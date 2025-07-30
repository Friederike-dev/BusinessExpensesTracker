package com.adlibita.businesstracker.repository;

import com.adlibita.businesstracker.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

import javax.swing.Spring;

/**
 * Repository für Expense-Datenbank-Operationen
 * 
 * JpaRepository<Expense, Long> bedeutet:
 * - Entity-Type: Expense
 * - Primary Key Type: Long
 * 
 * Spring Data JPA erstellt automatisch Implementierung mit:
 * - save() → INSERT/UPDATE
 * - findById() → SELECT WHERE id = ?
 * - findAll() → SELECT * FROM expenses
 * - deleteById() → DELETE WHERE id = ?
 * - count() → SELECT COUNT(*) FROM expenses
 * - existsById() → SELECT COUNT(*) WHERE id = ? > 0
 */
@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

//     Spring Data JPA generiert automatisch:
// save() → INSERT/UPDATE SQL
// findById() → SELECT WHERE id = ?
// findAll() → SELECT * FROM expenses
// deleteById() → DELETE WHERE id = ?
//      Plus die custom Methods:
// findByCategory() → SELECT * WHERE category = ?
// findByTitleContainingIgnoreCase() → SELECT * WHERE title LIKE %?%

    /**
     * Finde alle Expenses einer bestimmten Kategorie
     * 
     * Spring Data JPA generiert automatisch SQL:
     * SELECT * FROM expenses WHERE category = ?
     */
    List<Expense> findByCategory(String category);

    /**
     * Finde Expenses nach Titel (case-insensitive)
     * 
     * Spring Data JPA generiert:
     * SELECT * FROM expenses WHERE UPPER(title) LIKE UPPER(?)
     */
    List<Expense> findByTitleContainingIgnoreCase(String title);

    /**
     * Finde Expenses zwischen zwei Datums
     * 
     * Spring Data JPA generiert:
     * SELECT * FROM expenses WHERE expense_date BETWEEN ? AND ?
     */
    List<Expense> findByExpenseDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Finde Expenses größer als bestimmter Betrag
     * 
     * Spring Data JPA generiert:
     * SELECT * FROM expenses WHERE amount > ?
     */
    List<Expense> findByAmountGreaterThan(Double amount);

    /**
     * Finde Expenses sortiert nach Datum (neueste zuerst)
     * 
     * Spring Data JPA generiert:
     * SELECT * FROM expenses ORDER BY expense_date DESC
     */
    List<Expense> findAllByOrderByExpenseDateDesc();

    /**
     * Custom Query: Summe aller Expenses pro Kategorie
     * 
     * @Query erlaubt eigene SQL/JPQL-Queries
     */
    @Query("SELECT e.category, SUM(e.amount) FROM Expense e GROUP BY e.category")
    List<Object[]> findTotalAmountByCategory();

    /**
     * Custom Query: Finde Expenses im aktuellen Monat
     */
    @Query("SELECT e FROM Expense e WHERE YEAR(e.expenseDate) = YEAR(CURRENT_DATE) AND MONTH(e.expenseDate) = MONTH(CURRENT_DATE)")
    List<Expense> findExpensesThisMonth();

    /**
     * Custom Query: Finde Top 5 teuerste Expenses
     */
    @Query("SELECT e FROM Expense e ORDER BY e.amount DESC")
    List<Expense> findTop5ByOrderByAmountDesc();

    /**
     * Named Parameter Query: Finde Expenses nach Kategorie und Mindestbetrag
     */
    @Query("SELECT e FROM Expense e WHERE e.category = :category AND e.amount >= :minAmount")
    List<Expense> findByCategoryAndMinAmount(@Param("category") String category, @Param("minAmount") Double minAmount);

}