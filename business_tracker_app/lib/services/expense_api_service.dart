import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../models/quarterly_stats.dart';
import '../models/yearly_stats.dart';
import '../utils/api_config.dart';
import 'dart:async';

/**
 * API Exception - Custom exception for API-related errors
 * 
 * Provides detailed error information including HTTP status codes
 * and descriptive error messages for better debugging and user feedback.
 */
/// Exception for API-related errors
class ApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code (if available)
  final int? statusCode;

  /// Creates a new API exception
  ///
  /// [message] - Description of the error
  /// [statusCode] - HTTP status code (optional)
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/**
 * Expense API Service - HTTP client for BusinessTracker API
 * 
 * This service class handles all communication with the Spring Boot backend.
 * Implements the Singleton pattern to ensure a single instance across the app.
 * 
 * Features:
 * - Complete CRUD operations for expenses
 * - Statistics and analytics endpoints
 * - Error handling with custom exceptions
 * - JSON serialization/deserialization
 * - HTTP client with proper headers
 * 
 * API Endpoints:
 * - GET    /api/health                   → Backend status check
 * - GET    /api/expenses                 → Get all expenses
 * - POST   /api/expenses                 → Create new expense
 * - GET    /api/expenses/{id}            → Get expense by ID
 * - PUT    /api/expenses/{id}            → Update expense
 * - DELETE /api/expenses/{id}            → Delete expense
 * - GET    /api/expenses/stats/quarterly → Quarterly statistics
 * - GET    /api/expenses/stats/yearly    → Yearly statistics
 * 
 * @author Friederike H.
 * @version 1.0
 * @since 2025-01-30
 */
/// HTTP Service for BusinessTracker API communication
class ExpenseApiService {
  // === SINGLETON PATTERN IMPLEMENTATION ===

  /// Private static instance
  static final ExpenseApiService _instance = ExpenseApiService._internal();

  /// Factory constructor returns singleton instance
  factory ExpenseApiService() => _instance;

  /// Private constructor for singleton
  ExpenseApiService._internal();

  // === HTTP CLIENT CONFIGURATION ===

  /// HTTP client for making requests
  /// Reused across all API calls for connection pooling
  final http.Client _client = http.Client();

  // === API ENDPOINTS ===

  /// **GET /api/health** - Health Check
  ///
  /// Tests if the API backend is reachable and responsive.
  /// Used for connectivity verification and system status monitoring.
  ///
  /// Returns: Map with status information
  /// Throws: [ApiException] if backend is unreachable
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 API Health Check: ${ApiConfig.health}');
      }

      // Debugging-Ausgabe für Timeout-Werte
      print('Connect timeout: ${ApiConfig.connectTimeout}');
      print('Receive timeout: ${ApiConfig.receiveTimeout}');
      // Debugging-Ausgabe für HTTP-Header
      print('Default headers: ${ApiConfig.defaultHeaders}');
      // Debugging-Ausgabe vor dem API-Aufruf
      print('Testing API connection: ${ApiConfig.health}');

      try {
        print('Testing API connection: ${ApiConfig.health}');
        final response = await _client
            .get(
              Uri.parse(ApiConfig.health),
              headers: ApiConfig.defaultHeaders,
            )
            .timeout(ApiConfig.connectTimeout);

        // Debugging-Ausgabe nach dem API-Aufruf
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (!data.containsKey('success') || data['success'] != true) {
            print('❌ Invalid response structure: $data');
            throw ApiException(
                'Invalid response structure: success flag missing or false');
          }
          if (!data.containsKey('success') || data['success'] != true) {
            throw ApiException(
                'Invalid response structure: success flag missing or false');
          }
          if (ApiConfig.debugMode) {
            print('✅ Health Check OK: ${data['message']}');
            print('Full response: $data');
          }
          return data;
        } else {
          print(
              '❌ Health Check failed with status code: ${response.statusCode}');
          throw ApiException('Health check failed', response.statusCode);
        }
      } catch (e) {
        print('Error during API call: $e');
        if (e is SocketException) {
          print('SocketException details: ${e.osError?.message}');
          print('SocketException raw: $e');
          print('Is the backend running? Check port accessibility.');
          throw ApiException('No internet connection or server not running');
        } else if (e is TimeoutException) {
          print('TimeoutException occurred: $e');
          print('Is the backend responding within the timeout period?');
          throw ApiException('API request timed out');
        } else {
          print('Unknown error occurred during API call: $e');
          throw ApiException('Health check failed: $e');
        }
      }
    } on SocketException {
      print('SocketException caught outside inner try-catch');
      print('This might indicate a network issue or port blocking.');
      throw ApiException('No internet connection or server not running');
    } on FormatException {
      print('FormatException caught outside inner try-catch');
      print('The response format might be invalid or unexpected.');
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is TimeoutException) {
        print(
            'TimeoutException: API-Antwort hat zu lange gedauert. Timeout-Werte überprüfen.');
        throw ApiException('API request timed out');
      }
      print('Unknown error caught outside inner try-catch: $e');
      print('This might be an unhandled exception.');
      throw ApiException('Health check failed: $e');
    }
  }

  /// **GET** - Alle Expenses abrufen
  Future<List<Expense>> getAllExpenses() async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Fetching all expenses: ${ApiConfig.expenses}');
      }

      final response = await _client
          .get(
            Uri.parse(ApiConfig.expenses),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          print('❌ Invalid response structure: $responseData');
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        // Backend Response-Struktur: {"success": true, "data": [...], "message": "..."}
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> expensesJson =
              responseData['data'] as List<dynamic>;

          final expenses = expensesJson
              .map((json) => Expense.fromJson(json as Map<String, dynamic>))
              .toList();

          if (ApiConfig.debugMode) {
            print('✅ Loaded ${expenses.length} expenses');
          }

          return expenses;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        throw ApiException('Failed to load expenses', response.statusCode);
      }
    } on SocketException {
      print(
          'SocketException: Backend möglicherweise nicht erreichbar. Ist der Server gestartet?');
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } on TimeoutException {
      print(
          'TimeoutException: API-Antwort hat zu lange gedauert. Timeout-Werte überprüfen.');
      throw ApiException('API request timed out');
    } catch (e) {
      throw ApiException('Failed to load expenses: $e');
    }
  }

  /// **POST** - Neue Expense erstellen
  Future<Expense> createExpense(Expense expense) async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Creating expense: ${expense.title}');
      }

      final response = await _client
          .post(
            Uri.parse(ApiConfig.expenses),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(expense.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          print('❌ Invalid response structure: $responseData');
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (responseData['success'] == true && responseData['data'] != null) {
          final createdExpense =
              Expense.fromJson(responseData['data'] as Map<String, dynamic>);

          if (ApiConfig.debugMode) {
            print('✅ Expense created: ID ${createdExpense.id}');
          }

          return createdExpense;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw ApiException(errorMessage, response.statusCode);
      }
    } on SocketException {
      print(
          'SocketException: Backend möglicherweise nicht erreichbar. Ist der Server gestartet?');
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to create expense: $e');
    }
  }

  /// **PUT** - Expense bearbeiten
  Future<Expense> updateExpense(int id, Expense expense) async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Updating expense ID: $id');
      }

      final response = await _client
          .put(
            Uri.parse(ApiConfig.expenseById(id)),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(expense.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          final updatedExpense =
              Expense.fromJson(responseData['data'] as Map<String, dynamic>);

          if (ApiConfig.debugMode) {
            print('✅ Expense updated: ID ${updatedExpense.id}');
          }

          return updatedExpense;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw ApiException(errorMessage, response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to update expense: $e');
    }
  }

  /// **DELETE** - Expense löschen
  Future<void> deleteExpense(int id) async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Deleting expense ID: $id');
      }

      final response = await _client
          .delete(
            Uri.parse(ApiConfig.expenseById(id)),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        if (ApiConfig.debugMode) {
          print('✅ Expense deleted: ID $id');
        }
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw ApiException(errorMessage, response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to delete expense: $e');
    }
  }

  /// **GET** - Expenses nach Kategorie filtern
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Fetching expenses for category: $category');
      }

      final response = await _client
          .get(
            Uri.parse(ApiConfig.expensesByCategory(category)),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> expensesJson =
              responseData['data'] as List<dynamic>;

          final expenses = expensesJson
              .map((json) => Expense.fromJson(json as Map<String, dynamic>))
              .toList();

          if (ApiConfig.debugMode) {
            print(
                '✅ Loaded ${expenses.length} expenses for category $category');
          }

          return expenses;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        throw ApiException(
            'Failed to load expenses by category', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to load expenses by category: $e');
    }
  }

  /// **GET** - Statistiken abrufen
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Fetching statistics: ${ApiConfig.expenseStats()}');
      }

      final response = await _client
          .get(
            Uri.parse(ApiConfig.expenseStats()),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (responseData['success'] == true && responseData['data'] != null) {
          if (ApiConfig.debugMode) {
            print('✅ Statistics loaded successfully');
          }

          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        throw ApiException('Failed to load statistics', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to load statistics: $e');
    }
  }

  /// **GET** - Quartals-Statistiken abrufen
  Future<QuarterlyStats> getQuarterlyStatistics({int? year}) async {
    try {
      if (ApiConfig.debugMode) {
        print(
            '🔍 Fetching quarterly statistics for year: ${year ?? "current"}');
      }

      final response = await _client
          .get(
            Uri.parse(ApiConfig.quarterlyStats(year: year)),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (responseData['success'] == true && responseData['data'] != null) {
          final quarterlyStats = QuarterlyStats.fromJson(
              responseData['data'] as Map<String, dynamic>);

          if (ApiConfig.debugMode) {
            print(
                '✅ Loaded quarterly statistics for year ${quarterlyStats.year}');
          }

          return quarterlyStats;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        throw ApiException(
            'Failed to load quarterly statistics', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to load quarterly statistics: $e');
    }
  }

  /// **GET** - Jahres-Statistiken abrufen
  Future<YearlyStats> getYearlyStatistics() async {
    try {
      if (ApiConfig.debugMode) {
        print('🔍 Fetching yearly statistics');
      }

      final response = await _client
          .get(
            Uri.parse(ApiConfig.yearlyStats()),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          print('❌ Invalid response structure: $responseData');
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (!responseData.containsKey('success') ||
            responseData['success'] != true) {
          throw ApiException(
              'Invalid response structure: success flag missing or false');
        }
        if (responseData['success'] == true && responseData['data'] != null) {
          final yearlyStats = YearlyStats.fromJson(
              responseData['data'] as Map<String, dynamic>);

          if (ApiConfig.debugMode) {
            print(
                '✅ Loaded yearly statistics for ${yearlyStats.totalYears} years');
          }

          return yearlyStats;
        } else {
          throw ApiException('Invalid response structure');
        }
      } else {
        throw ApiException(
            'Failed to load yearly statistics', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Failed to load yearly statistics: $e');
    }
  }

  /// Cleanup-Methode
  void dispose() {
    _client.close();
  }
}
