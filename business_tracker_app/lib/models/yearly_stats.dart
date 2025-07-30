/// Model für Jahres-Statistiken
class YearlyStats {
  final List<YearData> years;
  final int totalYears;
  final double grandTotal;
  final double averagePerYear;

  const YearlyStats({
    required this.years,
    required this.totalYears,
    required this.grandTotal,
    required this.averagePerYear,
  });

  factory YearlyStats.fromJson(Map<String, dynamic> json) {
    return YearlyStats(
      years: (json['years'] as List<dynamic>)
          .map(
              (yearJson) => YearData.fromJson(yearJson as Map<String, dynamic>))
          .toList(),
      totalYears: json['totalYears'] as int,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      averagePerYear: (json['averagePerYear'] as num).toDouble(),
    );
  }

  /// Neuestes Jahr
  YearData? get latestYear => years.isNotEmpty ? years.last : null;

  /// Jahr mit höchsten Ausgaben
  YearData? get highestExpenseYear {
    if (years.isEmpty) return null;
    return years.reduce((a, b) => a.totalAmount > b.totalAmount ? a : b);
  }

  /// Jahr mit niedrigsten Ausgaben
  YearData? get lowestExpenseYear {
    if (years.isEmpty) return null;
    return years.reduce((a, b) => a.totalAmount < b.totalAmount ? a : b);
  }
}

/// Model für ein einzelnes Jahr
class YearData {
  final int year;
  final double totalAmount;
  final int expenseCount;
  final double? previousYearTotal;
  final double? percentageChange;
  final Map<String, double> categoryBreakdown;
  final double averagePerMonth;

  const YearData({
    required this.year,
    required this.totalAmount,
    required this.expenseCount,
    this.previousYearTotal,
    this.percentageChange,
    required this.categoryBreakdown,
    required this.averagePerMonth,
  });

  factory YearData.fromJson(Map<String, dynamic> json) {
    return YearData(
      year: json['year'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
      previousYearTotal: json['previousYearTotal'] != null
          ? (json['previousYearTotal'] as num).toDouble()
          : null,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
      categoryBreakdown: Map<String, double>.from(
        (json['categoryBreakdown'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      averagePerMonth: (json['averagePerMonth'] as num).toDouble(),
    );
  }

  /// Formatierte Anzeige der prozentualen Veränderung
  String get formattedPercentageChange {
    if (percentageChange == null) return 'N/A';

    final prefix = percentageChange! >= 0 ? '+' : '';
    return '$prefix${percentageChange!.toStringAsFixed(1)}%';
  }

  /// Trend-Icon basierend auf Veränderung
  String get trendIcon {
    if (percentageChange == null) return '📊';
    if (percentageChange! > 0) return '📈';
    if (percentageChange! < 0) return '📉';
    return '➡️';
  }

  /// Top-Kategorie (höchste Ausgaben)
  MapEntry<String, double>? get topCategory {
    if (categoryBreakdown.isEmpty) return null;
    return categoryBreakdown.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
  }

  /// Durchschnitt pro Quartal
  double get averagePerQuarter => totalAmount / 4;
}
