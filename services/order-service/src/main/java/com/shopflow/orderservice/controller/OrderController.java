package com.shopflow.orderservice.controller;

import com.shopflow.orderservice.dto.CreateOrderRequest;
import com.shopflow.orderservice.model.Order;
import com.shopflow.orderservice.repository.OrderRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private final OrderRepository orderRepository;

    public OrderController(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Order createOrder(@RequestBody CreateOrderRequest request) {
    Order order = new Order();
    order.setUserId(request.getUserId());
    order.setProductId(request.getProductId());
    order.setQuantity(request.getQuantity());
    order.setStatus("CREATED");
    return orderRepository.save(order);
}

    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    @GetMapping("/{id}")
    public Order getOrderById(@PathVariable Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + id));
    }

    @GetMapping("/user/{userId}")
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