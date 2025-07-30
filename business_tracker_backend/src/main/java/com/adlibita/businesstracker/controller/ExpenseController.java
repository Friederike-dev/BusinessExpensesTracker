package com.adlibita.businesstracker.controller;

import com.adlibita.businesstracker.model.Expense;
import com.adlibita.businesstracker.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST Controller for Expense Management
 * 
 * Provides HTTP endpoints for complete CRUD operations and statistics:
 * 
 * BASIC CRUD OPERATIONS:
 * - GET    /api/expenses           → Retrieve all expenses
 * - POST   /api/expenses           → Create new expense
 * - GET    /api/expenses/{id}      → Get specific expense by ID
 * - PUT    /api/expenses/{id}      → Update existing expense
 * - DELETE /api/expenses/{id}      → Delete expense by ID
 * 
 * FILTERING & SEARCH:
 * - GET    /api/expenses/category/{category} → Filter by category
 * - GET    /api/expenses/search    → Search by title (query parameter)
 * 
 * STATISTICS & ANALYTICS:
 * - GET    /api/expenses/stats     → Dashboard statistics
 * - GET    /api/expenses/stats/quarterly → Quarterly breakdown
 * - GET    /api/expenses/stats/yearly    → Yearly summary
 * 
 * All endpoints return JSON responses and follow RESTful conventions.
 * CORS is enabled for frontend integration.
 * 
 * @author Friederike H.
 * @version 1.0
 * @since 2025-01-30
 */
@RestController // All methods return JSON automatically (no @ResponseBody needed)
@RequestMapping("/expenses")    // Basis URL für alle Endpoints
public class ExpenseController {

    /**
     * Service für Business Logic
     * @Autowired: Spring injiziert ExpenseService automatisch
     */
    @Autowired
    private ExpenseService expenseService;

    // =================== CREATE ===================

    /**
     * Erstelle neue Expense
     * 
     * HTTP: POST /api/expenses
     * Request Body: JSON mit Expense-Daten
     * Response: 201 CREATED + erstellte Expense
     * 
     * Beispiel Flutter HTTP-Call:
     * POST http://localhost:8080/api/expenses
     * {
     *   "title": "Hotel Berlin",
     *   "amount": 150.50,
     *   "category": "Travel",
     *   "expenseDate": "2025-07-16T10:00:00",
     *   "description": "Business trip accommodation"
     * }
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createExpense(@Valid @RequestBody Expense expense) {
        try {
            Expense savedExpense = expenseService.createExpense(expense);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expense created successfully");
            response.put("data", savedExpense);
            
            return new ResponseEntity<>(response, HttpStatus.CREATED);
            
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    // =================== READ ===================

    /**
     * Alle Expenses abrufen
     * 
     * HTTP: GET /api/expenses
     * Response: 200 OK + Liste aller Expenses (sortiert nach Datum)
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllExpenses() {
        List<Expense> expenses = expenseService.getAllExpenses();
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Expenses retrieved successfully");
        response.put("data", expenses);
        response.put("count", expenses.size());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Expense nach ID abrufen
     * 
     * HTTP: GET /api/expenses/{id}
     * Path Parameter: id (Long)
     * Response: 200 OK + Expense oder 404 NOT FOUND
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses/1
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getExpenseById(@PathVariable Long id) {
        try {
            Expense expense = expenseService.getExpenseById(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expense found");
            response.put("data", expense);
            
            return ResponseEntity.ok(response);
            
        } catch (ExpenseService.ExpenseNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
        }
    }

    // =================== UPDATE ===================

    /**
     * Expense updaten
     * 
     * HTTP: PUT /api/expenses/{id}
     * Path Parameter: id (Long)
     * Request Body: JSON mit geänderten Expense-Daten
     * Response: 200 OK + geupdatete Expense
     * 
     * Beispiel Flutter HTTP-Call:
     * PUT http://localhost:8080/api/expenses/1
     * {
     *   "title": "Hotel Berlin - Updated",
     *   "amount": 175.00
     * }
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateExpense(
            @PathVariable Long id, 
             @RequestBody Expense expenseDetails) {  // ← @Valid entfernt!
//                 Problem: @Valid validiert das ganze Objekt
// Lösung: Separate Validation für Updates - also dass nur die geänderten Felder angegeben werden müssen
        try {
            // Service macht die Validierung
            Expense updatedExpense = expenseService.updateExpense(id, expenseDetails);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expense updated successfully");
            response.put("data", updatedExpense);
            
            return ResponseEntity.ok(response);
            
        } catch (ExpenseService.ExpenseNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
            
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    // =================== DELETE ===================

    /**
     * Expense löschen
     * 
     * HTTP: DELETE /api/expenses/{id}
     * Path Parameter: id (Long)
     * Response: 200 OK + Bestätigung
     * 
     * Beispiel Flutter HTTP-Call:
     * DELETE http://localhost:8080/api/expenses/1
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteExpense(@PathVariable Long id) {
        try {
            expenseService.deleteExpense(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expense deleted successfully");
            response.put("data", null);
            
            return ResponseEntity.ok(response);
            
        } catch (ExpenseService.ExpenseNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
            
        } catch (IllegalStateException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.FORBIDDEN);
        }
    }

    // =================== SEARCH & FILTER ===================

    /**
     * Expenses nach Kategorie filtern
     * 
     * HTTP: GET /api/expenses/category/{category}
     * Path Parameter: category (String)
     * Response: 200 OK + gefilterte Expenses
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses/category/Travel
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<Map<String, Object>> getExpensesByCategory(@PathVariable String category) {
        try {
            List<Expense> expenses = expenseService.getExpensesByCategory(category);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expenses for category '" + category + "' retrieved");
            response.put("data", expenses);
            response.put("count", expenses.size());
            
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    /**
     * Expenses nach Titel suchen
     * 
     * HTTP: GET /api/expenses/search?term={searchTerm}
     * Query Parameter: term (String)
     * Response: 200 OK + gefundene Expenses
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses/search?term=hotel
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchExpenses(@RequestParam String term) {
        List<Expense> expenses = expenseService.searchExpensesByTitle(term);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Search completed for term: '" + term + "'");
        response.put("data", expenses);
        response.put("count", expenses.size());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Expenses in Datumsbereich abrufen
     * 
     * HTTP: GET /api/expenses/range?start={startDate}&end={endDate}
     * Query Parameters: start, end (ISO DateTime)
     * Response: 200 OK + gefilterte Expenses
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses/range?start=2025-07-01T00:00:00&end=2025-07-31T23:59:59
     */
    @GetMapping("/range")
    public ResponseEntity<Map<String, Object>> getExpensesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        try {
            List<Expense> expenses = expenseService.getExpensesByDateRange(start, end);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Expenses in date range retrieved");
            response.put("data", expenses);
            response.put("count", expenses.size());
            
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            errorResponse.put("data", null);
            
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    // =================== STATISTICS ===================

    /**
     * Dashboard-Statistiken abrufen
     * 
     * HTTP: GET /api/expenses/stats
     * Response: 200 OK + Statistiken für Flutter Dashboard
     * 
     * Beispiel Flutter HTTP-Call:
     * GET http://localhost:8080/api/expenses/stats
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getExpenseStatistics() {
        Double totalAmount = expenseService.getTotalExpenseAmount();
        List<Object[]> categoryStats = expenseService.getExpensesByCategory();
        List<Expense> expensiveExpenses = expenseService.getExpensiveExpenses(100.0);
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalAmount", totalAmount);
        stats.put("categoryBreakdown", categoryStats);
        stats.put("expensiveExpenses", expensiveExpenses);
        stats.put("expensiveCount", expensiveExpenses.size());
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Statistics retrieved successfully");
        response.put("data", stats);
        
        return ResponseEntity.ok(response);
    }

    // =================== QUARTERLY & YEARLY STATISTICS ===================

    /**
     * Quartals-Statistiken abrufen
     * 
     * HTTP: GET /api/expenses/stats/quarterly?year={year}
     * Query Parameter: year (optional, default: aktuelles Jahr)
     * Response: 200 OK + Quartals-Statistiken
     */
    @GetMapping("/stats/quarterly")
    public ResponseEntity<Map<String, Object>> getQuarterlyStatistics(
            @RequestParam(required = false) Integer year) {
        
        if (year == null) {
            year = LocalDateTime.now().getYear();
        }
        
        Map<String, Object> quarterlyStats = expenseService.getQuarterlyStatistics(year);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Quarterly statistics for " + year + " retrieved successfully");
        response.put("data", quarterlyStats);
        
        return ResponseEntity.ok(response);
    }

    /**
     * Jahres-Statistiken abrufen
     * 
     * HTTP: GET /api/expenses/stats/yearly
     * Response: 200 OK + Jahres-Statistiken (alle Jahre)
     */
    @GetMapping("/stats/yearly")
    public ResponseEntity<Map<String, Object>> getYearlyStatistics() {
        Map<String, Object> yearlyStats = expenseService.getYearlyStatistics();
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Yearly statistics retrieved successfully");
        response.put("data", yearlyStats);
        
        return ResponseEntity.ok(response);
    }

    // =================== EXCEPTION HANDLING ===================

    /**
     * Global Exception Handler für unerwartete Fehler
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGenericException(Exception e) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("message", "An unexpected error occurred: " + e.getMessage());
        errorResponse.put("data", null);
        
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}