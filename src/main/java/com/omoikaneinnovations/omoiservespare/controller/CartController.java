package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import com.omoikaneinnovations.omoiservespare.dto.CartItemResponseDTO;
import java.util.List;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public List<CartItemResponseDTO> getCart() {
        return cartService.getCart(getUser());
    }

    @PostMapping("/add/{menuItemId}")
    public void add(@PathVariable Long menuItemId) {
        cartService.addToCart(getUser(), menuItemId);
    }

    @PostMapping("/decrease/{menuItemId}")
    public void decrease(@PathVariable Long menuItemId) {
        cartService.decreaseItem(getUser(), menuItemId);
    }

    @DeleteMapping("/clear")
    public void clear() {
        cartService.clearCart(getUser());
    }

    private String getUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth == null || !auth.isAuthenticated())
            throw new RuntimeException("Unauthenticated");

        return auth.getName(); // email
    }
}