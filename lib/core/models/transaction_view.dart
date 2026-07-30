import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';

class TransactionView {
  final String id;
  final String title;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double amount;
  final bool isIncome;
  final DateTime date;

  const TransactionView({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  factory TransactionView.fromExpense(ExpenseModel e) => TransactionView(
        id: e.id,
        title: e.productName,
        categoryName: e.category.name,
        categoryIcon: e.category.icon,
        categoryColor: e.category.color,
        amount: e.amount,
        isIncome: false,
        date: e.date,
      );

  factory TransactionView.fromIncome(IncomeModel i) => TransactionView(
        id: i.id,
        title: i.productName,
        categoryName: i.category.name,
        categoryIcon: i.category.icon,
        categoryColor: i.category.color,
        amount: i.amount,
        isIncome: true,
        date: i.date,
      );
}
