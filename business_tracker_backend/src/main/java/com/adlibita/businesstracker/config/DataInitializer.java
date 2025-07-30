package com.adlibita.businesstracker.config;

import com.adlibita.businesstracker.model.Expense;
import com.adlibita.businesstracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value; 
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * Erstellt automatisch Test-Daten beim App-Start
 * 
 * CommandLineRunner: Wird automatisch nach Spring Boot Start ausgeführt
 * Nur wenn Datenbank leer ist (count() == 0)
 */

//  Spring findet alle @Component-Klassen und erstellt Instanzen:
// // Spring macht automatisch:
// DataInitializer dataInitializer = new DataInitializer();
// ExpenseRepository expenseRepository = new ExpenseRepositoryImpl();

// // Dependency Injection:
// dataInitializer.expenseRepository = expenseRepository;  // @Autowired

// "Alle Klassen, die CommandLineRunner implementieren, werden nach dem Startup automatisch ausgeführt"


@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Value("${app.sample-data.enabled:true}")
    private boolean sampleDataEnabled;

    @Override
    public void run(String... args) throws Exception {
        // Nur Sample-Daten erstellen wenn enabled UND DB leer ist
        if (sampleDataEnabled && expenseRepository.count() == 0) {
            createSampleData();
        } else if (!sampleDataEnabled) {
            System.out.println("📋 Sample data creation disabled via configuration");
        } else {
            System.out.println("📊 Database already contains " + expenseRepository.count() + " expenses - skipping sample data");
        }
    }

    private void createSampleData() {
        System.out.println("🚀 Creating sample data...");

        // Sample Expense 1: Travel
        Expense expense1 = new Expense(
                "Hotel Berlin",
                150.50,
                "Travel",
                LocalDateTime.now().minusDays(5));
        expense1.setDescription("Business trip accommodation in Berlin");

        // Sample Expense 2: Office
        Expense expense2 = new Expense(
                "Office Supplies",
                89.99,
                "Office",
                LocalDateTime.now().minusDays(3));
        expense2.setDescription("Printer paper, pens, and notebooks");

        // Sample Expense 3: Software
        Expense expense3 = new Expense(
                "Software License",
                299.00,
                "Software",
                LocalDateTime.now().minusDays(1));
        expense3.setDescription("Annual license for development tools");

        // Sample Expense 4: Food
        Expense expense4 = new Expense(
                "Client Lunch",
                45.75,
                "Food",
                LocalDateTime.now().minusHours(2));
        expense4.setDescription("Business lunch with potential client");

        // Sample Expense 5: Transport
        Expense expense5 = new Expense(
                "Taxi to Airport",
                32.50,
                "Transport",
                LocalDateTime.now().minusHours(6));
        expense5.setDescription("Airport transfer for business trip");

        // Sample Expense 6: Marketing
        Expense expense6 = new Expense(
                "Google Ads Campaign",
                250.00,
                "Marketing",
                LocalDateTime.now().minusDays(2));
        expense6.setDescription("Online advertising for Q3 campaign");

        // Alle speichern
        expenseRepository.save(expense1);
        expenseRepository.save(expense2);
        expenseRepository.save(expense3);
        expenseRepository.save(expense4);
        expenseRepository.save(expense5);
        expenseRepository.save(expense6);

        System.out.println("✅ Sample data created successfully!");
        System.out.println("📊 Created " + expenseRepository.count() + " sample expenses");

        // Statistiken ausgeben
        printSampleDataStats();
    }

    private void printSampleDataStats() {
        System.out.println("\n📈 Sample Data Statistics:");
        System.out.println("─".repeat(40));

        // Total amount
        Double totalAmount = expenseRepository.findAll()
                .stream()
                .mapToDouble(Expense::getAmount)
                .sum();
        System.out.println("💰 Total Amount: €" + String.format("%.2f", totalAmount));

        // Count by category
        System.out.println("📂 Expenses by Category:");
        expenseRepository.findAll()
                .stream()
                .collect(java.util.stream.Collectors.groupingBy(
                        Expense::getCategory,
                        java.util.stream.Collectors.counting()))
                .forEach((category, count) -> System.out.println("   " + category + ": " + count + " expenses"));

        System.out.println("─".repeat(40));
        System.out.println("🎯 Ready for testing!");
    }
}