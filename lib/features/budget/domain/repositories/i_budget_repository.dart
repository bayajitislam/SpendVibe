import '../entities/budget_entity.dart';

abstract class IBudgetRepository {
  Stream<BudgetEntity?> watchMonthlyBudget(int month, int year);
  Future<void> setMonthlyBudget(int month, int year, double amount);
}
