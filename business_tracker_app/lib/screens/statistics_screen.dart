import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/quarterly_stats.dart';
import '../models/yearly_stats.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load statistics when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      provider.loadQuarterlyStatistics();
      provider.loadYearlyStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Quarterly', icon: Icon(Icons.calendar_view_month)),
            Tab(text: 'Yearly', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuarterlyTab(),
          _buildYearlyTab(),
        ],
      ),
    );
  }

  Widget _buildQuarterlyTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingStats) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.quarterlyStats == null) {
          return const Center(
            child: Text(
              'No quarterly data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildQuarterlyStatsContent(provider.quarterlyStats!);
      },
    );
  }

  Widget _buildYearlyTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingStats) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.yearlyStats == null) {
          return const Center(
            child: Text(
              'No yearly data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildYearlyStatsContent(provider.yearlyStats!);
      },
    );
  }

  Widget _buildQuarterlyStatsContent(QuarterlyStats stats) {
    // Get current and previous quarter data
    final currentQuarter =
        stats.quarters.isNotEmpty ? stats.quarters.last : null;
    final previousQuarter = stats.quarters.length > 1
        ? stats.quarters[stats.quarters.length - 2]
        : null;

    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        await provider.loadQuarterlyStatistics();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Section
            if (currentQuarter != null)
              _buildStatsCard(
                title: 'Current Quarter',
                value: '€${currentQuarter.totalAmount.toStringAsFixed(2)}',
                subtitle: 'Q${currentQuarter.quarter} ${currentQuarter.year}',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
            const SizedBox(height: 16),
            if (previousQuarter != null)
              _buildStatsCard(
                title: 'Previous Quarter',
                value: '€${previousQuarter.totalAmount.toStringAsFixed(2)}',
                subtitle: 'Q${previousQuarter.quarter} ${previousQuarter.year}',
                icon: Icons.history,
                color: Colors.orange,
              ),
            const SizedBox(height: 16),
            if (currentQuarter?.percentageChange != null)
              _buildPercentageChangeCard(
                title: 'Quarter-over-Quarter Change',
                percentage: currentQuarter!.percentageChange!,
                isPositive: currentQuarter.percentageChange! > 0,
              ),
            const SizedBox(height: 16),
            _buildStatsCard(
              title: 'Year Total',
              value: '€${stats.yearTotal.toStringAsFixed(2)}',
              subtitle: '${stats.year}',
              icon: Icons.calendar_today,
              color: Colors.green,
            ),

            // Quarterly Breakdown Section
            const SizedBox(height: 32),
            const Text(
              'Quarterly Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Quarterly breakdown list
            ...stats.quarters
                .map((quarter) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildQuarterBreakdownCard(
                        'Q${quarter.quarter}',
                        quarter.totalAmount,
                        quarter.expenseCount,
                        quarter.percentageChange,
                      ),
                    ))
                .toList(),

            // Bottom padding for better scrolling experience
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyStatsContent(YearlyStats stats) {
    // Get current and previous year data
    final currentYear = stats.years.isNotEmpty ? stats.years.last : null;
    final previousYear =
        stats.years.length > 1 ? stats.years[stats.years.length - 2] : null;

    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        await provider.loadYearlyStatistics();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Section
            if (currentYear != null)
              _buildStatsCard(
                title: 'Current Year',
                value: '€${currentYear.totalAmount.toStringAsFixed(2)}',
                subtitle: '${currentYear.year}',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
            const SizedBox(height: 16),
            if (previousYear != null)
              _buildStatsCard(
                title: 'Previous Year',
                value: '€${previousYear.totalAmount.toStringAsFixed(2)}',
                subtitle: '${previousYear.year}',
                icon: Icons.history,
                color: Colors.purple,
              ),
            const SizedBox(height: 16),
            if (currentYear?.percentageChange != null)
              _buildPercentageChangeCard(
                title: 'Year-over-Year Change',
                percentage: currentYear!.percentageChange!,
                isPositive: currentYear.percentageChange! > 0,
              ),
            const SizedBox(height: 16),
            _buildStatsCard(
              title: 'Grand Total',
              value: '€${stats.grandTotal.toStringAsFixed(2)}',
              subtitle: 'All ${stats.totalYears} years',
              icon: Icons.account_balance,
              color: Colors.blue,
            ),

            // Yearly Breakdown Section
            const SizedBox(height: 32),
            const Text(
              'Yearly Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Yearly breakdown list
            ...stats.years
                .map((year) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildYearBreakdownCard(
                        year.year.toString(),
                        year.totalAmount,
                        year.expenseCount,
                        year.percentageChange,
                      ),
                    ))
                .toList(),

            // Bottom padding for better scrolling experience
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageChangeCard({
    required String title,
    required double percentage,
    required bool isPositive,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (isPositive ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.red : Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPositive ? 'Increase' : 'Decrease',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterBreakdownCard(String quarter, double total,
      int expenseCount, double? percentageChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            quarter,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Quarter $quarter'),
        subtitle: Text('$expenseCount expenses'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (percentageChange != null)
              Text(
                '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: percentageChange >= 0 ? Colors.red : Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearBreakdownCard(
      String year, double total, int expenseCount, double? percentageChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            year,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text('Year $year'),
        subtitle: Text('$expenseCount expenses'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (percentageChange != null)
              Text(
                '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: percentageChange >= 0 ? Colors.red : Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
