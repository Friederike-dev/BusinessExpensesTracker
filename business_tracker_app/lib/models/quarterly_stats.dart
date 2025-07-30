/// Model für Quartals-Statistiken
class QuarterlyStats {
  final int year;
  final List<QuarterData> quarters;
  final double yearTotal;
  final double averagePerQuarter;

  const QuarterlyStats({
    required this.year,
    required this.quarters,
    required this.yearTotal,
    required this.averagePerQuarter,
  });

  factory QuarterlyStats.fromJson(Map<String, dynamic> json) {
    return QuarterlyStats(
      year: json['year'] as int,
      quarters: (json['quarters'] as List<dynamic>)
          .map((quarterJson) =>
              QuarterData.fromJson(quarterJson as Map<String, dynamic>))
          .toList(),
      yearTotal: (json['yearTotal'] as num).toDouble(),
      averagePerQuarter: (json['averagePerQuarter'] as num).toDouble(),
    );
  }
}

/// Model für ein einzelnes Quartal
class QuarterData {
  final int quarter;
  final int year;
  final double totalAmount;
  final int expenseCount;
  final double? previousQuarterTotal;
  final double? percentageChange;
  final Map<String, double> categoryBreakdown;
  final DateTime startDate;
  final DateTime endDate;

  const QuarterData({
    required this.quarter,
    required this.year,
    required this.totalAmount,
    required this.expenseCount,
    this.previousQuarterTotal,
    this.percentageChange,
    required this.categoryBreakdown,
    required this.startDate,
    required this.endDate,
  });

  factory QuarterData.fromJson(Map<String, dynamic> json) {
    return QuarterData(
      quarter: json['quarter'] as int,
      year: json['year'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
      previousQuarterTotal: json['previousQuarterTotal'] != null
          ? (json['previousQuarterTotal'] as num).toDouble()
          : null,
      percentageChange: json['percentageChange'] != null
          ? (json['percentageChange'] as num).toDouble()
          : null,
      categoryBreakdown: Map<String, double>.from(
        (json['categoryBreakdown'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
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

  /// Quartal als String (Q1, Q2, Q3, Q4)
  String get quarterName => 'Q$quarter';

  /// Vollständiger Name (Q1 2025)
  String get fullName => '$quarterName $year';
}
