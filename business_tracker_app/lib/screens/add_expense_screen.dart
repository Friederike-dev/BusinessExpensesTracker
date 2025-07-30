import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; // Für Edit-Mode

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Travel';

  // Ist Edit-Mode wenn expense übergeben wurde
  bool get isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();
    // Wenn Edit-Mode: Felder mit vorhandenen Daten füllen
    if (isEditMode) {
      final expense = widget.expense!;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description ?? '';
      _selectedDate = expense.expenseDate;
      _selectedCategory = expense.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseCategory.defaultCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: Text(
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  hintText: 'e.g. Business Lunch',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (€)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description Field (optional)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Additional notes...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              Spacer(),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Save Expense',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);

      // Zeige Loading-Indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(isEditMode ? 'Updating expense...' : 'Saving expense...'),
            ],
          ),
        ),
      );

      bool success;

      if (isEditMode) {
        // **Edit Mode: Update existing expense**
        final updatedExpense = widget.expense!.copyWith(
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          expenseDate: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );
        success = await expenseProvider.updateExpense(
            updatedExpense.id!, updatedExpense);
      } else {
        // **Create Mode: Create new expense**
        final expense = Expense(
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          expenseDate: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );
        success = await expenseProvider.createExpense(expense);
      }

      // Schließe Loading-Dialog
      Navigator.pop(context);

      if (success) {
        // Zurück zur Dashboard
        Navigator.pop(context);

        // Erfolgs-Nachricht
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? '✅ Expense updated successfully!'
                : '✅ Expense saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Fehler-Nachricht
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? '❌ Failed to update expense: ${expenseProvider.errorMessage}'
                : '❌ Failed to save expense: ${expenseProvider.errorMessage}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveExpense,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
