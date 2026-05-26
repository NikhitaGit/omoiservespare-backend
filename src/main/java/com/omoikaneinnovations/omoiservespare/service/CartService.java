package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.CartItemResponseDTO;
import com.omoikaneinnovations.omoiservespare.entity.Canteen;
import com.omoikaneinnovations.omoiservespare.entity.CartItem;
import com.omoikaneinnovations.omoiservespare.entity.MenuItem;
import com.omoikaneinnovations.omoiservespare.repository.CanteenRepository;
import com.omoikaneinnovations.omoiservespare.repository.MenuItemRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class CartService {

    @Autowired(required = false)
    private RedisTemplate<String, Object> redisTemplate;
    
    private final MenuItemRepository menuItemRepository;
    private final CanteenRepository canteenRepository;
    
    // In-memory fallback when Redis is not available
    private final Map<String, List<CartItem>> inMemoryCart = new ConcurrentHashMap<>();

    public CartService(MenuItemRepository menuItemRepository, CanteenRepository canteenRepository) {
        this.menuItemRepository = menuItemRepository;
        this.canteenRepository = canteenRepository;
    }

    private static final String CART_PREFIX = "cart:";

    private String key(String userEmail) {
        return CART_PREFIX + userEmail;
    }

    /* ================= RAW CART (FOR ORDER SERVICE) ================= */
    public List<CartItem> getCartRaw(String userEmail) {
        if (redisTemplate != null) {
            try {
                return (List<CartItem>) redisTemplate.opsForValue().get(key(userEmail));
            } catch (Exception e) {
                log.warn("Redis unavailable, using in-memory cart: {}", e.getMessage());
                return inMemoryCart.get(userEmail);
            }
        } else {
            return inMemoryCart.get(userEmail);
        }
    }

    /* ================= DTO CART (FOR CONTROLLER) ================= */
    public List<CartItemResponseDTO> getCart(String userEmail) {

        List<CartItem> cart = getCartRaw(userEmail);

        if (cart == null || cart.isEmpty())
            return Collections.emptyList();

        return cart.stream().map(item -> {

            MenuItem menuItem = menuItemRepository.findById(item.getMenuItemId())
                    .orElseThrow();

            Canteen canteen = canteenRepository.findById(menuItem.getCanteenId())
                    .orElseThrow();

            return CartItemResponseDTO.builder()
                    .menuItemId(item.getMenuItemId())
                    .name(item.getName())
                    .price(item.getPrice())
                    .quantity(item.getQuantity())
                    .imageUrl(item.getImageUrl())
                    .canteenId(canteen.getId())
                    .canteenName(canteen.getName())
                    .build();

        }).toList();
    }

    /* ================= ADD ================= */
    public void addToCart(String userEmail, Long menuItemId) {

        List<CartItem> cart = getCartRaw(userEmail);
        if (cart == null)
            cart = new ArrayList<>();

        Optional<CartItem> existing = cart.stream()
                .filter(c -> c.getMenuItemId().equals(menuItemId))
                .findFirst();

        if (existing.isPresent()) {
            existing.get().setQuantity(existing.get().getQuantity() + 1);
        } else {

            MenuItem item = menuItemRepository.findById(menuItemId)
                    .orElseThrow(() -> new RuntimeException("Item not found"));

            String image = item.getOverrideImageUrl() != null
                    ? item.getOverrideImageUrl()
                    : item.getDish().getBaseDish().getDefaultImageUrl();

            CartItem newItem = new CartItem(
                    item.getId(),
                    item.getDish().getName(),
                    item.getPrice().doubleValue(),
                    1,
                    image);

            cart.add(newItem);
        }

        saveCart(userEmail, cart);
    }

    /* ================= DECREASE ================= */
    public void decreaseItem(String userEmail, Long menuItemId) {

        List<CartItem> cart = getCartRaw(userEmail);
        if (cart == null)
            return;

        cart.removeIf(item -> {
            if (item.getMenuItemId().equals(menuItemId)) {
                if (item.getQuantity() > 1) {
                    item.setQuantity(item.getQuantity() - 1);
                    return false;
                }
                return true;
            }
            return false;
        });

        saveCart(userEmail, cart);
    }

    public void clearCart(String userEmail) {
        if (redisTemplate != null) {
            try {
                redisTemplate.delete(key(userEmail));
            } catch (Exception e) {
                log.warn("Redis unavailable for cart clear, using in-memory: {}", e.getMessage());
                inMemoryCart.remove(userEmail);
            }
        } else {
            inMemoryCart.remove(userEmail);
        }
    }
    
    private void saveCart(String userEmail, List<CartItem> cart) {
        if (redisTemplate != null) {
            try {
                redisTemplate.opsForValue().set(key(userEmail), cart, 30, TimeUnit.MINUTES);
            } catch (Exception e) {
                log.warn("Redis unavailable for cart save, using in-memory: {}", e.getMessage());
                inMemoryCart.put(userEmail, cart);
            }
        } else {
            inMemoryCart.put(userEmail, cart);
        }
    }
}