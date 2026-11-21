import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/data/repositories/transaction_repository.dart';

void main() {
  test('a stored slip reference is rejected', () async {
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final repo = TransactionRepository(database);
    final food = (await database.allCategories()).firstWhere(
      (c) => c.key == 'food',
    );
    final draft = TransactionDraft(
      amount: 65,
      type: 'expense',
      categoryId: food.id,
      occurredAt: DateTime(2026, 11, 17),
      slipReference: 'REF123456',
      recipient: '7-Eleven',
    );

    expect(await repo.save(draft), SaveStatus.saved);
    expect(await repo.save(draft), SaveStatus.duplicate);
    expect(
      await repo.save(
        TransactionDraft(
          amount: 10,
          type: 'expense',
          categoryId: food.id,
          occurredAt: DateTime(2026, 11, 17),
        ),
      ),
      SaveStatus.saved,
    );
    expect(await repo.suggestKey('7-Eleven'), 'food');

    final learned = (await database.allCategories()).firstWhere(
      (c) => c.key == 'shopping',
    );
    await repo.save(
      TransactionDraft(
        amount: 20,
        type: 'expense',
        categoryId: learned.id,
        occurredAt: DateTime(2026, 11, 18),
        recipient: '7-Eleven',
      ),
    );
    expect(await repo.suggestKey('7-Eleven'), 'shopping');
  });
}
