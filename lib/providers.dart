import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/clock.dart';
import 'data/db/app_database.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'services/budget_alerts.dart';
import 'services/exchange_rates.dart';
import 'services/home_layout.dart';
import 'services/money_posts.dart';
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

final exchangeRatesProvider =
    AsyncNotifierProvider<ExchangeRatesController, ExchangeBoard>(
      ExchangeRatesController.new,
    );

class ExchangeRatesController extends AsyncNotifier<ExchangeBoard> {
  @override
  Future<ExchangeBoard> build() => ExchangeRates.load();

  Future<void> refresh() async {
    state = AsyncData(await ExchangeRates.load());
  }
}

final moneyPostsProvider =
    AsyncNotifierProvider<MoneyPostsController, List<MoneyPost>>(
      MoneyPostsController.new,
    );

/// Changes on every visit so the banner shuffles even when the headlines match.
final bannerMixProvider = NotifierProvider<BannerMix, int>(BannerMix.new);

class BannerMix extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state++;
}

class MoneyPostsController extends AsyncNotifier<List<MoneyPost>> {
  @override
  Future<List<MoneyPost>> build() async {
    final posts = await MoneyPosts.load();
    _mixAgain();
    return posts;
  }

  Future<void> refresh() async {
    state = AsyncData(await MoneyPosts.load());
    _mixAgain();
  }

  void _mixAgain() {
    Future.microtask(() {
      if (!ref.mounted) return;
      ref.read(bannerMixProvider.notifier).next();
    });
  }
}

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

  Future<void> setTimeZone(String id) async {
    await _write(PreferencesCompanion(timeZoneId: Value(id)));
    await applyTimeZone(id);
  }

  Future<void> _write(PreferencesCompanion data) async {
    final db = ref.read(databaseProvider);
    await db.saveSettings(data);
    state = AsyncData(await db.settings());
  }
}

final timeZoneProvider = NotifierProvider<TimeZoneController, String>(
  TimeZoneController.new,
);

class TimeZoneController extends Notifier<String> {
  @override
  String build() {
    final choice =
        ref.watch(settingsProvider).asData?.value.timeZoneId ?? autoTimeZone;
    final shown = activeZoneId;
    Future<void>(() async {
      await applyTimeZone(choice);
      if (!ref.mounted || state == activeZoneId) return;
      state = activeZoneId;
    });
    return shown;
  }
}

final homeLayoutProvider =
    AsyncNotifierProvider<HomeLayoutController, List<String>>(
      HomeLayoutController.new,
    );

class HomeLayoutController extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => HomeLayout.load();

  Future<void> move(int oldIndex, int newIndex) async {
    final current = List<String>.of(state.asData?.value ?? HomeLayout.defaults);
    if (oldIndex < 0 ||
        oldIndex >= current.length ||
        newIndex < 0 ||
        newIndex >= current.length) {
      return;
    }
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    state = AsyncData(current);
    await HomeLayout.save(current);
  }

  Future<void> reset() async {
    state = const AsyncData(HomeLayout.defaults);
    await HomeLayout.save(HomeLayout.defaults);
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
