package com.shopflow.orderservice.controller;

import com.shopflow.orderservice.model.CreateOrderRequest;
import com.shopflow.orderservice.model.Order;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@RestController
public class OrderController {

    private final List<Order> orders = new ArrayList<>();
    private final AtomicLong counter = new AtomicLong(1);

    @GetMapping("/health")
    public String health() {
        return "{\"status\":\"ok\",\"service\":\"order-service\"}";
    }

    @PostMapping("/orders")
    public Order createOrder(@RequestBody CreateOrderRequest request) {
        Order order = new Order(
                counter.getAndIncrement(),
                request.getUserId(),
                request.getProductId(),
                request.getQuantity(),
                "CREATED"
        );
        orders.add(order);
        return order;
    }

    @GetMapping("/orders/user/{userId}")
    public List<Order> getOrdersByUser(@PathVariable Long userId) {
        return orders.stream()
                .filter(order -> order.getUserId().equals(userId))
                .collect(Collectors.toList());
    }
}