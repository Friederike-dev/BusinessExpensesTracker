import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/dashboard_screen.dart';
import 'package:http/http.dart' as http;

bool isFetching = false;

void testConnection() async {
  if (isFetching) return; // Verhindert parallele API-Aufrufe
  isFetching = true;

  try {
    final response = await http.get(Uri.parse('http://localhost:8080/api/health'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      print('✅ Connection successful!');
    } else {
      print('❌ Connection failed with status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during direct connection test: $e');
    if (e is SocketException) {
      print('SocketException details: ${e.osError?.message}');
    } else {
      print('Unhandled exception: $e');
    }
  }
}
void main() {
   testConnection(); // Verbindungstest ausführen
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
