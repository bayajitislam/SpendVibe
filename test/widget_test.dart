import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vibe/core/utils/currency_formatter.dart';
import 'package:spend_vibe/core/utils/date_helpers.dart';
import 'package:spend_vibe/core/constants/app_categories.dart';
import 'package:spend_vibe/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_vibe/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('SpendVibe Core Logic Unit Tests', () {
    test('CurrencyFormatter formats currency properly', () {
      expect(CurrencyFormatter.format(1250.50, symbol: '\$'), '\$1,250.50');
      expect(CurrencyFormatter.format(0.0, symbol: '€'), '€0.00');
      expect(CurrencyFormatter.format(50000.0, symbol: '¥'), '¥50,000');
    });

    test('BudgetEntity calculates remaining and warnings correctly', () {
      // Normal spending (50%)
      const healthyBudget = BudgetEntity(
        id: 'test_1',
        month: 9,
        year: 2026,
        limitAmount: 1000.0,
        spentAmount: 500.0,
      );
      expect(healthyBudget.remainingAmount, 500.0);
      expect(healthyBudget.percentageSpent, 0.5);
      expect(healthyBudget.isWarning, false);
      expect(healthyBudget.isOverBudget, false);

      // Warning threshold (85%)
      const warningBudget = BudgetEntity(
        id: 'test_2',
        month: 9,
        year: 2026,
        limitAmount: 1000.0,
        spentAmount: 850.0,
      );
      expect(warningBudget.remainingAmount, 150.0);
      expect(warningBudget.percentageSpent, 0.85);
      expect(warningBudget.isWarning, true);
      expect(warningBudget.isOverBudget, false);

      // Over budget (110%)
      const overBudget = BudgetEntity(
        id: 'test_3',
        month: 9,
        year: 2026,
        limitAmount: 1000.0,
        spentAmount: 1100.0,
      );
      expect(overBudget.remainingAmount, 0.0);
      expect(overBudget.percentageSpent, 1.1);
      expect(overBudget.isWarning, false);
      expect(overBudget.isOverBudget, true);
    });

    test('DateHelpers calculates start and end of month correctly', () {
      final testDate = DateTime(2026, 9, 15);
      final start = DateHelpers.startOfMonth(testDate);
      final end = DateHelpers.endOfMonth(testDate);

      expect(start.day, 1);
      expect(start.month, 9);
      expect(end.month, 9);
      expect(end.day, 30);
    });

    test('AppCategories has default categories pre-configured', () {
      expect(AppCategories.defaultExpenseCategories.isNotEmpty, true);
      expect(AppCategories.defaultIncomeCategories.isNotEmpty, true);

      final foodCat = AppCategories.getCategoryById('food');
      expect(foodCat.name, 'Food & Dining');
      expect(foodCat.type, TransactionType.expense);
    });

    test('TransactionEntity creation and copyWith works as expected', () {
      final tx = TransactionEntity(
        id: 'tx_123',
        title: 'Lunch',
        amount: 25.50,
        date: DateTime(2026, 9, 16),
        type: TransactionType.expense,
        categoryId: 'food',
      );

      final updated = tx.copyWith(amount: 30.0);
      expect(updated.id, 'tx_123');
      expect(updated.amount, 30.0);
      expect(updated.title, 'Lunch');
    });
  });
}
