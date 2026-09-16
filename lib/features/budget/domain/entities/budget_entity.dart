class BudgetEntity {
  final String id;
  final int month;
  final int year;
  final double limitAmount;
  final double spentAmount;

  const BudgetEntity({
    required this.id,
    required this.month,
    required this.year,
    required this.limitAmount,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => (limitAmount - spentAmount).clamp(0.0, double.infinity);
  double get percentageSpent => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 2.0) : 0.0;
  bool get isWarning => percentageSpent >= 0.8 && percentageSpent < 1.0;
  bool get isOverBudget => percentageSpent >= 1.0;

  BudgetEntity copyWith({
    String? id,
    int? month,
    int? year,
    double? limitAmount,
    double? spentAmount,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}
