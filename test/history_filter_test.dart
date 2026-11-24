import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/features/history/history_filter.dart';

MoneyTransaction _row({
  required int id,
  required String type,
  required String note,
  String? recipient,
}) {
  return MoneyTransaction(
    id: id,
    amount: 20,
    type: type,
    categoryId: 1,
    occurredAt: DateTime(2026, 11, 24),
    note: note,
    recipient: recipient,
    slipReference: null,
    imagePath: null,
  );
}

void main() {
  test('search matches the category name as well as the note', () {
    const filter = HistoryFilter(query: 'food');
    final row = _row(id: 1, type: 'expense', note: '');
    expect(filter.matches(row), isFalse);
    expect(filter.matches(row, categoryText: 'Food อาหาร'), isTrue);
  });

  test('type keeps income and expense apart', () {
    const expenses = HistoryFilter(type: 'expense');
    final salary = _row(id: 2, type: 'income', note: 'salary');
    final lunch = _row(id: 3, type: 'expense', note: 'lunch', recipient: 'cafe');
    expect(expenses.matches(salary), isFalse);
    expect(expenses.matches(lunch), isTrue);
    expect(const HistoryFilter(query: 'cafe').matches(lunch), isTrue);
  });
}
