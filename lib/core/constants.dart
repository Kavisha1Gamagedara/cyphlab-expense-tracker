import 'package:flutter/material.dart';

/// App-wide constants, strings, colors, and static configuration.
class AppConstants {
  static const String appName = 'Trace Expense Tracker';
  static const String appLogo = 'assets/images/logo.png';
  static const String expensesCollection = 'expenses';
  static const String biometricLockKey = 'biometric_lock_enabled';
  static String currencySymbol = '\$';
  static String get defaultCurrency => currencySymbol;

  // Category names
  static const String categoryFood = 'Food & Dining';
  static const String categoryTransport = 'Transport';
  static const String categoryShopping = 'Shopping';
  static const String categoryEntertainment = 'Entertainment';
  static const String categoryBills = 'Bills & Utilities';
  static const String categoryHealth = 'Health & Medical';
  static const String categoryEducation = 'Education';
  static const String categoryOther = 'Other';

  static const List<String> categories = [
    categoryFood,
    categoryTransport,
    categoryShopping,
    categoryEntertainment,
    categoryBills,
    categoryHealth,
    categoryEducation,
    categoryOther,
  ];

  /// Get corresponding icon for a category
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case categoryFood:
        return Icons.restaurant_rounded;
      case categoryTransport:
        return Icons.directions_car_rounded;
      case categoryShopping:
        return Icons.shopping_bag_rounded;
      case categoryEntertainment:
        return Icons.movie_filter_rounded;
      case categoryBills:
        return Icons.receipt_long_rounded;
      case categoryHealth:
        return Icons.favorite_rounded;
      case categoryEducation:
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get corresponding accent color for a category
  static Color getCategoryColor(String category) {
    switch (category) {
      case categoryFood:
        return const Color(0xFFF97316); // Amber Orange
      case categoryTransport:
        return const Color(0xFF0EA5E9); // Sky Blue
      case categoryShopping:
        return const Color(0xFFEC4899); // Pink
      case categoryEntertainment:
        return const Color(0xFF8B5CF6); // Violet
      case categoryBills:
        return const Color(0xFFEF4444); // Crimson Red
      case categoryHealth:
        return const Color(0xFF10B981); // Emerald Green
      case categoryEducation:
        return const Color(0xFF6366F1); // Indigo
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}

/// Curated modern color palette
class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color accent = Color(0xFF06B6D4); // Cyan 500

  // Neutral - Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Neutral - Dark Theme
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
