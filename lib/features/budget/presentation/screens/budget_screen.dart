import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_helpers.dart';
import '../providers/budget_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, double currentLimit, String currencySymbol) {
    final controller = TextEditingController(text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Monthly Budget', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your total spending target for this month. You will receive visual alerts as you approach your limit.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                autofocus: true,
                decoration: InputDecoration(
                  prefixText: '$currencySymbol ',
                  labelText: 'Monthly Limit',
                  hintText: 'e.g. 1500',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim());
                if (amount != null && amount > 0) {
                  final now = DateTime.now();
                  final repo = ref.read(budgetRepositoryProvider);
                  await repo.setMonthlyBudget(now.month, now.year, amount);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Limit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(activeBudgetProvider);
    final currency = ref.watch(settingsProvider).currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final limit = budget?.limitAmount ?? 0.0;
    final spent = budget?.spentAmount ?? 0.0;
    final remaining = budget?.remainingAmount ?? 0.0;
    final percentage = budget?.percentageSpent ?? 0.0;

    final progressColor = budget?.isOverBudget == true
        ? AppColors.expense
        : (budget?.isWarning == true ? AppColors.warning : AppColors.income);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Budget',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          // Month Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppColors.primaryLight),
                const SizedBox(width: 12),
                Text(
                  DateHelpers.formatMonthYear(now),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showSetBudgetDialog(context, ref, limit, currency.symbol),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(limit > 0 ? 'Edit Limit' : 'Set Limit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Budget Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (limit > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: progressColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          budget?.isOverBudget == true
                              ? 'Over Budget'
                              : (budget?.isWarning == true ? 'Near Limit (>80%)' : 'Healthy'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  limit > 0
                      ? '${CurrencyFormatter.format(remaining, symbol: currency.symbol)} left'
                      : 'No Budget Limit Configured',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: limit > 0 ? (remaining > 0 ? AppColors.income : AppColors.expense) : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: limit > 0 ? percentage.clamp(0.0, 1.0) : 0.0,
                    minHeight: 12,
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol('Total Limit', CurrencyFormatter.format(limit, symbol: currency.symbol), isDark),
                    _buildStatCol('Total Spent', CurrencyFormatter.format(spent, symbol: currency.symbol), isDark),
                    _buildStatCol('% Used', '${(percentage * 100).toInt()}%', isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Helpful Insights Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Budgeting Rule of Thumb',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try the 50/30/20 rule: 50% for Needs (groceries, bills), 30% for Wants (dining, entertainment), and 20% for Savings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}
