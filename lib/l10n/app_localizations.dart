import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BahtBuddy'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @emptyTransactions.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get emptyTransactions;

  /// No description provided for @scanSlip.
  ///
  /// In en, this message translates to:
  /// **'Scan a slip'**
  String get scanSlip;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get manualEntry;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @requiredAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get requiredAmount;

  /// No description provided for @reviewSlip.
  ///
  /// In en, this message translates to:
  /// **'Review slip'**
  String get reviewSlip;

  /// No description provided for @parsingSlip.
  ///
  /// In en, this message translates to:
  /// **'Reading slip…'**
  String get parsingSlip;

  /// No description provided for @ocrFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the slip. You can fill the fields yourself.'**
  String get ocrFailed;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'This slip is already saved'**
  String get duplicateTitle;

  /// No description provided for @duplicateBody.
  ///
  /// In en, this message translates to:
  /// **'A record with this reference number already exists.'**
  String get duplicateBody;

  /// No description provided for @saveWithoutReference.
  ///
  /// In en, this message translates to:
  /// **'Save without the reference'**
  String get saveWithoutReference;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search note, shop, or category'**
  String get searchHint;

  /// No description provided for @allRecords.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allRecords;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No records match this search'**
  String get noMatches;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Min amount'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max amount'**
  String get maxAmount;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from this device.'**
  String get deleteBody;

  /// No description provided for @reportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to chart in this period'**
  String get reportsEmpty;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @overTime.
  ///
  /// In en, this message translates to:
  /// **'Over time'**
  String get overTime;

  /// No description provided for @byDay.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get byDay;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense'**
  String get incomeVsExpense;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @noBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget set'**
  String get noBudget;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get saveBudget;

  /// No description provided for @removeBudget.
  ///
  /// In en, this message translates to:
  /// **'Remove budget'**
  String get removeBudget;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorTheme;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get ocean;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your money, on this phone'**
  String get appTagline;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZone;

  /// No description provided for @timeZoneAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get timeZoneAutomatic;

  /// No description provided for @timeZoneSearch.
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get timeZoneSearch;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get thai;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @removePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get removePin;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinMismatch;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter 6 digits'**
  String get pinTooShort;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get enterCurrentPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit PIN'**
  String get createPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmNewPin;

  /// No description provided for @pinMismatchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'PINs did not match. Try again.'**
  String get pinMismatchTryAgain;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Face ID / Touch ID'**
  String get biometrics;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are not available on this device'**
  String get biometricsUnavailable;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily expense reminder'**
  String get dailyReminder;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'BahtBuddy'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Remember to record today\'s spending'**
  String get reminderBody;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'File ready to share'**
  String get exportDone;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restoreDone;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'That backup file could not be read'**
  String get restoreFailed;

  /// No description provided for @budgetWarning.
  ///
  /// In en, this message translates to:
  /// **'{category} is at 80% of its monthly budget'**
  String budgetWarning(String category);

  /// No description provided for @budgetReached.
  ///
  /// In en, this message translates to:
  /// **'{category} has reached its monthly budget'**
  String budgetReached(String category);

  /// No description provided for @optionalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo (optional)'**
  String get optionalPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @cashHint.
  ///
  /// In en, this message translates to:
  /// **'Cash spending and income, which have no slip'**
  String get cashHint;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested from the recipient'**
  String get suggested;

  /// No description provided for @spentOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String spentOf(String spent, String limit);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'BahtBuddy is locked'**
  String get lockedTitle;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addRecord;

  /// No description provided for @emptyAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add a record'**
  String get emptyAddCta;

  /// No description provided for @remainingOf.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left'**
  String remainingOf(String remaining);

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(String value);

  /// No description provided for @lockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to see your records'**
  String get lockSubtitle;

  /// No description provided for @filterCategoryChip.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategoryChip;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @monthBalance.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get monthBalance;

  /// No description provided for @emptyHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved on this phone yet. Scan a slip, or add cash by hand.'**
  String get emptyHint;

  /// No description provided for @sampleSlip.
  ///
  /// In en, this message translates to:
  /// **'Try a sample slip'**
  String get sampleSlip;

  /// No description provided for @ocrText.
  ///
  /// In en, this message translates to:
  /// **'Text read from the slip'**
  String get ocrText;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(String count);

  /// No description provided for @sameAsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'About the same as last month'**
  String get sameAsLastMonth;

  /// No description provided for @noSpendingLastMonth.
  ///
  /// In en, this message translates to:
  /// **'No spending last month'**
  String get noSpendingLastMonth;

  /// No description provided for @noIncomeLastMonth.
  ///
  /// In en, this message translates to:
  /// **'No income last month'**
  String get noIncomeLastMonth;

  /// No description provided for @comparedWithLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{change} compared with last month'**
  String comparedWithLastMonth(String change);

  /// No description provided for @bannerSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a little every day'**
  String get bannerSaveTitle;

  /// No description provided for @bannerSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Small habits keep your baht for later.'**
  String get bannerSaveBody;

  /// No description provided for @bannerTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'See where your money goes'**
  String get bannerTrackTitle;

  /// No description provided for @bannerTrackBody.
  ///
  /// In en, this message translates to:
  /// **'A clear month makes saving easier.'**
  String get bannerTrackBody;

  /// No description provided for @safePerDay.
  ///
  /// In en, this message translates to:
  /// **'Safe to spend {amount} a day'**
  String safePerDay(String amount);

  /// No description provided for @nothingLeft.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to spend this month'**
  String get nothingLeft;

  /// No description provided for @overIncome.
  ///
  /// In en, this message translates to:
  /// **'Over this month\'s income by {amount}'**
  String overIncome(String amount);

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get exchangeRates;

  /// No description provided for @exchangeAsOf.
  ///
  /// In en, this message translates to:
  /// **'European Central Bank · {date}'**
  String exchangeAsOf(String date);

  /// No description provided for @exchangeOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect once to load exchange rates'**
  String get exchangeOffline;

  /// No description provided for @exchangeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get exchangeRetry;

  /// No description provided for @convertToBaht.
  ///
  /// In en, this message translates to:
  /// **'Convert to baht'**
  String get convertToBaht;

  /// No description provided for @arrange.
  ///
  /// In en, this message translates to:
  /// **'Arrange'**
  String get arrange;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @arrangeHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the handle and drag a card'**
  String get arrangeHint;

  /// No description provided for @resetLayout.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLayout;

  /// No description provided for @cardTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get cardTips;

  /// No description provided for @cardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get cardShortcuts;

  /// No description provided for @cardSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get cardSpending;

  /// No description provided for @cardWaiting.
  ///
  /// In en, this message translates to:
  /// **'This card fills in after you add records'**
  String get cardWaiting;

  /// No description provided for @reportGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get reportGlance;

  /// No description provided for @keptShare.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get keptShare;

  /// No description provided for @vsLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Vs last period'**
  String get vsLastPeriod;

  /// No description provided for @recordCount.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordCount;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'A day'**
  String get perDay;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @tipEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log income and spending to get a tip for this period.'**
  String get tipEmpty;

  /// No description provided for @tipSteady.
  ///
  /// In en, this message translates to:
  /// **'Income and spending are in a steady range. Keep logging so the next tip can be sharper.'**
  String get tipSteady;

  /// No description provided for @tipOverspent.
  ///
  /// In en, this message translates to:
  /// **'Spending is {amount} above income. Pause the next non-essential buy.'**
  String tipOverspent(String amount);

  /// No description provided for @tipMissingIncome.
  ///
  /// In en, this message translates to:
  /// **'Spending is logged, but income is not. Add income so the balance is true.'**
  String get tipMissingIncome;

  /// No description provided for @tipNoSpending.
  ///
  /// In en, this message translates to:
  /// **'Income is in and nothing went out. This is a good stretch to keep.'**
  String get tipNoSpending;

  /// No description provided for @tipCategory.
  ///
  /// In en, this message translates to:
  /// **'{name} is {percent} of spending. Trimming that category moves the total the most.'**
  String tipCategory(String name, String percent);

  /// No description provided for @tipSpendUp.
  ///
  /// In en, this message translates to:
  /// **'Spending is {percent} higher than the previous period.'**
  String tipSpendUp(String percent);

  /// No description provided for @tipSpendDown.
  ///
  /// In en, this message translates to:
  /// **'Spending is {percent} lower than the previous period.'**
  String tipSpendDown(String percent);

  /// No description provided for @tipThin.
  ///
  /// In en, this message translates to:
  /// **'Only {percent} of income is left. A 20% buffer is a steadier target.'**
  String tipThin(String percent);

  /// No description provided for @tipHealthy.
  ///
  /// In en, this message translates to:
  /// **'You kept {percent} of income. That buffer can cover a surprise bill.'**
  String tipHealthy(String percent);

  /// No description provided for @tipPace.
  ///
  /// In en, this message translates to:
  /// **'At this pace, the rest of the period costs about {amount} more than the balance left.'**
  String tipPace(String amount);

  /// No description provided for @tipLargest.
  ///
  /// In en, this message translates to:
  /// **'The largest record is {amount} in {name}. Check that it was planned.'**
  String tipLargest(String amount, String name);

  /// No description provided for @runningTotal.
  ///
  /// In en, this message translates to:
  /// **'Running total'**
  String get runningTotal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
