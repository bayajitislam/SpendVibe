import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/purchases/purchase_service.dart';
import 'privacy_policy_screen.dart';

enum ProPlanType { monthly, lifetime }

/// Modern, high-converting bottom sheet paywall for SpendVibe Pro.
class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  /// Convenient helper to display the sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallSheet(),
    );
  }

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  ProPlanType _selectedPlan = ProPlanType.monthly;
  final PurchaseService _purchaseService = PurchaseService.instance;

  @override
  void initState() {
    super.initState();
    // Query latest product info on open
    _purchaseService.queryProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 120 : 40),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _purchaseService.isProNotifier,
          builder: (context, isPro, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _purchaseService.isPurchaseInProgressNotifier,
              builder: (context, isPurchasing, _) {
                return ValueListenableBuilder<List<ProductDetails>>(
                  valueListenable: _purchaseService.productsNotifier,
                  builder: (context, products, _) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Top Close Button & Title Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 40),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SPENDVIBE PRO',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (isPro) ...[
                            // Already Pro State
                            _buildAlreadyProView(context, isDark),
                          ] else ...[
                            // Header Headline
                            Text(
                              'Upgrade to SpendVibe Pro',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enjoy a seamless, 100% ad-free personal finance tracker and support ongoing development.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Feature Highlights
                            _buildFeatureList(isDark),
                            const SizedBox(height: 24),

                            // Plan Cards
                            _buildPlanCards(context, isDark, products),
                            const SizedBox(height: 24),

                            // CTA Purchase Button
                            _buildPurchaseButton(context, isDark, isPurchasing, products),
                            const SizedBox(height: 14),

                            // Restore Purchases Button
                            TextButton.icon(
                              onPressed: isPurchasing ? null : _handleRestore,
                              icon: const Icon(Icons.restore, size: 18),
                              label: Text(
                                'Restore Previous Purchases',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Legal Terms & Privacy links
                            _buildLegalFooter(context, isDark),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlreadyProView(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(120), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified, size: 60, color: Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Text(
            'You are a SpendVibe Pro Member!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All banner, interstitial, and app open ads are permanently disabled. Thank you for supporting our work!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Back to SpendVibe'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(bool isDark) {
    final features = [
      {'icon': Icons.block, 'color': AppColors.expense, 'title': '100% Ad-Free Experience', 'desc': 'No banner, interstitial, or app open ads anywhere.'},
      {'icon': Icons.speed, 'color': AppColors.primary, 'title': 'Blazing Fast Performance', 'desc': 'Instant launch, zero ad tracking latency.'},
      {'icon': Icons.sync, 'color': AppColors.income, 'title': 'Cross-Device Restore', 'desc': 'Restore purchases seamlessly across any Android device.'},
      {'icon': Icons.volunteer_activism, 'color': const Color(0xFFEC4899), 'title': 'Support Independent Creator', 'desc': 'Fund ongoing updates, offline security, and new features.'},
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (f['color'] as Color).withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(f['icon'] as IconData, size: 20, color: f['color'] as Color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f['desc'] as String,
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
      }).toList(),
    );
  }

  Widget _buildPlanCards(BuildContext context, bool isDark, List<ProductDetails> products) {
    // Find store products or fallback to default strings
    ProductDetails? monthlyProduct;
    ProductDetails? lifetimeProduct;

    for (final p in products) {
      if (p.id == PurchaseService.monthlySubscriptionId) monthlyProduct = p;
      if (p.id == PurchaseService.lifetimeProductId) lifetimeProduct = p;
    }

    final monthlyPrice = monthlyProduct?.price ?? '\$1.99';
    final lifetimePrice = lifetimeProduct?.price ?? '\$99.99';

    return Row(
      children: [
        // Monthly Plan Card
        Expanded(
          child: _buildPlanOption(
            isDark: isDark,
            plan: ProPlanType.monthly,
            title: 'Monthly',
            price: monthlyPrice,
            period: '/ month',
            subtitle: 'Flexible plan\nCancel anytime',
            badgeText: 'POPULAR',
            badgeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        // Lifetime Plan Card
        Expanded(
          child: _buildPlanOption(
            isDark: isDark,
            plan: ProPlanType.lifetime,
            title: 'Lifetime',
            price: lifetimePrice,
            period: 'one-time',
            subtitle: 'Pay once\nKeep forever',
            badgeText: 'SUPPORTER',
            badgeColor: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanOption({
    required bool isDark,
    required ProPlanType plan,
    required String title,
    required String price,
    required String period,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
  }) {
    final isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : (isDark ? AppColors.darkSurface.withAlpha(120) : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? badgeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: badgeColor.withAlpha(isDark ? 80 : 40),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Plan Title
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Price
            Text(
              price,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isSelected ? badgeColor : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            Text(
              period,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                height: 1.3,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    bool isDark,
    bool isPurchasing,
    List<ProductDetails> products,
  ) {
    ProductDetails? selectedProduct;
    final targetId = _selectedPlan == ProPlanType.monthly
        ? PurchaseService.monthlySubscriptionId
        : PurchaseService.lifetimeProductId;

    for (final p in products) {
      if (p.id == targetId) selectedProduct = p;
    }

    final buttonLabel = _selectedPlan == ProPlanType.monthly
        ? 'Subscribe for ${selectedProduct?.price ?? "\$1.99/mo"}'
        : 'Get Lifetime for ${selectedProduct?.price ?? "\$99.99"}';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isPurchasing ? null : () => _handlePurchase(selectedProduct),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                buttonLabel,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePurchase(ProductDetails? product) async {
    if (product == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connecting to Google Play Store... Please ensure you are logged into Google Play.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      await _purchaseService.queryProducts();
      return;
    }

    final success = await _purchaseService.buyProduct(product);
    if (!mounted) return;

    if (!success) {
      final errorMsg = _purchaseService.purchaseErrorNotifier.value;
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: GoogleFonts.inter()),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checking Google Play for previous purchases...', style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
      ),
    );

    await _purchaseService.restorePurchases();

    if (!mounted) return;

    if (_purchaseService.isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back! SpendVibe Pro restored successfully.', style: GoogleFonts.inter()),
          backgroundColor: AppColors.income,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No active purchases found for this Google account.', style: GoogleFonts.inter()),
        ),
      );
    }
  }

  Widget _buildLegalFooter(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          'Subscriptions renew automatically unless canceled at least 24 hours before the end of the billing cycle in Google Play Subscriptions.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
