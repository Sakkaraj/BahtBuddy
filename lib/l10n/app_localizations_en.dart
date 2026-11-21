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
  String get scanSlip => 'Scan a slip';

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
  String get reviewSlip => 'Review slip';

  @override
  String get parsingSlip => 'Reading slip…';

  @override
  String get ocrFailed =>
      'Could not read the slip. You can fill the fields yourself.';

  @override
  String get duplicateTitle => 'This slip is already saved';

  @override
  String get duplicateBody =>
      'A record with this reference number already exists.';

  @override
  String get saveWithoutReference => 'Save without the reference';

  @override
  String get searchHint => 'Search note, recipient, or reference';

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
  String get language => 'Language';

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
  String get cashHint => 'Cash spending and income, which have no slip';

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
}
