package com.shopflow.orderservice.controller;

import com.shopflow.orderservice.dto.CreateOrderRequest;
import com.shopflow.orderservice.model.Order;
import com.shopflow.orderservice.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping("/orders")
    public Order createOrder(@RequestBody CreateOrderRequest request) {
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setProductId(request.getProductId());
        order.setQuantity(request.getQuantity());
        order.setStatus("CREATED");
        return orderRepository.save(order);
    }

    @GetMapping("/orders/user/{userId}")
    public List<Order> getOrdersByUser(@PathVariable Long userId) {
        return orderRepository.findAll().stream()
                .filter(order -> order.getUserId().equals(userId))
                .toList();
    }

    @GetMapping("/health")
    public String health() {
        return "{\"status\":\"ok\",\"service\":\"order-service\"}";
    }
}