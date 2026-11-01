import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/settings_provider.dart';
import '../utils/csv_exporter.dart';
import 'privacy_policy_screen.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../../core/ads/ad_helper.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/purchases/purchase_service.dart';
import 'paywall_sheet.dart';

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
          // SpendVibe Pro Status Banner
          ValueListenableBuilder<bool>(
            valueListenable: PurchaseService.instance.isProNotifier,
            builder: (context, isPro, _) {
              return _buildProCard(context, isDark, isPro);
            },
          ),
          const SizedBox(height: 20),

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

          // Membership & Data Section
          _buildSectionHeader('Membership & Data', isDark),
          _buildTile(
            context,
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'SpendVibe Pro',
            subtitle: 'Manage subscription or view lifetime perks',
            onTap: () => PaywallSheet.show(context),
            isDark: isDark,
          ),
          _buildTile(
            context,
            icon: Icons.restore_rounded,
            iconColor: AppColors.primaryLight,
            title: 'Restore Purchases',
            subtitle: 'Sync active Google Play purchases and entitlements',
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checking Google Play for previous purchases...')),
              );
              await PurchaseService.instance.restorePurchases();
              if (context.mounted) {
                if (PurchaseService.instance.isPro) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SpendVibe Pro is active and restored!'),
                      backgroundColor: AppColors.income,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No active purchases found for this account.')),
                  );
                }
              }
            },
            isDark: isDark,
          ),
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

          // AdMob Testing Section (Visible during development/debug mode)
          if (AdHelper.isTestMode) ...[
            _buildSectionHeader('AdMob & Billing Testing (Debug Only)', isDark),
            ValueListenableBuilder<bool>(
              valueListenable: PurchaseService.instance.isProNotifier,
              builder: (context, isPro, _) {
                return _buildTile(
                  context,
                  icon: Icons.star_half_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Toggle Pro Status (Debug)',
                  subtitle: 'Current status: ${isPro ? "PRO ACTIVE (Ads Disabled)" : "FREE (Ads Active)"}',
                  onTap: () {
                    PurchaseService.instance.debugSetProStatus(!isPro);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pro status switched to: ${!isPro}')),
                    );
                  },
                  isDark: isDark,
                );
              },
            ),
            _buildTile(
              context,
              icon: Icons.fullscreen_rounded,
              iconColor: AppColors.primary,
              title: 'Show Interstitial Ad',
              subtitle: 'Test full-screen interstitial ad on demand',
              onTap: () {
                final shown = AdService.instance.showInterstitialAd();
                if (!shown && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        PurchaseService.instance.isPro
                            ? 'User is Pro! Interstitial ads are suppressed.'
                            : 'Interstitial ad is loading... Please tap again in a few seconds.',
                      ),
                    ),
                  );
                }
              },
              isDark: isDark,
            ),
            _buildTile(
              context,
              icon: Icons.open_in_browser_rounded,
              iconColor: AppColors.income,
              title: 'Show App Open Ad',
              subtitle: 'Test App Open ad on demand (ignores cooldown)',
              onTap: () {
                final shown = AdService.instance.showAppOpenAdIfAvailable(ignoreCooldown: true);
                if (!shown && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        PurchaseService.instance.isPro
                            ? 'User is Pro! App Open ads are suppressed.'
                            : 'App Open ad is loading... Please tap again in a few seconds.',
                      ),
                    ),
                  );
                }
              },
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],

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
            subtitle: 'Version 1.1.0 (Build 4)',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SpendVibe',
                applicationVersion: '1.1.0',
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

  Widget _buildProCard(BuildContext context, bool isDark, bool isPro) {
    if (isPro) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withAlpha(isDark ? 50 : 25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SpendVibe Pro',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100% Ad-Free • Supporter Status',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SPENDVIBE PRO',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AD-FREE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Enjoy Clean, Ad-Free Budgeting',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Remove all ads forever. Choose flexible monthly or supporter lifetime access.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withAlpha(220),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => PaywallSheet.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upgrade Now',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
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
