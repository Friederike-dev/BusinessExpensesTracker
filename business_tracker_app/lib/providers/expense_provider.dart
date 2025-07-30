import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/quarterly_stats.dart';
import '../models/yearly_stats.dart';
import '../services/expense_api_service.dart';

enum LoadingState { idle, loading, success, error }

class ExpenseProvider with ChangeNotifier {
  final ExpenseApiService _apiService = ExpenseApiService();

  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = ExpenseCategory.defaultCategories;
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;

  // Statistics
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get expensesByCategory {
    Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  // **Statistics Properties**
  QuarterlyStats? _quarterlyStats;
  YearlyStats? _yearlyStats;
  LoadingState _statsLoadingState = LoadingState.idle;

  // **Statistics Getters**
  QuarterlyStats? get quarterlyStats => _quarterlyStats;
  YearlyStats? get yearlyStats => _yearlyStats;
  LoadingState get statsLoadingState => _statsLoadingState;
  bool get isLoadingStats => _statsLoadingState == LoadingState.loading;

  // **API Methods** - Integration mit Backend

  /// **Lade alle Expenses von der API**
  Future<void> loadExpenses() async {
    try {
      _setLoadingState(LoadingState.loading);

      final expenses = await _apiService.getAllExpenses();
      _expenses = expenses;

      _setLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Loaded ${expenses.length} expenses from API');
      }
    } catch (e) {
      _setError('Failed to load expenses: $e');
      if (kDebugMode) {
        print('❌ Error loading expenses: $e');
      }
    }
  }

  /// **Erstelle neue Expense**
  Future<bool> createExpense(Expense expense) async {
    try {
      _setLoadingState(LoadingState.loading);

      final createdExpense = await _apiService.createExpense(expense);
      _expenses.insert(0, createdExpense); // Neueste zuerst

      _setLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Created expense: ${createdExpense.title}');
      }
      return true;
    } catch (e) {
      _setError('Failed to create expense: $e');
      if (kDebugMode) {
        print('❌ Error creating expense: $e');
      }
      return false;
    }
  }

  /// **Update bestehende Expense**
  Future<bool> updateExpense(int id, Expense expense) async {
    try {
      _setLoadingState(LoadingState.loading);

      final updatedExpense = await _apiService.updateExpense(id, expense);

      // Ersetze in lokaler Liste
      final index = _expenses.indexWhere((exp) => exp.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }

      _setLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Updated expense: ${updatedExpense.title}');
      }
      return true;
    } catch (e) {
      _setError('Failed to update expense: $e');
      if (kDebugMode) {
        print('❌ Error updating expense: $e');
      }
      return false;
    }
  }

  /// **Lösche Expense**
  Future<bool> deleteExpense(int id) async {
    try {
      _setLoadingState(LoadingState.loading);

      await _apiService.deleteExpense(id);

      // Entferne aus lokaler Liste
      _expenses.removeWhere((expense) => expense.id == id);

      _setLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Deleted expense with ID: $id');
      }
      return true;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      if (kDebugMode) {
        print('❌ Error deleting expense: $e');
      }
      return false;
    }
  }

  /// **Lade Expenses nach Kategorie**
  Future<List<Expense>> loadExpensesByCategory(String category) async {
    try {
      final expenses = await _apiService.getExpensesByCategory(category);

      if (kDebugMode) {
        print('✅ Loaded ${expenses.length} expenses for category: $category');
      }

      return expenses;
    } catch (e) {
      _setError('Failed to load expenses by category: $e');
      if (kDebugMode) {
        print('❌ Error loading expenses by category: $e');
      }
      return [];
    }
  }

  /// **Test API-Verbindung**
  Future<bool> testConnection() async {
    try {
      await _apiService.healthCheck();
      if (kDebugMode) {
        print('✅ API connection successful');
      }
      return true;
    } catch (e) {
      _setError('API connection failed: $e');
      if (kDebugMode) {
        print('❌ API connection failed: $e');
      }
      return false;
    }
  }

  /// **Lade Quartals-Statistiken**
  Future<void> loadQuarterlyStatistics({int? year}) async {
    try {
      _setStatsLoadingState(LoadingState.loading);

      final stats = await _apiService.getQuarterlyStatistics(year: year);
      _quarterlyStats = stats;

      _setStatsLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Loaded quarterly statistics for year ${stats.year}');
      }
    } catch (e) {
      _setError('Failed to load quarterly statistics: $e');
      if (kDebugMode) {
        print('❌ Error loading quarterly statistics: $e');
      }
    }
  }

  /// **Lade Jahres-Statistiken**
  Future<void> loadYearlyStatistics() async {
    try {
      _setStatsLoadingState(LoadingState.loading);

      final stats = await _apiService.getYearlyStatistics();
      _yearlyStats = stats;

      _setStatsLoadingState(LoadingState.success);

      if (kDebugMode) {
        print('✅ Loaded yearly statistics for ${stats.totalYears} years');
      }
    } catch (e) {
      _setError('Failed to load yearly statistics: $e');
      if (kDebugMode) {
        print('❌ Error loading yearly statistics: $e');
      }
    }
  }

  /// **Lade alle Statistiken**
  Future<void> loadAllStatistics({int? year}) async {
    await Future.wait([
      loadQuarterlyStatistics(year: year),
      loadYearlyStatistics(),
    ]);
  }

  // **Local Methods** - Für Offline-Funktionalität

  /// Lokale Expense hinzufügen (ohne API)
  void addExpenseLocally(Expense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  /// Lokale Expense entfernen (ohne API)
  void removeExpenseLocally(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }

  // Utility Methods
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getRecentExpenses({int limit = 5}) {
    return _expenses.take(limit).toList();
  }

  /// Fehler löschen
  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.idle;
    }
    notifyListeners();
  }

  // **Private Helper Methods**
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    if (state != LoadingState.error) {
      _errorMessage = null; // Clear error when not in error state
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _loadingState = LoadingState.error;
    notifyListeners();
  }

  void _setStatsLoadingState(LoadingState state) {
    _statsLoadingState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
