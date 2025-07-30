package com.adlibita.businesstracker.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class TestController {

    @GetMapping("/")
    public Map<String, String> root() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "BusinessTracker API is running!");
        response.put("status", "OK");
        return response;
    }

    @GetMapping("/test")
    public Map<String, String> test() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Test endpoint working!");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        return response;
    }
}
