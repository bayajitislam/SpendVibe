import '../../../../core/database/app_database.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/i_budget_repository.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  @override
  Stream<BudgetEntity?> watchMonthlyBudget(int month, int year) {
    return _db.watchMonthlyBudget(month, year).map((row) {
      if (row == null) return null;
      return BudgetEntity(
        id: row.id,
        month: row.month,
        year: row.year,
        limitAmount: row.amount,
      );
    });
  }

  @override
  Future<void> setMonthlyBudget(int month, int year, double amount) async {
    await _db.setMonthlyBudget(month, year, amount);
  }
}
