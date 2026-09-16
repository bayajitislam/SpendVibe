import 'package:intl/intl.dart';

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', flag: '🇧🇩'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    CurrencyInfo(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    CurrencyInfo(code: 'AUD', symbol: 'AU\$', name: 'Australian Dollar', flag: '🇦🇺'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    CurrencyInfo(code: 'SGD', symbol: 'SG\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    CurrencyInfo(code: 'AED', symbol: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
    CurrencyInfo(code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
    CurrencyInfo(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit', flag: '🇲🇾'),
    CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
    CurrencyInfo(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
    CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    CurrencyInfo(code: 'KRW', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    CurrencyInfo(code: 'TRY', symbol: '₺', name: 'Turkish Lira', flag: '🇹🇷'),
    CurrencyInfo(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah', flag: '🇮🇩'),
    CurrencyInfo(code: 'PKR', symbol: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰'),
    CurrencyInfo(code: 'PHP', symbol: '₱', name: 'Philippine Peso', flag: '🇵🇭'),
  ];

  static String format(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    if (symbol == '¥' || symbol == 'JPY' || symbol == '₩' || symbol == 'KRW') {
      final intFormatter = NumberFormat('#,##0', 'en_US');
      return '$symbol${intFormatter.format(amount)}';
    }
    return '$symbol${formatter.format(amount)}';
  }

  static String formatCompact(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compact(locale: 'en_US');
    return '$symbol${formatter.format(amount)}';
  }
}
