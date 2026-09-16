import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            context,
            icon: Icons.shield_rounded,
            iconColor: AppColors.income,
            title: '100% Offline & Private',
            content:
                'SpendVibe is designed with a strict offline-first philosophy. Your financial records, transactions, categories, and budgets are saved exclusively on your physical device using a local SQLite database. We do not transmit or store your personal financial data on any external servers.',
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            icon: Icons.lock_outline_rounded,
            iconColor: AppColors.primary,
            title: 'No Account or Bank Logins Required',
            content:
                'You can use SpendVibe completely anonymously. We do not require you to create an account, register your email address, or link your bank credentials.',
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            icon: Icons.file_download_outlined,
            iconColor: AppColors.warning,
            title: 'User Data Ownership & Export',
            content:
                'You own 100% of your financial data. At any time, you can generate a complete CSV export of all your transactions via the Settings tab, or wipe your local data completely.',
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            icon: Icons.contact_support_outlined,
            iconColor: AppColors.primaryLight,
            title: 'Contact Information',
            content:
                'If you have any questions or feedback regarding this privacy policy or the SpendVibe app, please contact us at lasharaxai@gmail.com or developer at contact@bayajitislam.com.',
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Last updated: September 2026\nVersion 1.0.0 (Build 1)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    ),
  );
  }
}
