import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(BusinessTrackerApp());
}

class BusinessTrackerApp extends StatelessWidget {
  // Flutter übergibt context automatisch an uns
  @override
  Widget build(BuildContext context) {
    // Flutter sagt: "Hier ist dein context, baue dein UI!"
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider erwartet eine Funktion, die den Provider erstellt:
        // "ChangeNotifierProvider, wenn du einen Provider brauchst, rufe diese Funktion auf, die einen neuen ExpenseProvider erstellt und zurückgibt."
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'BusinessTracker Pro',
        // debugShowCheckedModeBanner: false, // Entfernt das Debug-Banner
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: DashboardScreen(),
      ),
    );
  }
}
