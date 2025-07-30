package com.adlibita.businesstracker.config;

import org.springframework.context.annotation.Configuration;

/**
 * Vereinfachte Jackson-Konfiguration für DateTime-Parsing
 * 
 * Lösung: Flutter sendet nur noch einfaches Format "yyyy-MM-ddTHH:00:00"
 * Keine Minuten, Sekunden oder Millisekunden mehr
 */
@Configuration
public class JacksonConfig {
    // Basiskonfiguration über application.properties
    // spring.jackson.date-format=yyyy-MM-dd'T'HH:mm:ss
}
