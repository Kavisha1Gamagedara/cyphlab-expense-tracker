# TRACE — Personal Expense Tracker Mobile App

**TRACE** is a modern, full-featured personal expense tracking mobile application built with **Flutter** and powered by **Firebase**. Designed with a clean aesthetic, TRACE empowers users to effortlessly record expenses, set category-wise budgets, analyze spending trends through interactive charts, secure their data with hardware biometric locks, and stay disciplined with timezone-accurate daily reminders and real-time budget threshold warnings.

## Features Implemented

### 1. Core Requirements
- **Add New Expenses**: Log expenses with Title, Amount, Category, Date, and an optional Description/Note.
- **Edit Existing Expenses**: Update any transaction directly with auto-populated form fields.
- **Two-Stage Deletion**: Soft-delete items to a dedicated Recycle Bin to prevent accidental data loss, with permanent deletion and restoration options.
- **Expense Categorization**: 8 default categories with custom color tokens and icons:
  - *Food & Dining*, *Transport*, *Shopping*, *Entertainment*, *Bills & Utilities*, *Health & Medical*, *Education*, and *Other*.
- **Firebase Cloud Storage**: Real-time cloud persistence using **Cloud Firestore** scoped securely per authenticated user (`users/{userId}/expenses/{id}`) with offline cache support.
- **Monthly Totals & Daily Averages**: Instant calculation of total spending for the current or selected month alongside computed daily averages.
- **Expense History**: Chronological expense feed with date headers (*Today*, *Yesterday*, or formatted calendar date).
- **Multi-criteria Filtering**:
  - Filter transactions horizontally by category chips (*All*, *Food*, *Transport*, etc.).
  - Navigate between months or pick a specific calendar day via an interactive calendar bottom sheet.
- **Robust Form Validation**: Live FormKey validation ensuring title presence, positive numerical amounts (`> 0`), category selection, and valid date selection.
- **State Handling**:
  - **Loading State**: Shimmer skeleton placeholder cards during asynchronous data fetching.
  - **Empty State**: Custom illustrations with contextual guidance and quick-action buttons when no records exist.
  - **Error State**: User-friendly error displays with a one-tap retry mechanism.

---

### 2. Advanced & Additional Features
- **Biometric App Lock (`local_auth`)**:
  - Hardware-backed biometric security supporting Fingerprint, Face ID, or system passcode fallback.
  - Automatic app locking when minimized or backgrounded with a secure privacy barrier.
  - User toggle with prompt verification in Settings.
- **Notification & Reminder Service (`flutter_local_notifications`)**:
  - **Daily Expense Reminder**: Customizable recurring reminder alarm with an interactive in-app TimePicker dialog.
  - **Timezone Awareness (`flutter_timezone` + `timezone`)**: Automatically resolves device local timezone (e.g., `Asia/Colombo` UTC+05:30) ensuring exact alarms trigger at the user's scheduled local time.
  - **Real-Time Budget Warnings**: Immediate push notifications when spending hits **80%** (Warning) or **100%** (Exceeded) of an overall or category budget limit.
  - **Recycle Bin Cleanup Warning**: Informs users when soft-deleted items approach permanent cleanup.
- **Budgeting & Spending Limits**:
  - Monthly overall budget target with dynamic progress bar and remaining balance indicator.
  - Category-wise spending limits with visual over-budget indicators.
- **Interactive Charts & Analytics**:
  - **Weekly Spend Bar Chart**: Interactive custom bar chart with day selection and highlighted spending peaks.
  - **Monthly Spend Curve**: Custom-painted bezier line chart displaying monthly expense trajectory with smooth gradients.
  - **Category Breakdown**: Donut chart and percentage distribution list highlighting top expense categories.
- **Recycle Bin & Data Retention**:
  - Dedicated screen displaying soft-deleted transactions with a 5-day retention countdown badge.
  - Ability to restore individual items or empty the trash permanently.
- **Multi-Currency Converter**:
  - Support for global currencies including **LKR (Rs)**, **USD ($)**, **EUR (€)**, **GBP (£)**, **JPY (¥)**, **AUD ($)**, **CAD ($)**, **INR (₹)**, and more.
  - Live currency formatting across all balance cards, charts, and transaction tiles.
- **Bilingual Localization (English & Sinhala)**:
  - Complete, seamless in-app language switching between **English** and **Sinhala (සිංහල)**.
  - Comprehensive localization dictionary covering all screens, dialogs, validation messages, and system prompts.
- **Reports & Data Export**:
  - Export monthly or filtered expense records to styled **PDF documents** (complete with tables and summary headers) or download raw **CSV spreadsheets**.
- **Dark Mode & Appearance Customization**:
  - Dedicated theme switcher supporting **Light Mode**, **Dark Mode**, and **System Auto Mode**.
- **Firebase Authentication**:
  - Email & password registration, sign-in, password reset, and session state persistence via `AuthGate`.
- **Interactive Onboarding Walkthrough**:
  - Story-style swipeable carousel walking new users through TRACE's core capabilities.

---

## Technologies & Packages Used

| Package / Tool | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `>= 3.10.8` | Cross-platform UI toolkit |
| **Dart** | `>= 3.0.0` | Core programming language |
| **[`provider`](https://pub.dev/packages/provider)** | `^6.1.5+1` | Reactive state management |
| **[`firebase_core`](https://pub.dev/packages/firebase_core)** | `^4.15.0` | Firebase app initialization |
| **[`cloud_firestore`](https://pub.dev/packages/cloud_firestore)** | `^6.10.0` | Cloud database for real-time transaction sync |
| **[`firebase_auth`](https://pub.dev/packages/firebase_auth)** | `^6.7.0` | User authentication and session persistence |
| **[`local_auth`](https://pub.dev/packages/local_auth)** | `^3.0.2` | Biometric authentication (Fingerprint / Face ID / PIN) |
| **[`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)** | `^22.3.1` | Local scheduled reminders and budget alert notifications |
| **[`timezone`](https://pub.dev/packages/timezone)** | `^0.11.1` | Timezone-aware date calculations for exact alarms |
| **[`flutter_timezone`](https://pub.dev/packages/flutter_timezone)** | `^5.1.0` | Native device timezone identifier resolution |
| **[`shared_preferences`](https://pub.dev/packages/shared_preferences)** | `^2.5.5` | Key-value persistent storage for settings and preferences |
| **[`intl`](https://pub.dev/packages/intl)** | `^0.20.3` | Date formatting and currency calculations |
| **[`pdf`](https://pub.dev/packages/pdf)** | `^3.12.0` | Document creation for PDF expense statements |
| **[`printing`](https://pub.dev/packages/printing)** | `^5.14.3` | Printing and PDF sharing functionality |
| **[`csv`](https://pub.dev/packages/csv)** | `^8.0.0` | CSV data generation for spreadsheet exports |
| **[`path_provider`](https://pub.dev/packages/path_provider)** | `^2.1.6` | Accessing device file storage directories |
| **[`share_plus`](https://pub.dev/packages/share_plus)** | `^13.3.0` | Native OS file sharing dialog |
| **[`cupertino_icons`](https://pub.dev/packages/cupertino_icons)** | `^1.0.8` | iOS-styled iconography |

---

## AI Tools Used

During the design and implementation of **TRACE**, AI tooling was leveraged for engineering productivity, rapid problem-solving, and quality assurance:

- **ChatGPT**:
  - **logo Generation**: generated the digital version of hand drawn logo.

- **StitchAI**: generated the digital version of hand drawn sample UI layout.

- **Google Antigravity (Advanced Agentic AI)**:
  - **Architecture & Code Structuring**: Pair-programmed state management architectures using `Provider`, structuring data services (`FirebaseService`, `NotificationService`, `BiometricService`), and maintaining strict separation of concerns.
  - **Timezone & Background Scheduling Debugging**: Diagnosed Android 12+ exact alarm scheduling quirks (`SCHEDULE_EXACT_ALARM`, `AndroidScheduleMode.exactAllowWhileIdle`) and configured `flutter_timezone` with IANA resolution to eliminate UTC offset timing bugs.
  - **Android Gradle Desugaring**: Resolved Java 8 / `desugar_jdk_libs` compilation constraints for `flutter_local_notifications` in Android Gradle Plugin 8 (`build.gradle.kts`).
  - **Bilingual Dictionary Generation**: Curated comprehensive English and Sinhala (සිංහල) linguistic translations across the UI.
  - **Custom Canvas & UI Design**: Built custom mathematical curves for the monthly expenditure line graph and weekly bar chart widgets via `CustomPainter`.
  - **Automated Unit Testing**: Generated isolated unit tests with mock services in `test/notification_provider_test.dart` and `test/biometric_provider_test.dart`.

## Project Setup Instructions

### Prerequisites
Ensure your local development environment has:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** version `3.10.8` or higher
- **Dart SDK** version `3.0.0` or higher
- **VS Code** with Flutter and Dart extensions installed
- **Android SDK** (API Level 34+ recommended) with **JDK 17**
- An active **Firebase project** (for Firestore and Authentication)

### Step-by-Step Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Kavisha1Gamagedara/cyphlab-expense-tracker.git
   cd cyphlab-expense-tracker
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password provider).
   - Enable **Cloud Firestore Database** (Start in test mode or apply user-scoped security rules).
   - **For Android**:
     - Register an Android app with package name `com.example.expense_tracker`.
     - Download `google-services.json` and place it in `android/app/google-services.json`.
   - Alternatively, configure via the FlutterFire CLI:
     ```bash
     flutterfire configure
     ```

4. **Verify Codebase Health**:
   - Run the static analyzer to confirm 0 warnings/errors:
     ```bash
     flutter analyze
     ```
   - Execute all unit tests:
     ```bash
     flutter test
     ```

5. **Run the Application**:
   - Connect an Android device or launch an emulator:
     ```bash
     flutter run
     ```
   - Or build a standalone debug APK:
     ```bash
     flutter build apk --debug
     ```

---

### Android Build Notes
- **Core Library Desugaring**: Required by `flutter_local_notifications` for Java 8 Time APIs on older Android versions. Already pre-configured in `android/app/build.gradle.kts`:
  ```kotlin
  compileOptions {
      isCoreLibraryDesugaringEnabled = true
      sourceCompatibility = JavaVersion.VERSION_17
      targetCompatibility = JavaVersion.VERSION_17
  }
  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
  }
  ```
- **Permissions**: Notification (`POST_NOTIFICATIONS`), Boot (`RECEIVE_BOOT_COMPLETED`), and Exact Alarm permissions (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`) are declared in `android/app/src/main/AndroidManifest.xml`.


## Project Architecture

```
lib/
├── core/
│   ├── constants.dart        # Global configuration, categories & storage keys
│   ├── theme.dart            # Modern Light & Dark color palettes & ThemeData
│   └── translations.dart     # Complete English & Sinhala localization dictionary
├── data/
│   ├── models/
│   │   ├── budget_model.dart     # Monthly & category budget models
│   │   ├── currency_model.dart   # Supported currency entities & formatting
│   │   └── expense_model.dart    # Transaction model with Firestore serialization
│   └── services/
│       ├── auth_service.dart         # Firebase Authentication handler
│       ├── biometric_service.dart    # Hardware biometric authentication wrapper
│       ├── export_service.dart       # PDF statement generation & CSV exporter
│       ├── firebase_service.dart     # Cloud Firestore real-time queries & CRUD
│       └── notification_service.dart # Local notifications, timezone & exact alarm manager
├── presentation/
│   ├── screens/
│   │   ├── analytics_screen.dart       # Deep spending insights & category charts
│   │   ├── auth_screen.dart            # Clean login & registration flow
│   │   ├── biometric_lock_screen.dart  # Secure privacy shield & biometric unlock UI
│   │   ├── dashboard_screen.dart       # Main financial feed, summary cards & search
│   │   ├── expense_form.dart           # Validated transaction creation & edit form
│   │   ├── main_navigation_screen.dart # Floating bottom navigation controller
│   │   ├── onboarding_screen.dart      # Story-style walkthrough
│   │   ├── recycle_bin_screen.dart     # 5-day retention & restoration trash bin
│   │   └── settings_screen.dart        # Preferences, biometrics, timers & language
│   ├── state/
│   │   ├── auth_provider.dart          # Authentication state management
│   │   ├── biometric_provider.dart     # Biometric toggle & lock gate state
│   │   ├── currency_provider.dart      # Selected currency and symbol state
│   │   ├── expense_provider.dart       # Expenses, filters, budgets & recycle bin logic
│   │   ├── language_provider.dart      # English / Sinhala translation state
│   │   ├── notification_provider.dart  # Reminder time, master switch & alert thresholds
│   │   └── theme_provider.dart         # Light / Dark / System mode state
│   └── widgets/
│       ├── budget_settings_sheet.dart  # Category-wise budget limit configuration
│       ├── calendar_selector_sheet.dart# Custom calendar date filter sheet
│       ├── currency_picker_sheet.dart  # Searchable multi-currency selector
│       ├── empty_state.dart            # Contextual empty state illustrations
│       ├── error_state.dart            # Error handling with retry action
│       ├── expense_tile.dart           # Polished transaction card with swipe actions
│       ├── export_report_sheet.dart    # Date-range report download dialog
│       ├── monthly_analytics_card.dart # Category breakdown donut widget
│       ├── monthly_budget_card.dart    # Hero budget card with bezier trend curve
│       └── theme_settings_sheet.dart   # Theme selector modal
├── firebase_options.dart               # Default Firebase initialization options
└── main.dart                           # Entrypoint, providers & biometric gate
```


## erification & Quality Assurance

The codebase complies with strict quality standards:
- **`flutter analyze`**: **0 issues found** (clean linting and static analysis).
- **`flutter test`**: **8/8 unit tests passed** covering:
  - `BiometricProvider`: Initial defaults, SharedPreferences loading, and authentication toggles.
  - `NotificationProvider`: Default schedules, preference persistence, time updates, budget alert dispatch, and master disable cancellation.
- **Android APK Build**: Verified with successful Gradle compilation (`flutter build apk --debug`).

