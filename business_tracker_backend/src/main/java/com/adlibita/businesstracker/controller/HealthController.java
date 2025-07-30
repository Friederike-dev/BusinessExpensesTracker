package com.adlibita.businesstracker.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;


/**
 * Health-Check Controller für API-Status
 */

//  @RestController: Diese Klasse verarbeitet HTTP-Requests und gibt JSON zurück
@RestController
// @RequestMapping("/health"): Basis-URL für alle Methoden in diesem Controller
@RequestMapping("/health")
public class HealthController {

    // @GetMapping: Diese Methode verarbeitet GET-Requests an /api/health
    @GetMapping
    public Map<String, Object> health() {
        // Map<String, Object>: Wird automatisch zu JSON konvertiert
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("message", "BusinessTracker API is running successfully!");
        response.put("version", "1.0.0");
        return response;
    }
}