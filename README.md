# SpendVibe

A modern, production-grade, offline-first personal finance application built with Flutter, Clean Architecture, Riverpod, and Drift (`drift_flutter`).

Designed for Google Play Store compliance, zero-crash reliability, and scalable infrastructure supporting future monetization models (In-App Purchases, Google AdMob, and cloud synchronization).

---

## Overview

SpendVibe provides an intuitive, high-performance solution for personal expense and budget management. The application operates entirely offline, storing financial records directly on the device using an ACID-compliant SQLite engine powered by Drift.

### Key Capabilities

- **Two-Tap Transaction Logging**: Rapid entry workflow allowing users to record income or expenses within seconds via category selectors and a currency-aware numeric interface.
- **Visual Analytics**: Dynamic category breakdowns and weekly expenditure trends built using `fl_chart`.
- **Budget Threshold Tracking**: Monthly spending allocations with automated threshold indicators (Normal, Warning at 80%, Over-budget at 100%).
- **Privacy-First Storage**: Complete on-device data isolation with zero required user authentication, zero external server transmissions, and no bank credential requests.
- **Multi-Currency Engine**: Runtime currency switching across global currencies including USD, EUR, GBP, BDT, INR, JPY, and more.
- **Data Portability**: Full transaction history export in standard CSV format via system share integrations (`share_plus`).
- **Google Play Compliance**: Meets target API 34+ guidelines, provides edge-to-edge layout support, and includes an in-app privacy policy.
- **Adaptive Theming**: Material 3 implementation featuring high-contrast dark and light color systems using Google Fonts typography.

---

## Architecture & Technology Stack

SpendVibe is structured according to Feature-First Clean Architecture principles, ensuring clear separation of concerns, testability, and maintainability.

### Layer Responsibilities

- **Domain Layer**: Contains pure Dart business entities, value objects, and abstract repository contracts (`TransactionEntity`, `CategoryEntity`, `BudgetEntity`, `ITransactionRepository`). Contains no dependencies on UI frameworks or storage libraries.
- **Data Layer**: Implements persistence via Drift (`drift_flutter`). Manages typed SQLite tables, queries, reactive streams, and mapping between database rows and domain entities.
- **Presentation Layer**: Built with Flutter widgets, Material 3 theming, and reactive state management powered by `flutter_riverpod` (`Notifier`, `StreamProvider`).
- **Core Layer**: Provides global utilities, currency formatters, date calculation helpers, and design token definitions.

### Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Theme color definitions
│   │   ├── app_categories.dart        # Category definitions and metadata
│   │   └── app_theme.dart             # Material 3 theme configurations
│   ├── database/
│   │   ├── app_database.dart          # Drift database definition and reactive streams
│   │   ├── app_database.g.dart        # Generated database code
│   │   └── tables/                    # Database schema definitions
│   └── utils/
│       ├── currency_formatter.dart    # Currency localization utilities
│       └── date_helpers.dart          # Date calculation and formatting helpers
│
├── features/
│   ├── transactions/
│   │   ├── domain/                    # Entities and repository interfaces
│   │   ├── data/                      # Mappers and repository implementations
│   │   └── presentation/              # Transaction screens and components
│   │
│   ├── analytics/
│   │   └── presentation/              # Donut chart and bar chart analytics
│   │
│   ├── budget/
│   │   ├── domain/                    # Budget domain entities
│   │   ├── data/                      # Budget repository implementations
│   │   └── presentation/              # Monthly budget configuration screens
│   │
│   └── settings/
│       └── presentation/              # Settings, CSV exporter, and privacy disclosures
│
├── screens/
│   └── main_navigation_screen.dart    # Root persistent navigation bar
└── main.dart                          # Application entry point and ProviderScope
```

---

## Getting Started

### Prerequisites

- Flutter SDK (version 3.19.0 or higher)
- Android Studio / VS Code with Flutter and Dart extensions
- Android SDK with API Level 34 installed

### Installation & Execution

1. Clone or open the workspace:
   ```bash
   cd "spend_vibe"
   ```

2. Retrieve project dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Drift database schema (required after schema modifications):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

---

## Quality Assurance & Verification

### Static Analysis

Execute static analysis to ensure code conforms to official Dart analysis standards:
```bash
flutter analyze
```

### Automated Testing

Run the test suite:
```bash
flutter test
```

The test suite validates:
- Currency formatting and multi-currency edge cases
- Budget threshold calculations and warning triggers
- Date calculation boundaries (week start/end, month start/end)
- Domain entity immutability and state transitions

---

## Google Play Release Configuration

- **Application ID**: `com.spendvibe.app`
- **Application Label**: `SpendVibe`
- **Minimum SDK**: API 21 (Android 5.0 Lollipop)
- **Target SDK**: API 34+ (Android 14)

### Build Production Bundle

To build a signed Android App Bundle (`.aab`) ready for Google Play Console upload:
```bash
flutter build appbundle --release
```

The resulting bundle is output to:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Roadmap

### Upcoming Capabilities

- **Advertising Integration**: Non-intrusive Google AdMob banner and rewarded ad implementations.
- **Premium Tier (In-App Purchases)**:
  - Automated receipt scanning and OCR integration
  - Biometric authentication (Fingerprint / Face ID)
  - Custom category and icon management
  - Encrypted cloud backup and cross-device synchronization
- **System Widgets**: Android home screen quick-logging widgets.

---

## License

This software and associated documentation are proprietary to SpendVibe (`com.spendvibe.app`).
