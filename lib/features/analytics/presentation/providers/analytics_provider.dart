import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

enum AnalyticsTimeframe { week, month, year }

class CategorySpending {
  final String categoryId;
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  const CategorySpending({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class DaySpending {
  final String dayLabel;
  final double amount;
  final DateTime date;

  const DaySpending({
    required this.dayLabel,
    required this.amount,
    required this.date,
  });
}

class AnalyticsState {
  final AnalyticsTimeframe timeframe;
  final double totalSpent;
  final List<CategorySpending> categoryBreakdown;
  final List<DaySpending> dailyTrend;

  const AnalyticsState({
    this.timeframe = AnalyticsTimeframe.month,
    this.totalSpent = 0.0,
    this.categoryBreakdown = const [],
    this.dailyTrend = const [],
  });

  AnalyticsState copyWith({
    AnalyticsTimeframe? timeframe,
    double? totalSpent,
    List<CategorySpending>? categoryBreakdown,
    List<DaySpending>? dailyTrend,
  }) {
    return AnalyticsState(
      timeframe: timeframe ?? this.timeframe,
      totalSpent: totalSpent ?? this.totalSpent,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      dailyTrend: dailyTrend ?? this.dailyTrend,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    final transactionsAsync = ref.watch(allTransactionsStreamProvider);
    final transactions = transactionsAsync.asData?.value ?? [];
    return _compute(stateOrNull?.timeframe ?? AnalyticsTimeframe.month, transactions);
  }

  void setTimeframe(AnalyticsTimeframe timeframe) {
    final transactionsAsync = ref.read(allTransactionsStreamProvider);
    final transactions = transactionsAsync.asData?.value ?? [];
    state = _compute(timeframe, transactions);
  }

  AnalyticsState _compute(AnalyticsTimeframe timeframe, List<TransactionEntity> transactions) {
    final now = DateTime.now();
    DateTime filterStart;

    switch (timeframe) {
      case AnalyticsTimeframe.week:
        filterStart = DateHelpers.startOfWeek(now);
      case AnalyticsTimeframe.month:
        filterStart = DateHelpers.startOfMonth(now);
      case AnalyticsTimeframe.year:
        filterStart = DateTime(now.year, 1, 1);
    }

    final filteredExpenses = transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.date.isAfter(filterStart.subtract(const Duration(seconds: 1)));
    }).toList();

    final totalSpent = filteredExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);

    final Map<String, double> catTotals = {};
    for (final t in filteredExpenses) {
      catTotals[t.categoryId] = (catTotals[t.categoryId] ?? 0.0) + t.amount;
    }

    final List<CategorySpending> breakdown = [];
    catTotals.forEach((catId, amount) {
      final defaultCat = AppCategories.getCategoryById(catId);
      final percentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;
      breakdown.add(
        CategorySpending(
          categoryId: catId,
          name: defaultCat.name,
          amount: amount,
          percentage: percentage,
          color: Color(defaultCat.colorValue),
          icon: defaultCat.icon,
        ),
      );
    });

    breakdown.sort((a, b) => b.amount.compareTo(a.amount));

    final List<DaySpending> trend = [];
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayExpenses = transactions.where((t) {
        return t.type == TransactionType.expense &&
            t.date.year == targetDate.year &&
            t.date.month == targetDate.month &&
            t.date.day == targetDate.day;
      });
      final dayTotal = dayExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);
      trend.add(
        DaySpending(
          dayLabel: DateHelpers.formatDayOfWeek(targetDate),
          amount: dayTotal,
          date: targetDate,
        ),
      );
    }

    return AnalyticsState(
      timeframe: timeframe,
      totalSpent: totalSpent,
      categoryBreakdown: breakdown,
      dailyTrend: trend,
    );
  }
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);
