import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart' as csvlib;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';

class BackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  Future<File> exportCsv() async {
    final categories = {for (final c in await _db.allCategories()) c.id: c};
    final rows = <List<dynamic>>[
      [
        'date',
        'type',
        'category',
        'amount',
        'note',
        'recipient',
        'reference',
      ],
    ];
    for (final row in await _db.allTransactions()) {
      rows.add([
        row.occurredAt.toIso8601String(),
        row.type,
        categories[row.categoryId]?.nameEn ?? '',
        row.amount.toStringAsFixed(2),
        row.note,
        row.recipient ?? '',
        row.slipReference ?? '',
      ]);
    }
    return _writeTemp('bahtbuddy.csv', csvlib.csv.encode(rows));
  }

  Future<File> exportBackup() async {
    final settings = await _db.settings();
    final payload = {
      'version': 1,
      'categories': [
        for (final c in await _db.allCategories())
          {
            'id': c.id,
            'key': c.key,
            'nameEn': c.nameEn,
            'nameTh': c.nameTh,
            'isIncome': c.isIncome,
          },
      ],
      'transactions': [
        for (final t in await _db.allTransactions())
          {
            'amount': t.amount,
            'type': t.type,
            'categoryId': t.categoryId,
            'occurredAt': t.occurredAt.toIso8601String(),
            'note': t.note,
            'recipient': t.recipient,
            'slipReference': t.slipReference,
            'imagePath': t.imagePath,
          },
      ],
      'budgets': [
        for (final b in await _db.watchBudgets().first)
          {'categoryId': b.categoryId, 'monthlyLimit': b.monthlyLimit},
      ],
      'rules': [
        for (final r in await (_db.select(_db.recipientRules)).get())
          {'recipientKey': r.recipientKey, 'categoryId': r.categoryId},
      ],
      'preferences': {
        'themeMode': settings.themeMode,
        'localeCode': settings.localeCode,
        'pinHash': settings.pinHash,
        'biometricsEnabled': settings.biometricsEnabled,
        'dailyReminder': settings.dailyReminder,
        'reminderHour': settings.reminderHour,
        'reminderMinute': settings.reminderMinute,
      },
    };
    return _writeTemp(
      'bahtbuddy-backup.json',
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  Future<void> restore(String jsonText) async {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map || decoded['version'] != 1) {
      throw const FormatException('Unsupported backup');
    }
    final categories = <Category>[
      for (final raw in decoded['categories'] as List)
        Category(
          id: raw['id'] as int,
          key: raw['key'] as String,
          nameEn: raw['nameEn'] as String,
          nameTh: raw['nameTh'] as String,
          isIncome: raw['isIncome'] as bool,
        ),
    ];
    final transactions = <MoneyTransaction>[
      for (final raw in decoded['transactions'] as List)
        MoneyTransaction(
          id: 0,
          amount: (raw['amount'] as num).toDouble(),
          type: raw['type'] as String,
          categoryId: raw['categoryId'] as int,
          occurredAt: DateTime.parse(raw['occurredAt'] as String),
          note: raw['note'] as String? ?? '',
          recipient: raw['recipient'] as String?,
          slipReference: raw['slipReference'] as String?,
          imagePath: raw['imagePath'] as String?,
        ),
    ];
    final budgets = <Budget>[
      for (final raw in decoded['budgets'] as List)
        Budget(
          id: 0,
          categoryId: raw['categoryId'] as int,
          monthlyLimit: (raw['monthlyLimit'] as num).toDouble(),
        ),
    ];
    final rules = <RecipientRule>[
      for (final raw in decoded['rules'] as List)
        RecipientRule(
          id: 0,
          recipientKey: raw['recipientKey'] as String,
          categoryId: raw['categoryId'] as int,
        ),
    ];
    final prefs = decoded['preferences'] as Map;
    await _db.replaceAll(
      BackupPayload(
        categories: categories,
        transactions: transactions,
        budgets: budgets,
        rules: rules,
        themeMode: prefs['themeMode'] as String? ?? 'system',
        localeCode: prefs['localeCode'] as String? ?? 'en',
        pinHash: prefs['pinHash'] as String?,
        biometricsEnabled: prefs['biometricsEnabled'] as bool? ?? false,
        dailyReminder: prefs['dailyReminder'] as bool? ?? false,
        reminderHour: prefs['reminderHour'] as int? ?? 20,
        reminderMinute: prefs['reminderMinute'] as int? ?? 0,
      ),
    );
  }

  Future<File> _writeTemp(String name, String contents) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    return file.writeAsString(contents);
  }
}
