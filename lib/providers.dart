import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'services/budget_alerts.dart';
import 'services/slip_ocr.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(databaseProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(databaseProvider));
});

final budgetAlertsProvider = Provider<BudgetAlerts>((ref) => BudgetAlerts());

final slipOcrProvider = Provider<SlipOcr>((ref) => SlipOcr());

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).watchCategories();
});

final transactionsProvider = StreamProvider<List<MoneyTransaction>>((ref) {
  return ref.watch(databaseProvider).watchTransactions();
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(databaseProvider).watchBudgets();
});

final settingsProvider = AsyncNotifierProvider<SettingsController, Preference>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<Preference> {
  @override
  Future<Preference> build() => ref.watch(databaseProvider).settings();

  Future<void> setTheme(String mode) =>
      _write(PreferencesCompanion(themeMode: Value(mode)));

  Future<void> setLocale(String code) =>
      _write(PreferencesCompanion(localeCode: Value(code)));

  Future<void> setPin(String? hash) => _write(
    PreferencesCompanion(
      pinHash: Value(hash),
      biometricsEnabled: hash == null
          ? const Value(false)
          : const Value.absent(),
    ),
  );

  Future<void> setBiometrics(bool enabled) =>
      _write(PreferencesCompanion(biometricsEnabled: Value(enabled)));

  Future<void> setReminder({required bool enabled}) =>
      _write(PreferencesCompanion(dailyReminder: Value(enabled)));

  Future<void> _write(PreferencesCompanion data) async {
    final db = ref.read(databaseProvider);
    await db.saveSettings(data);
    state = AsyncData(await db.settings());
  }
}

final sessionUnlockedProvider = NotifierProvider<SessionUnlocked, bool>(
  SessionUnlocked.new,
);

class SessionUnlocked extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}

final suppressLockProvider = NotifierProvider<SuppressLock, bool>(
  SuppressLock.new,
);

class SuppressLock extends Notifier<bool> {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}
