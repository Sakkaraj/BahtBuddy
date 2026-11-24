import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/backup_crypto.dart';
import 'package:project/core/pin_hash.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/data/repositories/backup_repository.dart';
import 'package:project/data/repositories/transaction_repository.dart';

void main() {
  test('the wrong pin does not open a sealed backup', () {
    final sealed = sealBackup('{"version":1}', '135790');
    expect(backupIsSealed(sealed), isTrue);
    expect(openBackup(sealed, '135790'), '{"version":1}');
    expect(openBackup(sealed, '000000'), isNull);
    expect(sealed.contains('version":1'), isFalse);
  });

  test('an encrypted backup restores the ledger and the pin', () async {
    final source = AppDatabase.memory();
    addTearDown(source.close);
    final food = (await source.allCategories()).firstWhere((c) => c.key == 'food');
    await TransactionRepository(source).save(
      TransactionDraft(
        amount: 20,
        type: 'expense',
        categoryId: food.id,
        occurredAt: DateTime(2026, 11, 24),
        note: 'secret-note',
      ),
    );
    final text = await BackupRepository(source).backupText('135790');
    expect(text.contains('secret-note'), isFalse);

    final target = AppDatabase.memory();
    addTearDown(target.close);
    await BackupRepository(target).restore(text, pin: '135790');
    final rows = await target.allTransactions();
    expect(rows.single.note, 'secret-note');
    expect(rows.single.amount, 20);
    expect(pinMatches('135790', (await target.settings()).pinHash!), isTrue);
    expect(
      () => BackupRepository(target).restore(text, pin: '000000'),
      throwsFormatException,
    );
  });
}
