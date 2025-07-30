package com.adlibita.businesstracker.service;

import com.adlibita.businesstracker.model.Expense;
import com.adlibita.businesstracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Service Layer für Expense Business Logic
 * 
 * @Service: Spring verwaltet diese Klasse als Bean
 * @Transactional: Alle Methoden laufen in Database-Transaktionen
 */
@Service // Spring nutzt Spring Bean, um diese Klasse zu verwalten. Spring Bean ist eine Instanz dieser Klasse, die Spring erstellt und verwaltet.
@Transactional // Alle Methoden laufen in einer Datenbank-Transaktion
public class ExpenseService {

    /**
     * Repository für Datenbank-Zugriff
     * @Autowired: Spring injiziert automatisch ExpenseRepository
     *  = Dependency Injection
     */
    @Autowired
    private ExpenseRepository expenseRepository;

    /**
     * Erstelle neue Expense
     * 
     * Business Logic:
     * 1. Validiere Eingabedaten
     * 2. Setze Standardwerte
     * 3. Speichere in Database
     * 4. Gebe gespeicherte Expense zurück
     */
    public Expense createExpense(Expense expense) {
        // Geschäftslogik: Validierung
        validateExpense(expense);
        
        // Geschäftslogik: Standardwerte setzen
        if (expense.getExpenseDate() == null) {
            expense.setExpenseDate(LocalDateTime.now());
        }
        
        // Repository-Aufruf: Speichern
        return expenseRepository.save(expense);
    }

    /**
     * Finde alle Expenses
     * 
     * Business Logic:
     * - Sortiere nach Datum (neueste zuerst)
     * - Könnte später Filtering/Paging hinzufügen
     */
    @Transactional(readOnly = true)  // Nur lesen = Performance-Optimierung
    public List<Expense> getAllExpenses() {
        return expenseRepository.findAllByOrderByExpenseDateDesc();
    }

    /**
     * Finde Expense nach ID
     * 
     * Business Logic:
     * - Prüfe ob Expense existiert
     * - Werfe Exception falls nicht gefunden
     */
    @Transactional(readOnly = true)
    public Expense getExpenseById(Long id) {
        return expenseRepository.findById(id)
                .orElseThrow(() -> new ExpenseNotFoundException("Expense with ID " + id + " not found"));
    }

    /**
     * Update bestehende Expense
     * 
     * Business Logic:
     * 1. Prüfe ob Expense existiert
     * 2. Validiere neue Daten
     * 3. Update nur geänderte Felder
     * 4. Speichere Änderungen
     */
    public Expense updateExpense(Long id, Expense expenseDetails) {
        // Prüfe ob Expense existiert
        Expense existingExpense = getExpenseById(id);
        
        // Validiere neue Daten
        validateExpense(expenseDetails);
        
        // Update Felder (nur nicht-null Werte)
        if (expenseDetails.getTitle() != null) {
            existingExpense.setTitle(expenseDetails.getTitle());
        }
        if (expenseDetails.getAmount() != null) {
            existingExpense.setAmount(expenseDetails.getAmount());
        }
        if (expenseDetails.getCategory() != null) {
            existingExpense.setCategory(expenseDetails.getCategory());
        }
        if (expenseDetails.getExpenseDate() != null) {
            existingExpense.setExpenseDate(expenseDetails.getExpenseDate());
        }
        if (expenseDetails.getDescription() != null) {
            existingExpense.setDescription(expenseDetails.getDescription());
        }
        if (expenseDetails.getImagePath() != null) {
            existingExpense.setImagePath(expenseDetails.getImagePath());
        }
        
        // Speichere Änderungen
        return expenseRepository.save(existingExpense);
    }

    /**
     * Lösche Expense
     * 
     * Business Logic:
     * 1. Prüfe ob Expense existiert
     * 2. Prüfe Geschäftsregeln (z.B. nur eigene Expenses löschen)
     * 3. Lösche aus Database
     */
    public void deleteExpense(Long id) {
        // Prüfe ob existiert (wirft Exception falls nicht)
        Expense expense = getExpenseById(id);
        
        // Geschäftslogik: Prüfe ob Löschung erlaubt
        validateDeletion(expense);
        
        // Repository-Aufruf: Löschen
        expenseRepository.deleteById(id);
    }

    /**
     * Finde Expenses nach Kategorie
     */
    @Transactional(readOnly = true)
    public List<Expense> getExpensesByCategory(String category) {
        if (category == null || category.trim().isEmpty()) {
            throw new IllegalArgumentException("Category cannot be empty");
        }
        return expenseRepository.findByCategory(category);
    }

    /**
     * Finde Expenses zwischen zwei Datums
     */
    @Transactional(readOnly = true)
    public List<Expense> getExpensesByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException("Start and end date must be provided");
        }
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("Start date must be before end date");
        }
        return expenseRepository.findByExpenseDateBetween(startDate, endDate);
    }

    /**
     * Berechne Gesamtsumme aller Expenses
     * 
     * Business Logic für Dashboard/Statistics
     */
    @Transactional(readOnly = true)
    public Double getTotalExpenseAmount() {
        List<Expense> allExpenses = expenseRepository.findAll();
        return allExpenses.stream()
                .mapToDouble(Expense::getAmount)
                .sum();
    }

    /**
     * Berechne Ausgaben pro Kategorie
     * 
     * Business Logic für Charts/Reports
     */
    @Transactional(readOnly = true)
    public List<Object[]> getExpensesByCategory() {
        return expenseRepository.findTotalAmountByCategory();
    }

    /**
     * Finde teure Expenses (über bestimmtem Betrag)
     * 
     * Business Logic für Alerts/Monitoring
     */
    @Transactional(readOnly = true)
    public List<Expense> getExpensiveExpenses(Double threshold) {
        if (threshold == null || threshold <= 0) {
            threshold = 100.0; // Default threshold
        }
        return expenseRepository.findByAmountGreaterThan(threshold);
    }

    /**
     * Suche Expenses nach Titel
     */
    @Transactional(readOnly = true)
    public List<Expense> searchExpensesByTitle(String searchTerm) {
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getAllExpenses();
        }
        return expenseRepository.findByTitleContainingIgnoreCase(searchTerm.trim());
    }

    // =================== QUARTERLY & YEARLY STATISTICS ===================

    /**
     * Quartals-Statistiken für ein bestimmtes Jahr
     * 
     * Berechnet für jedes Quartal:
     * - Gesamtausgaben
     * - Prozentuale Veränderung zum Vorquartal
     * - Ausgaben nach Kategorie
     */
    public Map<String, Object> getQuarterlyStatistics(Integer year) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> quarters = new ArrayList<>();

        for (int quarter = 1; quarter <= 4; quarter++) {
            LocalDateTime startDate = getQuarterStart(year, quarter);
            LocalDateTime endDate = getQuarterEnd(year, quarter);
            
            List<Expense> quarterExpenses = expenseRepository.findByExpenseDateBetween(startDate, endDate);
            double quarterTotal = quarterExpenses.stream().mapToDouble(Expense::getAmount).sum();
            
            // Prozentuale Veränderung zum Vorquartal berechnen
            Double previousQuarterTotal = null;
            Double percentageChange = null;
            
            if (quarter > 1) {
                LocalDateTime prevStartDate = getQuarterStart(year, quarter - 1);
                LocalDateTime prevEndDate = getQuarterEnd(year, quarter - 1);
                List<Expense> prevQuarterExpenses = expenseRepository.findByExpenseDateBetween(prevStartDate, prevEndDate);
                previousQuarterTotal = prevQuarterExpenses.stream().mapToDouble(Expense::getAmount).sum();
                
                if (previousQuarterTotal > 0) {
                    percentageChange = ((quarterTotal - previousQuarterTotal) / previousQuarterTotal) * 100;
                }
            }
            
            // Ausgaben nach Kategorie für dieses Quartal
            Map<String, Double> categoryBreakdown = quarterExpenses.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                    Expense::getCategory,
                    java.util.stream.Collectors.summingDouble(Expense::getAmount)
                ));
            
            Map<String, Object> quarterData = new HashMap<>();
            quarterData.put("quarter", quarter);
            quarterData.put("year", year);
            quarterData.put("totalAmount", quarterTotal);
            quarterData.put("expenseCount", quarterExpenses.size());
            quarterData.put("previousQuarterTotal", previousQuarterTotal);
            quarterData.put("percentageChange", percentageChange);
            quarterData.put("categoryBreakdown", categoryBreakdown);
            quarterData.put("startDate", startDate);
            quarterData.put("endDate", endDate);
            
            quarters.add(quarterData);
        }
        
        // Jahresgesamtsumme
        double yearTotal = quarters.stream()
            .mapToDouble(q -> (Double) q.get("totalAmount"))
            .sum();
        
        result.put("year", year);
        result.put("quarters", quarters);
        result.put("yearTotal", yearTotal);
        result.put("averagePerQuarter", yearTotal / 4);
        
        return result;
    }

    /**
     * Jahres-Statistiken für alle Jahre
     * 
     * Zeigt Trends über mehrere Jahre hinweg
     */
    public Map<String, Object> getYearlyStatistics() {
        List<Expense> allExpenses = expenseRepository.findAll();
        
        // Gruppiere nach Jahren
        Map<Integer, List<Expense>> expensesByYear = allExpenses.stream()
            .collect(java.util.stream.Collectors.groupingBy(
                expense -> expense.getExpenseDate().getYear()
            ));
        
        List<Map<String, Object>> yearlyData = new ArrayList<>();
        Integer previousYear = null;
        Double previousYearTotal = null;
        
        for (Integer year : expensesByYear.keySet().stream().sorted().toList()) {
            List<Expense> yearExpenses = expensesByYear.get(year);
            double yearTotal = yearExpenses.stream().mapToDouble(Expense::getAmount).sum();
            
            // Prozentuale Veränderung zum Vorjahr
            Double percentageChange = null;
            if (previousYearTotal != null && previousYearTotal > 0) {
                percentageChange = ((yearTotal - previousYearTotal) / previousYearTotal) * 100;
            }
            
            // Ausgaben nach Kategorie für dieses Jahr
            Map<String, Double> categoryBreakdown = yearExpenses.stream()
                .collect(java.util.stream.Collectors.groupingBy(
                    Expense::getCategory,
                    java.util.stream.Collectors.summingDouble(Expense::getAmount)
                ));
            
            Map<String, Object> yearData = new HashMap<>();
            yearData.put("year", year);
            yearData.put("totalAmount", yearTotal);
            yearData.put("expenseCount", yearExpenses.size());
            yearData.put("previousYearTotal", previousYearTotal);
            yearData.put("percentageChange", percentageChange);
            yearData.put("categoryBreakdown", categoryBreakdown);
            yearData.put("averagePerMonth", yearTotal / 12);
            
            yearlyData.add(yearData);
            
            previousYear = year;
            previousYearTotal = yearTotal;
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("years", yearlyData);
        result.put("totalYears", yearlyData.size());
        
        if (!yearlyData.isEmpty()) {
            double grandTotal = yearlyData.stream()
                .mapToDouble(y -> (Double) y.get("totalAmount"))
                .sum();
            result.put("grandTotal", grandTotal);
            result.put("averagePerYear", grandTotal / yearlyData.size());
        }
        
        return result;
    }

    /**
     * Helper: Quartal-Startdatum berechnen
     */
    private LocalDateTime getQuarterStart(int year, int quarter) {
        int month = (quarter - 1) * 3 + 1;
        return LocalDateTime.of(year, month, 1, 0, 0, 0);
    }

    /**
     * Helper: Quartal-Enddatum berechnen
     */
    private LocalDateTime getQuarterEnd(int year, int quarter) {
        int month = quarter * 3;
        return LocalDateTime.of(year, month, 1, 0, 0, 0)
            .plusMonths(1)
            .minusDays(1)
            .withHour(23)
            .withMinute(59)
            .withSecond(59);
    }

    // ============ PRIVATE HELPER METHODS ============

    /**
     * Validiere Expense-Daten
     * 
     * Business Rules:
     * - Title darf nicht leer sein
     * - Amount muss positiv sein
     * - Category muss erlaubt sein
     * - Datum darf nicht in der Zukunft liegen
     */
    private void validateExpense(Expense expense) {
        if (expense == null) {
            throw new IllegalArgumentException("Expense cannot be null");
        }
        
        // Title validieren
        if (expense.getTitle() == null || expense.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Expense title is required");
        }
        if (expense.getTitle().length() > 255) {
            throw new IllegalArgumentException("Expense title cannot exceed 255 characters");
        }
        
        // Amount validieren
        if (expense.getAmount() == null) {
            throw new IllegalArgumentException("Expense amount is required");
        }
        if (expense.getAmount() <= 0) {
            throw new IllegalArgumentException("Expense amount must be positive");
        }
        if (expense.getAmount() > 999999.99) {
            throw new IllegalArgumentException("Expense amount cannot exceed 999999.99");
        }
        
        // Category validieren
        if (expense.getCategory() == null || expense.getCategory().trim().isEmpty()) {
            throw new IllegalArgumentException("Expense category is required");
        }
        if (!isValidCategory(expense.getCategory())) {
            throw new IllegalArgumentException("Invalid expense category: " + expense.getCategory());
        }
        
        // Datum validieren
        if (expense.getExpenseDate() != null && expense.getExpenseDate().isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("Expense date cannot be in the future");
        }
    }

    /**
     * Prüfe ob Kategorie erlaubt ist
     * 
     * Business Rule: Nur bestimmte Kategorien erlaubt
     */
    private boolean isValidCategory(String category) {
        List<String> allowedCategories = List.of(
            "Travel", "Office", "Marketing", "Equipment", 
            "Software", "Training", "Food", "Transport", 
            "Accommodation", "Other"
        );
        return allowedCategories.contains(category);
    }

    /**
     * Validiere ob Löschung erlaubt ist
     * 
     * Business Rules:
     * - Könnte prüfen ob User berechtigt ist
     * - Könnte prüfen ob Expense nicht zu alt ist
     * - Könnte prüfen ob Expense nicht bereits abgerechnet ist
     */
    private void validateDeletion(Expense expense) {
        // Beispiel Business Rule: Keine Expenses älter als 30 Tage löschen
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        if (expense.getCreatedAt().isBefore(thirtyDaysAgo)) {
            throw new IllegalStateException("Cannot delete expenses older than 30 days");
        }
        
        // Weitere Business Rules könnten hier stehen...
    }

    /**
     * Custom Exception für nicht gefundene Expenses
     */
    public static class ExpenseNotFoundException extends RuntimeException {
        public ExpenseNotFoundException(String message) {
            super(message);
        }
    }
}