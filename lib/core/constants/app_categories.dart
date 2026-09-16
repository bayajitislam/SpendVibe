import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class DefaultCategory {
  final String id;
  final String name;
  final IconData icon;
  final int colorValue;
  final TransactionType type;

  const DefaultCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
  });

  int get iconCodePoint => icon.codePoint;
}

class AppCategories {
  AppCategories._();

  static const List<DefaultCategory> defaultExpenseCategories = [
    DefaultCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      colorValue: 0xFFF59E0B, // Amber
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      colorValue: 0xFF3B82F6, // Blue
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      colorValue: 0xFFEC4899, // Pink
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      colorValue: 0xFF8B5CF6, // Purple
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      colorValue: 0xFF10B981, // Emerald
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.local_hospital_rounded,
      colorValue: 0xFF14B8A6, // Teal
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      colorValue: 0xFFF97316, // Orange
      type: TransactionType.expense,
    ),
    DefaultCategory(
      id: 'other_expense',
      name: 'Other Expense',
      icon: Icons.more_horiz_rounded,
      colorValue: 0xFF64748B, // Slate
      type: TransactionType.expense,
    ),
  ];

  static const List<DefaultCategory> defaultIncomeCategories = [
    DefaultCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      colorValue: 0xFF10B981, // Emerald
      type: TransactionType.income,
    ),
    DefaultCategory(
      id: 'freelance',
      name: 'Freelance & Gigs',
      icon: Icons.laptop_mac_rounded,
      colorValue: 0xFF6366F1, // Indigo
      type: TransactionType.income,
    ),
    DefaultCategory(
      id: 'investment',
      name: 'Investments',
      icon: Icons.trending_up_rounded,
      colorValue: 0xFF06B6D4, // Cyan
      type: TransactionType.income,
    ),
    DefaultCategory(
      id: 'gift',
      name: 'Gifts & Bonus',
      icon: Icons.card_giftcard_rounded,
      colorValue: 0xFFEC4899, // Pink
      type: TransactionType.income,
    ),
    DefaultCategory(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.attach_money_rounded,
      colorValue: 0xFF84CC16, // Lime
      type: TransactionType.income,
    ),
  ];

  static List<DefaultCategory> get allCategories => [
    ...defaultExpenseCategories,
    ...defaultIncomeCategories,
  ];

  static DefaultCategory getCategoryById(String id) {
    return allCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultExpenseCategories.last,
    );
  }

  static IconData getCategoryIcon(String id) {
    return getCategoryById(id).icon;
  }
}
