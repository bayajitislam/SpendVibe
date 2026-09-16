import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';

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
  @override
  SettingsState build() {
    return const SettingsState(
      currency: CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
      themeMode: ThemeMode.dark,
    );
  }

  void setCurrency(CurrencyInfo currency) {
    state = state.copyWith(currency: currency);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
