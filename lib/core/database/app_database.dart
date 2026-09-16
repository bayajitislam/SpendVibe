import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/budgets_table.dart';
import '../constants/app_categories.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TransactionsTable, CategoriesTable, BudgetsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'spend_vibe_db'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        // Seed default categories
        for (final cat in AppCategories.allCategories) {
          await into(categoriesTable).insert(
            CategoriesTableCompanion.insert(
              id: cat.id,
              name: cat.name,
              iconCodePoint: cat.iconCodePoint,
              colorValue: cat.colorValue,
              type: cat.type.name,
            ),
          );
        }
      },
    );
  }

  // --- Transactions ---
  Stream<List<TransactionsTableData>> watchAllTransactions() {
    return (select(transactionsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<TransactionsTableData>> watchTransactionsBetween(DateTime start, DateTime end) {
    return (select(transactionsTable)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<TransactionsTableData>> getAllTransactions() {
    return (select(transactionsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> insertTransaction(TransactionsTableCompanion transaction) {
    return into(transactionsTable).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsTableCompanion transaction) {
    return update(transactionsTable).replace(transaction);
  }

  Future<int> deleteTransaction(String id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  // --- Categories ---
  Stream<List<CategoriesTableData>> watchAllCategories() {
    return select(categoriesTable).watch();
  }

  Future<List<CategoriesTableData>> getAllCategories() {
    return select(categoriesTable).get();
  }

  // --- Budgets ---
  Stream<BudgetsTableData?> watchMonthlyBudget(int month, int year) {
    return (select(budgetsTable)
          ..where((b) => b.month.equals(month) & b.year.equals(year) & b.categoryId.isNull()))
        .watchSingleOrNull();
  }

  Future<int> setMonthlyBudget(int month, int year, double amount) async {
    final existing = await (select(budgetsTable)
          ..where((b) => b.month.equals(month) & b.year.equals(year) & b.categoryId.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      return (update(budgetsTable)..where((b) => b.id.equals(existing.id))).write(
        BudgetsTableCompanion(amount: Value(amount)),
      );
    } else {
      return into(budgetsTable).insert(
        BudgetsTableCompanion.insert(
          id: 'budget_${year}_$month',
          month: month,
          year: year,
          amount: amount,
        ),
      );
    }
  }
}
