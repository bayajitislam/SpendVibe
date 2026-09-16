import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../data/repositories/transaction_repository_impl.dart';

// Database Singleton Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Transaction Repository Provider
final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db);
});

// Watch all transactions stream
final allTransactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchAllTransactions();
});

// Watch current month transactions stream
final currentMonthTransactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final start = DateHelpers.startOfMonth(now);
  final end = DateHelpers.endOfMonth(now);
  return repository.watchTransactionsBetween(start, end);
});

// Watch categories stream
final categoriesStreamProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchCategories();
});

// Financial Summary Data Class
class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const FinancialSummary({
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.netBalance = 0.0,
  });
}

// Current Month Summary Provider (Reactive)
final monthlySummaryProvider = Provider<FinancialSummary>((ref) {
  final transactionsAsync = ref.watch(currentMonthTransactionsStreamProvider);

  return transactionsAsync.when(
    data: (transactions) {
      double income = 0.0;
      double expense = 0.0;

      for (final t in transactions) {
        if (t.type.name == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      return FinancialSummary(
        totalIncome: income,
        totalExpense: expense,
        netBalance: income - expense,
      );
    },
    loading: () => const FinancialSummary(),
    error: (err, stack) => const FinancialSummary(),
  );
});
