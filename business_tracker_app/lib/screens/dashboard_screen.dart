import 'package:flutter/material.dart'; // Flutter UI-Komponenten
import 'package:provider/provider.dart'; // State Management
import '../providers/expense_provider.dart'; // Unsere Datenverwaltung
import '../models/expense.dart'; // Expense-Model
import '../models/category.dart'; // Category-Model
import 'add_expense_screen.dart'; // Add-Expense-Screen
import 'statistics_screen.dart'; // Statistics-Screen

// Kann sich neu zeichnen wenn sich Daten ändern
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Lade Expenses beim Start der App
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  Future<void> _loadExpenses() async {
    // gib mir den ExpenseProvider aus main.dart
    // anders als in java braucht in Dart der Typ nicht explizit angegeben werden
    // Dart erkennt den Typ durch ExpenseProvider
    // bei komplexen Typen wie Listen oder Maps ist die explizite Angabe des Typs aber wieder nötig
    final expenseProvider = context.read<
        ExpenseProvider>(); // damit context schon verfügbar ist wird oben loadExpenses in WidgetsBinding mit addPostFrameCallback aufgerufen

    // Teste zuerst die API-Verbindung
    final connectionSuccess = await expenseProvider.testConnection();

    if (connectionSuccess) {
      // API ist erreichbar → Lade echte Daten
      await expenseProvider.loadExpenses();
    } else {
      // API nicht erreichbar → Zeige Fehler
      _showConnectionError();
    }
  }

  void _showConnectionError() {
    final expenseProvider = context.read<ExpenseProvider>();
    final errorMessage = expenseProvider.errorMessage ?? 'Unknown error';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('❌ Backend not reachable'),
            Text('Details: $errorMessage', style: TextStyle(fontSize: 12)),
            Text('Make sure Spring Boot is running on localhost:8080',
                style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _loadExpenses,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('BusinessTracker Pro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(),
                ),
              );
            },
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    '€${expenseProvider.totalExpenses.toStringAsFixed(2)}',
                    Icons.euro,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Number of Expenses',
                    '${expenseProvider.expenses.length}',
                    Icons.receipt_long,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsScreen(),
                        ),
                      );
                    },
                    child: _buildSummaryCard(
                      'Analytics',
                      _getTopCategory(expenseProvider),
                      Icons.analytics,
                      Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Recent Expenses Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Connection Status
                    Icon(
                      expenseProvider.hasError ? Icons.error : Icons.cloud_done,
                      color:
                          expenseProvider.hasError ? Colors.red : Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    // Refresh Button
                    IconButton(
                      icon: expenseProvider.isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh),
                      onPressed:
                          expenseProvider.isLoading ? null : _loadExpenses,
                      tooltip: 'Refresh data',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Expense List
            Expanded(
              child: expenseProvider.expenses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: expenseProvider.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseProvider.expenses[index];
                        return _buildExpenseCard(expense, context, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense, BuildContext context, int index) {
    final category = ExpenseCategory.defaultCategories.firstWhere(
      (cat) => cat.name == expense.category,
      orElse: () => ExpenseCategory.defaultCategories.first, // Fallback
    );

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key('expense_${expense.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          color: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmDialog(expense);
        },
        onDismissed: (direction) {
          _deleteExpense(expense.id!);
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.2),
            child: Icon(category.icon, color: category.color),
          ),
          title: Text(expense.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${expense.category} • ${expense.expenseDate.day}.${expense.expenseDate.month}.${expense.expenseDate.year}',
              ),
              if (expense.description != null)
                Text(
                  expense.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editExpense(expense);
                  } else if (value == 'delete') {
                    _deleteExpense(expense.id!);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            _showExpenseDetails(expense);
          },
        ),
      ),
    );
  }

  // **Delete Confirmation Dialog**
  Future<bool?> _showDeleteConfirmDialog(Expense expense) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // **Delete Expense**
  Future<void> _deleteExpense(int id) async {
    final expenseProvider = context.read<ExpenseProvider>();

    final success = await expenseProvider.deleteExpense(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Expense deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to delete expense'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // **Edit Expense**
  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    ).then((_) {
      // Refresh nach Edit
      _loadExpenses();
    });
  }

  // **Show Expense Details**
  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(expense.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: €${expense.amount.toStringAsFixed(2)}'),
              Text('Category: ${expense.category}'),
              Text(
                  'Date: ${expense.expenseDate.day}.${expense.expenseDate.month}.${expense.expenseDate.year}'),
              if (expense.description != null) ...[
                SizedBox(height: 8),
                Text('Description:'),
                Text(expense.description!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editExpense(expense);
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getTopCategory(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return 'No data';
    }

    final categoryTotals = provider.expensesByCategory;
    if (categoryTotals.isEmpty) {
      return 'No data';
    }

    // Find the category with the highest total
    var topCategory = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return topCategory.key;
  }
}
