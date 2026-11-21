import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get nameEn => text()();
  TextColumn get nameTh => text()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
}

class MoneyTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get recipient => text().nullable()();
  TextColumn get slipReference => text().nullable().unique()();
  TextColumn get imagePath => text().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().unique().references(Categories, #id)();
  RealColumn get monthlyLimit => real()();
}

class RecipientRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipientKey => text().unique()();
  IntColumn get categoryId => integer().references(Categories, #id)();
}

class Preferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get localeCode => text().withDefault(const Constant('en'))();
  TextColumn get pinHash => text().nullable()();
  BoolColumn get biometricsEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get dailyReminder =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(20))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Categories,
    MoneyTransactions,
    Budgets,
    RecipientRules,
    Preferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'bahtbuddy'));

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
  );

  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(categories, [
        CategoriesCompanion.insert(
          key: 'food',
          nameEn: 'Food',
          nameTh: 'อาหาร',
        ),
        CategoriesCompanion.insert(
          key: 'transport',
          nameEn: 'Transport',
          nameTh: 'เดินทาง',
        ),
        CategoriesCompanion.insert(
          key: 'shopping',
          nameEn: 'Shopping',
          nameTh: 'ช้อปปิ้ง',
        ),
        CategoriesCompanion.insert(
          key: 'bills',
          nameEn: 'Bills',
          nameTh: 'บิล',
        ),
        CategoriesCompanion.insert(
          key: 'entertainment',
          nameEn: 'Entertainment',
          nameTh: 'บันเทิง',
        ),
        CategoriesCompanion.insert(
          key: 'health',
          nameEn: 'Health',
          nameTh: 'สุขภาพ',
        ),
        CategoriesCompanion.insert(
          key: 'education',
          nameEn: 'Education',
          nameTh: 'การศึกษา',
        ),
        CategoriesCompanion.insert(
          key: 'other',
          nameEn: 'Other',
          nameTh: 'อื่นๆ',
        ),
        CategoriesCompanion.insert(
          key: 'salary',
          nameEn: 'Salary',
          nameTh: 'รายได้',
          isIncome: const Value(true),
        ),
      ]);
    });
    await into(preferences).insert(PreferencesCompanion.insert());
  }

  Future<List<Category>> allCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.id)])).get();

  Stream<List<Category>> watchCategories() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.id)])).watch();

  Future<Preference> settings() =>
      (select(preferences)..limit(1)).getSingle();

  Stream<Preference> watchSettings() =>
      (select(preferences)..limit(1)).watchSingle();

  Future<void> saveSettings(PreferencesCompanion data) async {
    final current = await settings();
    await (update(preferences)..where((p) => p.id.equals(current.id))).write(
      data,
    );
  }

  Stream<List<MoneyTransaction>> watchTransactions() => (select(
    moneyTransactions,
  )..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).watch();

  Future<List<MoneyTransaction>> allTransactions() => (select(
    moneyTransactions,
  )..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).get();

  Future<MoneyTransaction?> transactionByReference(String reference) =>
      (select(moneyTransactions)
            ..where((t) => t.slipReference.equals(reference)))
          .getSingleOrNull();

  Future<int> insertTransaction(MoneyTransactionsCompanion row) =>
      into(moneyTransactions).insert(row);

  Future<void> updateTransaction(int id, MoneyTransactionsCompanion row) =>
      (update(moneyTransactions)..where((t) => t.id.equals(id))).write(row);

  Future<void> deleteTransaction(int id) =>
      (delete(moneyTransactions)..where((t) => t.id.equals(id))).go();

  Future<double> expenseSpent({
    required int categoryId,
    required DateTime start,
    required DateTime end,
    int? excludingId,
  }) async {
    final rows =
        await (select(moneyTransactions)..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.type.equals('expense') &
                  t.occurredAt.isBiggerOrEqualValue(start) &
                  t.occurredAt.isSmallerThanValue(end),
            ))
            .get();
    var total = 0.0;
    for (final row in rows) {
      if (excludingId != null && row.id == excludingId) continue;
      total += row.amount;
    }
    return total;
  }

  Stream<List<Budget>> watchBudgets() => select(budgets).watch();

  Future<Budget?> budgetFor(int categoryId) => (select(
    budgets,
  )..where((b) => b.categoryId.equals(categoryId))).getSingleOrNull();

  Future<void> upsertBudget(int categoryId, double limit) async {
    final existing = await budgetFor(categoryId);
    if (existing == null) {
      await into(budgets).insert(
        BudgetsCompanion.insert(categoryId: categoryId, monthlyLimit: limit),
      );
    } else {
      await (update(budgets)..where((b) => b.id.equals(existing.id))).write(
        BudgetsCompanion(monthlyLimit: Value(limit)),
      );
    }
  }

  Future<void> deleteBudgetFor(int categoryId) =>
      (delete(budgets)..where((b) => b.categoryId.equals(categoryId))).go();

  Future<int?> learnedCategoryId(String recipientKey) async {
    final row = await (select(
      recipientRules,
    )..where((r) => r.recipientKey.equals(recipientKey))).getSingleOrNull();
    return row?.categoryId;
  }

  Future<void> learnRecipient(String recipientKey, int categoryId) async {
    final existing = await (select(
      recipientRules,
    )..where((r) => r.recipientKey.equals(recipientKey))).getSingleOrNull();
    if (existing == null) {
      await into(recipientRules).insert(
        RecipientRulesCompanion.insert(
          recipientKey: recipientKey,
          categoryId: categoryId,
        ),
      );
    } else {
      await (update(recipientRules)..where((r) => r.id.equals(existing.id)))
          .write(RecipientRulesCompanion(categoryId: Value(categoryId)));
    }
  }

  Future<void> replaceAll(BackupPayload payload) {
    return transaction(() async {
      await delete(moneyTransactions).go();
      await delete(budgets).go();
      await delete(recipientRules).go();
      await delete(categories).go();
      await delete(preferences).go();
      for (final category in payload.categories) {
        await into(categories).insert(
          CategoriesCompanion(
            id: Value(category.id),
            key: Value(category.key),
            nameEn: Value(category.nameEn),
            nameTh: Value(category.nameTh),
            isIncome: Value(category.isIncome),
          ),
        );
      }
      await into(preferences).insert(
        PreferencesCompanion.insert(
          themeMode: Value(payload.themeMode),
          localeCode: Value(payload.localeCode),
          pinHash: Value(payload.pinHash),
          biometricsEnabled: Value(payload.biometricsEnabled),
          dailyReminder: Value(payload.dailyReminder),
          reminderHour: Value(payload.reminderHour),
          reminderMinute: Value(payload.reminderMinute),
        ),
      );
      for (final rule in payload.rules) {
        await into(recipientRules).insert(
          RecipientRulesCompanion.insert(
            recipientKey: rule.recipientKey,
            categoryId: rule.categoryId,
          ),
        );
      }
      for (final budget in payload.budgets) {
        await into(budgets).insert(
          BudgetsCompanion.insert(
            categoryId: budget.categoryId,
            monthlyLimit: budget.monthlyLimit,
          ),
        );
      }
      for (final row in payload.transactions) {
        await into(moneyTransactions).insert(
          MoneyTransactionsCompanion.insert(
            amount: row.amount,
            type: row.type,
            categoryId: row.categoryId,
            occurredAt: row.occurredAt,
            note: Value(row.note),
            recipient: Value(row.recipient),
            slipReference: Value(row.slipReference),
            imagePath: Value(row.imagePath),
          ),
        );
      }
    });
  }
}

class BackupPayload {
  const BackupPayload({
    required this.categories,
    required this.transactions,
    required this.budgets,
    required this.rules,
    required this.themeMode,
    required this.localeCode,
    required this.pinHash,
    required this.biometricsEnabled,
    required this.dailyReminder,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final List<Category> categories;
  final List<MoneyTransaction> transactions;
  final List<Budget> budgets;
  final List<RecipientRule> rules;
  final String themeMode;
  final String localeCode;
  final String? pinHash;
  final bool biometricsEnabled;
  final bool dailyReminder;
  final int reminderHour;
  final int reminderMinute;
}
