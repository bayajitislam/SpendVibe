import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors (Fintech modern)
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Financial Semantics
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFEF4444); // Coral Crimson
  static const Color expenseLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B); // Amber warning for budgets
  static const Color warningLight = Color(0xFFFEF3C7);

  // Dark Theme Background & Surfaces (Obsidian Slate)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  // Light Theme Background & Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Category Accent Colors
  static const List<Color> categoryPalette = [
    Color(0xFFF59E0B), // Food & Dining - Amber
    Color(0xFF3B82F6), // Transport - Blue
    Color(0xFFEC4899), // Shopping - Pink
    Color(0xFF8B5CF6), // Bills & Utilities - Purple
    Color(0xFF10B981), // Entertainment - Emerald
    Color(0xFF14B8A6), // Health & Fitness - Teal
    Color(0xFFF97316), // Education - Orange
    Color(0xFF06B6D4), // Travel - Cyan
    Color(0xFF6366F1), // Salary - Indigo
    Color(0xFF84CC16), // Freelance / Side Gig - Lime
    Color(0xFF64748B), // Others - Slate
  ];
}
