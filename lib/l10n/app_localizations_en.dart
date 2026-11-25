// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BahtBuddy';

  @override
  String get navHome => 'Home';

  @override
  String get navAdd => 'Add';

  @override
  String get navHistory => 'History';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get recent => 'Recent';

  @override
  String get seeAll => 'See all';

  @override
  String get emptyTransactions => 'No records yet';

  @override
  String get scanSlip => 'Scan a slip or receipt';

  @override
  String get gallery => 'Photo library';

  @override
  String get camera => 'Camera';

  @override
  String get manualEntry => 'Enter manually';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get note => 'Note';

  @override
  String get recipient => 'Recipient';

  @override
  String get reference => 'Reference';

  @override
  String get type => 'Type';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get requiredAmount => 'Enter an amount greater than 0';

  @override
  String get reviewSlip => 'Review before save';

  @override
  String get parsingSlip => 'Reading the photo…';

  @override
  String get ocrFailed =>
      'Could not read the photo. You can fill the fields yourself.';

  @override
  String get duplicateTitle => 'This slip or receipt is already saved';

  @override
  String get duplicateBody =>
      'A record with this reference number already exists.';

  @override
  String get saveWithoutReference => 'Save without the reference';

  @override
  String get searchHint => 'Search note, shop, or category';

  @override
  String get allRecords => 'All';

  @override
  String get noMatches => 'No records match this search';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get minAmount => 'Min amount';

  @override
  String get maxAmount => 'Max amount';

  @override
  String get allCategories => 'All categories';

  @override
  String get deleteTitle => 'Delete this record?';

  @override
  String get deleteBody => 'It will be removed from this device.';

  @override
  String get reportsEmpty => 'Nothing to chart in this period';

  @override
  String get byCategory => 'By category';

  @override
  String get overTime => 'Over time';

  @override
  String get byDay => 'By day';

  @override
  String get incomeVsExpense => 'Income vs expense';

  @override
  String get budgets => 'Budgets';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get noBudget => 'No budget set';

  @override
  String get saveBudget => 'Save budget';

  @override
  String get removeBudget => 'Remove budget';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get colorTheme => 'Color';

  @override
  String get ocean => 'Ocean';

  @override
  String get appTagline => 'Your money, on this phone';

  @override
  String get language => 'Language';

  @override
  String get timeZone => 'Time zone';

  @override
  String get timeZoneAutomatic => 'Automatic';

  @override
  String get timeZoneSearch => 'Search time zones';

  @override
  String get english => 'English';

  @override
  String get thai => 'ไทย';

  @override
  String get security => 'Security';

  @override
  String get setPin => 'Set PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get removePin => 'Remove PIN';

  @override
  String get pin => 'PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get pinTooShort => 'Enter 6 digits';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get createPin => 'Create a 6-digit PIN';

  @override
  String get confirmNewPin => 'Confirm your PIN';

  @override
  String get pinMismatchTryAgain => 'PINs did not match. Try again.';

  @override
  String get unlock => 'Unlock';

  @override
  String get biometrics => 'Face ID / Touch ID';

  @override
  String get biometricsUnavailable =>
      'Biometrics are not available on this device';

  @override
  String get reminders => 'Reminders';

  @override
  String get dailyReminder => 'Daily expense reminder';

  @override
  String get reminderTitle => 'BahtBuddy';

  @override
  String get reminderBody => 'Remember to record today\'s spending';

  @override
  String get dataSection => 'Data';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get backup => 'Back up';

  @override
  String get restore => 'Restore';

  @override
  String get exportDone => 'File ready to share';

  @override
  String get restoreDone => 'Backup restored';

  @override
  String get restoreFailed => 'That backup file could not be read';

  @override
  String get backupNeedsPin =>
      'Set a PIN first. The backup file is locked with it.';

  @override
  String get backupUnlock => 'Enter your PIN to lock this backup';

  @override
  String get restoreUnlock => 'Enter the PIN that locked this backup';

  @override
  String get wrongBackupPin => 'That PIN does not open this backup';

  @override
  String budgetWarning(String category) {
    return '$category is at 80% of its monthly budget';
  }

  @override
  String budgetReached(String category) {
    return '$category has reached its monthly budget';
  }

  @override
  String get optionalPhoto => 'Receipt photo (optional)';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get saved => 'Saved';

  @override
  String get cashHint =>
      'Bank slip, 7-Eleven, or a restaurant receipt. Or type cash by hand.';

  @override
  String get suggested => 'Suggested from the recipient';

  @override
  String spentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get apply => 'Apply';

  @override
  String get lockedTitle => 'BahtBuddy is locked';

  @override
  String get addRecord => 'Add';

  @override
  String get emptyAddCta => 'Add a record';

  @override
  String remainingOf(String remaining) {
    return '$remaining left';
  }

  @override
  String percentValue(String value) {
    return '$value%';
  }

  @override
  String get lockSubtitle => 'Enter your PIN to see your records';

  @override
  String get filterCategoryChip => 'Category';

  @override
  String get overBudget => 'Over budget';

  @override
  String get monthBalance => 'This month';

  @override
  String get emptyHint =>
      'Nothing is saved on this phone yet. Scan a slip or a receipt, or add cash by hand.';

  @override
  String get sampleSlip => 'Try a sample slip';

  @override
  String get ocrText => 'Text read from the photo';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get topCategory => 'Top category';

  @override
  String daysLeft(String count) {
    return '$count days left';
  }

  @override
  String get sameAsLastMonth => 'About the same as last month';

  @override
  String get noSpendingLastMonth => 'No spending last month';

  @override
  String get noIncomeLastMonth => 'No income last month';

  @override
  String comparedWithLastMonth(String change) {
    return '$change compared with last month';
  }

  @override
  String get bannerSaveTitle => 'Save a little every day';

  @override
  String get bannerSaveBody => 'Small habits keep your baht for later.';

  @override
  String get bannerTrackTitle => 'See where your money goes';

  @override
  String get bannerTrackBody => 'A clear month makes saving easier.';

  @override
  String get mustKnow => 'Must know';

  @override
  String get mustKnowDisclaimer =>
      'A general note. It is not advice for your own money.';

  @override
  String get knowMonthTitle => 'Keep this month\'s money ready';

  @override
  String get knowMonthBody =>
      'Money you plan to spend this month stays in the ledger. Safe to spend is a pace, not a sum to invest.';

  @override
  String get knowBufferTitle => 'A buffer comes first';

  @override
  String get knowBufferBody =>
      'A few months of expenses, set aside, is a common step before buying a fund or a share.';

  @override
  String get knowFeesTitle => 'Fees and inflation stay';

  @override
  String get knowFeesBody =>
      'The amount you keep is the return after fees, and after prices have risen.';

  @override
  String get knowSpreadTitle => 'One price is not a promise';

  @override
  String get knowSpreadBody =>
      'A holding that rose last year can fall. Spreading money limits the damage from one fall.';

  @override
  String get moneyNews => 'Money';

  @override
  String get moneyNewsDisclaimer =>
      'A headline from BBC News. It is not a recommendation.';

  @override
  String get readStory => 'Read the story';

  @override
  String get offerTag => 'Promotion';

  @override
  String get offerSavingsTitle => 'A savings account';

  @override
  String get offerSavingsBody =>
      'Money you may need soon can sit in a savings account at a Thai bank.';

  @override
  String get offerFundTitle => 'A fund for later';

  @override
  String get offerFundBody =>
      'A fund is for money you will not spend this month.';

  @override
  String get offerSpreadTitle => 'More than one holding';

  @override
  String get offerSpreadBody =>
      'Spreading a little across holdings limits the damage from one fall.';

  @override
  String get offerDisclaimer =>
      'A sample promotion. It does not open an account.';

  @override
  String safePaceExplain(String balance, String days) {
    return 'This month\'s balance of $balance is divided by $days days left, including today.';
  }

  @override
  String safePerDay(String amount) {
    return 'Safe to spend $amount a day';
  }

  @override
  String get nothingLeft => 'Nothing left to spend this month';

  @override
  String overIncome(String amount) {
    return 'Over this month\'s income by $amount';
  }

  @override
  String get exchangeRates => 'Exchange rates';

  @override
  String exchangeAsOf(String date) {
    return 'European Central Bank · $date';
  }

  @override
  String get exchangeOffline => 'Connect once to load exchange rates';

  @override
  String get exchangeRetry => 'Try again';

  @override
  String get convertToBaht => 'Convert to baht';

  @override
  String get arrange => 'Arrange';

  @override
  String get done => 'Done';

  @override
  String get arrangeHint => 'Hold the handle and drag a card';

  @override
  String get resetLayout => 'Reset';

  @override
  String get cardTips => 'Tips';

  @override
  String get cardShortcuts => 'Shortcuts';

  @override
  String get cardSpending => 'Spending';

  @override
  String get cardWaiting => 'This card fills in after you add records';

  @override
  String get reportGlance => 'At a glance';

  @override
  String get keptShare => 'Kept';

  @override
  String get vsLastPeriod => 'Vs last period';

  @override
  String get recordCount => 'Records';

  @override
  String get perDay => 'A day';

  @override
  String get forYou => 'For you';

  @override
  String get tipEmpty =>
      'Log income and spending to get a tip for this period.';

  @override
  String get tipSteady =>
      'Income and spending are in a steady range. Keep logging so the next tip can be sharper.';

  @override
  String tipOverspent(String amount) {
    return 'Spending is $amount above income. Pause the next non-essential buy.';
  }

  @override
  String get tipMissingIncome =>
      'Spending is logged, but income is not. Add income so the balance is true.';

  @override
  String get tipNoSpending =>
      'Income is in and nothing went out. This is a good stretch to keep.';

  @override
  String tipCategory(String name, String percent) {
    return '$name is $percent of spending. Trimming that category moves the total the most.';
  }

  @override
  String tipSpendUp(String percent) {
    return 'Spending is $percent higher than the previous period.';
  }

  @override
  String tipSpendDown(String percent) {
    return 'Spending is $percent lower than the previous period.';
  }

  @override
  String tipThin(String percent) {
    return 'Only $percent of income is left. A 20% buffer is a steadier target.';
  }

  @override
  String tipHealthy(String percent) {
    return 'You kept $percent of income. That buffer can cover a surprise bill.';
  }

  @override
  String tipPace(String amount) {
    return 'At this pace, the rest of the period costs about $amount more than the balance left.';
  }

  @override
  String tipLargest(String amount, String name) {
    return 'The largest record is $amount in $name. Check that it was planned.';
  }

  @override
  String get runningTotal => 'Running total';
}
