package com.omoikaneinnovations.omoiservespare.service;
import com.omoikaneinnovations.omoiservespare.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrderEventPublisher {

    private final SimpMessagingTemplate messagingTemplate;

    public void toCanteen(String canteenId, Object payload) {
        messagingTemplate.convertAndSend("/topic/canteen/" + canteenId, payload);
    }

    public void toCustomer(User customer, Object payload) {
        messagingTemplate.convertAndSend("/topic/customer/" + customer.getEmail(), payload);
    }

    public void toOrder(String orderCode, Object payload) {
        messagingTemplate.convertAndSend("/topic/order/" + orderCode, payload);
    }
}