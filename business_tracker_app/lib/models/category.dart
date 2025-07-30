import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(name: 'Travel', icon: Icons.flight, color: Colors.blue),
    ExpenseCategory(name: 'Office', icon: Icons.work, color: Colors.green),
    ExpenseCategory(
        name: 'Marketing', icon: Icons.campaign, color: Colors.orange),
    ExpenseCategory(name: 'Food', icon: Icons.restaurant, color: Colors.red),
    ExpenseCategory(
        name: 'Transport', icon: Icons.directions_car, color: Colors.purple),
    ExpenseCategory(
        name: 'Software',
        icon: Icons.computer,
        color: Colors.indigo), // Hinzugefügt
    ExpenseCategory(name: 'Equipment', icon: Icons.devices, color: Colors.teal),
    ExpenseCategory(name: 'Other', icon: Icons.more_horiz, color: Colors.grey),
  ];
}
