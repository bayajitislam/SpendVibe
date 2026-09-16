import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/i_budget_repository.dart';
import '../../data/repositories/budget_repository_impl.dart';

// Budget Repository Provider
final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db);
});

// Watch current month's budget
final currentMonthBudgetStreamProvider = StreamProvider<BudgetEntity?>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final now = DateTime.now();
  return repository.watchMonthlyBudget(now.month, now.year);
});

// Active Budget with Real-time Spent Amount attached
final activeBudgetProvider = Provider<BudgetEntity?>((ref) {
  final budgetAsync = ref.watch(currentMonthBudgetStreamProvider);
  final summary = ref.watch(monthlySummaryProvider);

  return budgetAsync.when(
    data: (budget) {
      if (budget == null) return null;
      return budget.copyWith(spentAmount: summary.totalExpense);
    },
    loading: () => null,
    error: (err, stack) => null,
  );
});
