# BahtBuddy

BahtBuddy is an offline-first expense tracker for Android and iOS. It combines
manual income and expense entry with on-device slip text recognition, a local
Drift/SQLite ledger, category budgets, reports, notifications, PIN/biometric
security, English and Thai localization, and JSON/CSV backup.

## ITCS259 Submission

The final report and slide deck are in [`docs/ITCS259/`](docs/ITCS259/):

- [`BahtBuddy_Project_Report.pdf`](docs/ITCS259/BahtBuddy_Project_Report.pdf)
- [`BahtBuddy_Presentation_Slides.pdf`](docs/ITCS259/BahtBuddy_Presentation_Slides.pdf)
- [`build_final_deliverables.py`](docs/ITCS259/build_final_deliverables.py) regenerates the report and slides.

The report and slides include real Android emulator UI, implementation
architecture, data model, test evidence, limitations, team responsibilities,
and references.

## Requirements

- Flutter 3.x
- Dart 3.x
- Android Studio/SDK for Android
- Xcode and macOS for iOS compilation
- An emulator or supported physical device

## Installation

Install dependencies:

```powershell
flutter pub get
```

Run the application:

```powershell
flutter run
```

Run tests:

```powershell
flutter test
```

## Android

Connect an emulator or physical Android device, enable developer mode, and run
`flutter run`.

## iOS

On macOS:

```bash
cd ios
pod install
cd ..
flutter run
```

The iOS project includes camera, photo-library, Face ID, and ML Kit model
configuration. iOS binaries must be compiled on macOS with Xcode.

## How the Application Works

### Application startup and navigation

`lib/main.dart` initializes Flutter and starts a `ProviderScope`. The app in
`lib/app.dart` loads the saved locale and theme, configures `go_router`, and
places the selected route behind the optional lock gate. The main navigation
uses a stateful shell with Home, History, Reports, and Settings. Entry and
Budgets are separate routes.

### State and data flow

Screens watch Riverpod providers in `lib/providers.dart`. The providers expose
live Drift streams for transactions, categories, and budgets, and asynchronous
state for preferences, exchange rates, and the Home card layout. A change made
through a repository is written to SQLite; Drift then emits updated data to
subscribed screens, so totals and reports refresh from the same ledger.

The normal transaction path is:

1. The user enters an expense/income manually or chooses a slip image.
2. The entry form collects or reviews amount, date, category, note, recipient,
   reference, and optional image.
3. `TransactionRepository` checks for an existing non-empty slip reference.
   The same row can retain its reference while being edited.
4. The repository inserts or updates the transaction using `AppDatabase`.
5. If a recipient is present, its normalized name and chosen category are
   stored as a learned rule for later suggestions.
6. Riverpod/Drift updates Home, History, Budgets, and Reports.

### Slip scanning and OCR

Camera and gallery actions are provided by `image_picker`. The selected image
is copied into the app's documents storage. `SlipOcr` uses Google ML Kit's
on-device Latin recognizer and returns text; it does not upload the image to a
BahtBuddy server. `SlipParser` applies prioritized regular expressions to
extract an amount, date/time, recipient, and transaction reference. It
recognizes common English and Thai labels and Buddhist-year dates, but the
configured ML Kit model does not read Thai script. Consequently, OCR output
opens as an editable draft and is never saved without user confirmation.

Category suggestions use recipient keywords first and may be overridden by a
learned recipient rule. A duplicate slip reference is rejected by the
repository and is also protected by the unique SQLite column.

### Local database and calculations

`lib/data/db/app_database.dart` defines the Drift schema and migrations:

- `Categories`: bilingual category labels and income/expense classification
- `MoneyTransactions`: amount, type, category, date, note, recipient, slip
  reference, and image path
- `Budgets`: monthly limit per category
- `RecipientRules`: learned recipient-to-category mappings
- `Preferences`: theme, locale, PIN hash, biometrics, reminder, and time zone

The ledger database is local SQLite. The Home card arrangement and exchange
rates are stored as local JSON files. Reports and budget progress derive from
the transaction records and selected date ranges; they do not depend on a
remote analytics service.

### Reports, budgets, and notifications

Reports summarize the selected day, week, or month, compare it with the
previous period, plot category/period data, and select up to three tips from
deterministic rules. Rules include category concentration, period change,
remaining-income buffer, and daily spending pace. These are explainable
threshold rules, not generated financial advice.

Budgets store one monthly limit per category. After an expense is saved, local
notification logic can notify the user when spending crosses the configured
warning and limit levels. A daily reminder is optional and can be configured
in Settings.

### Network, security, and backups

The optional Frankfurter exchange-rate service is the only application
network-data feature. Rates are converted into baht and cached locally; the
ledger remains usable offline. The app can be protected with a PIN and
device-supported biometrics. CSV export provides a transaction-oriented file;
versioned JSON backup/restore covers the app's categories, transactions,
budgets, recipient rules, and preferences.

### Internationalization and presentation

English and Thai strings are generated from the localization resources. Theme
preferences, including system appearance, are persisted in preferences. App
assets include the bundled Plus Jakarta Sans font and Home promotional
graphics. The Android and iOS folders contain the respective platform
configuration; an iOS binary requires macOS and Xcode.

## Test Status

The complete Flutter suite passed **23 tests** on 24 November 2026. Coverage
includes slip parsing, duplicate references, Bangkok time zones, history
filters, PIN behavior, exchange-rate conversion, report tips, and manual-entry
and slip-confirmation widget workflows.

To regenerate the academic PDFs, install the Python ReportLab dependency if
needed, then run from the repository root:

```powershell
python docs\ITCS259\build_final_deliverables.py
```

## Source

https://github.com/Sakkaraj/BahtBuddy
