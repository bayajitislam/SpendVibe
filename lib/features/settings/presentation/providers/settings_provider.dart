import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/currency_formatter.dart';

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

class SettingsState {
  final CurrencyInfo currency;
  final ThemeMode themeMode;

  const SettingsState({
    required this.currency,
    this.themeMode = ThemeMode.dark,
  });

  SettingsState copyWith({
    CurrencyInfo? currency,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const String _currencyCodeKey = 'selected_currency_code';
  static const String _themeModeKey = 'selected_theme_mode';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs?.getString(_currencyCodeKey);
    final savedTheme = prefs?.getString(_themeModeKey);

    final currency = savedCode != null
        ? CurrencyFormatter.supportedCurrencies.firstWhere(
            (c) => c.code == savedCode,
            orElse: () => CurrencyFormatter.supportedCurrencies.first,
          )
        : CurrencyFormatter.supportedCurrencies.first;

    final themeMode = savedTheme == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;

    return SettingsState(
      currency: currency,
      themeMode: themeMode,
    );
  }

  Future<void> setCurrency(CurrencyInfo currency) async {
    state = state.copyWith(currency: currency);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs?.setString(_currencyCodeKey, currency.code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs?.setString(
      _themeModeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
