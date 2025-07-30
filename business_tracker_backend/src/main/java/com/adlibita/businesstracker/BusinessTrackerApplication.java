// src/main/java/com/adlibita/businesstracker/BusinessTrackerApplication.java
package com.adlibita.businesstracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main-Klasse für die BusinessTracker REST API
 * 
 * [at]SpringBootApplication kombiniert:
 * - @Configuration: Diese Klasse enthält Spring-Konfiguration
 * - @EnableAutoConfiguration: Spring konfiguriert sich automatisch
 * - @ComponentScan: Spring scannt nach @Component, @Service, @Repository
 */

@SpringBootApplication
public class BusinessTrackerApplication {

    public static void main(String[] args) {
        SpringApplication.run(BusinessTrackerApplication.class, args);
    }
    /**
     * SpringApplication.run() startet:
     * - Embedded Tomcat Server (Port 8080)
     * - Spring Context (Dependency Injection)
     * - Auto-Configuration (Database, Web, etc.)
     */

}