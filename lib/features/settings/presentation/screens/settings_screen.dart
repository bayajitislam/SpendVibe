import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/settings_provider.dart';
import '../utils/csv_exporter.dart';
import 'privacy_policy_screen.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsProvider).currency;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Material(
          color: isDark ? AppColors.darkBackground : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: CurrencyFormatter.supportedCurrencies.length,
                  itemBuilder: (ctx, index) {
                    final curr = CurrencyFormatter.supportedCurrencies[index];
                    final isSelected = curr.code == current.code;

                    return ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            curr.flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      title: Text(curr.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${curr.code} • ${curr.symbol}'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(settingsProvider.notifier).setCurrency(curr);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          // Preferences Section
          _buildSectionHeader('Preferences', isDark),
          _buildTile(
            context,
            icon: Icons.currency_exchange_rounded,
            iconColor: AppColors.income,
            title: 'Currency',
            subtitle: '${settings.currency.flag}  ${settings.currency.name} (${settings.currency.symbol})',
            onTap: () => _showCurrencyPicker(context, ref),
            isDark: isDark,
          ),
          _buildTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: AppColors.warning,
            title: 'Theme Mode',
            subtitle: settings.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
            trailing: Switch.adaptive(
              value: settings.themeMode == ThemeMode.dark,
              activeThumbColor: AppColors.primary,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).setThemeMode(
                      val ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management', isDark),
          _buildTile(
            context,
            icon: Icons.file_download_outlined,
            iconColor: AppColors.primaryLight,
            title: 'Export to CSV',
            subtitle: 'Export complete transaction history as spreadsheet',
            onTap: () async {
              final transactions = await ref.read(transactionRepositoryProvider).getAllTransactions();
              if (transactions.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No transactions to export yet!')),
                  );
                }
                return;
              }
              await CsvExporter.exportAndShare(transactions);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // About & Compliance
          _buildSectionHeader('About & Legal', isDark),
          _buildTile(
            context,
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.income,
            title: 'Privacy Policy',
            subtitle: '100% offline data protection & disclosures',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            isDark: isDark,
          ),
          _buildTile(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primary,
            title: 'About SpendVibe',
            subtitle: 'Version 1.0.0 (Build 1)',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SpendVibe',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 28),
                ),
                children: const [
                  Text('SpendVibe is your private, fast, offline-first personal budget and expense manager.'),
                ],
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'SpendVibe • Made with Flutter\ncom.spendvibe.app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    required bool isDark,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
