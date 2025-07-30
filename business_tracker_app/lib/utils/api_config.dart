import 'dart:io';
import 'package:flutter/foundation.dart';

/// API-Konfiguration für BusinessTracker Backend
class ApiConfig {
  /// Dynamische Base URL je nach Plattform
  static String get baseUrl {
    // Für Web: kIsWeb = true → kein Platform.isAndroid verfügbar
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    // Für Android Emulator: 10.0.2.2 statt localhost
    // Für iOS Simulator/Desktop: localhost
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api';
      }
    } catch (e) {
      // Platform.isAndroid wirft Exception bei Web
      // Fallback zu localhost
    }

    return 'http://localhost:8080/api';
  }

  /// Basis-Endpoint für Expenses
  static const String expensesEndpoint = '/expenses';
  static const String healthEndpoint = '/health';

  /// Vollständige URLs
  static String get expenses => '$baseUrl$expensesEndpoint';
  static String get health => '$baseUrl$healthEndpoint';
  static String expenseById(int id) => '$baseUrl$expensesEndpoint/$id';
  static String expensesByCategory(String category) =>
      '$baseUrl$expensesEndpoint/category/$category';

  /// Statistics Endpoints
  static String expenseStats() => '$baseUrl$expensesEndpoint/stats';
  static String quarterlyStats({int? year}) =>
      '$baseUrl$expensesEndpoint/stats/quarterly${year != null ? '?year=$year' : ''}';
  static String yearlyStats() => '$baseUrl$expensesEndpoint/stats/yearly';

  /// Standard HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// Debug-Modus für detaillierte Logs
  static const bool debugMode = true;
}
