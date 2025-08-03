import 'dart:io';
import 'package:flutter/foundation.dart';

/// API-Konfiguration für BusinessTracker Backend
class ApiConfig {
  /// Dynamische Base URL je nach Plattform
  static String get baseUrl {
    // Für Web: kIsWeb = true → kein Platform.isAndroid verfügbar
    if (kIsWeb) {
      print('Platform: Web');
      print('API Base URL: http://localhost:8080/api');
      return 'http://localhost:8080/api';
    }

    // Für Android Emulator: 10.0.2.2 statt localhost
    try {
      if (Platform.isAndroid) {
        print('Platform: Android');
        print('API Base URL: http://10.0.2.2:8080/api');
        return 'http://10.0.2.2:8080/api';
      }
      if (Platform.isIOS) {
        print('Platform: iOS');
        // TODO: Set your MacBook's IP here for local testing
        return 'http://<YOUR_LOCAL_IP>:8080/api';
      }
    } catch (e) {
      // Platform.isAndroid wirft Exception bei Web
      // Fallback zu localhost für andere Plattformen
      print('Error determining platform: $e');
    }

    // Für macOS: 127.0.0.1 statt localhost
    if (Platform.isMacOS) {
      print('Platform: macOS');
      print('API Base URL: http://localhost:8080/api');
      return 'http://localhost:8080/api';
    }

    // Standard-Fallback für andere Plattformen
    print('Platform: macOS/iOS/Desktop');
    print('API Base URL: http://localhost:8080/api');
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
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Debug-Modus für detaillierte Logs
  static const bool debugMode = true;
}
