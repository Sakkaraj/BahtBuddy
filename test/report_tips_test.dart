import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/features/reports/summary.dart';
import 'package:project/features/reports/tips.dart';

MoneyTransaction _row({
  required int id,
  required double amount,
  required String type,
  required int categoryId,
  required DateTime at,
}) {
  return MoneyTransaction(
    id: id,
    amount: amount,
    type: type,
    categoryId: categoryId,
    occurredAt: at,
    note: '',
    recipient: null,
    slipReference: null,
    imagePath: null,
  );
}

void main() {
  const names = {1: 'Food', 2: 'Salary', 3: 'Transport'};
  String name(int id) => names[id] ?? 'Other';

  test('an empty log asks for records before giving a tip', () {
    final now = DateTime(2026, 11, 24);
    final facts = reportFacts(
      rows: const [],
      range: ReportRange.month(now),
      previous: ReportRange.month(DateTime(2026, 10)),
      now: now,
      categoryName: name,
    );
    expect(facts.records, 0);
    expect(facts.tips.single.kind, TipKind.empty);
  });

  test('spending above income points at the largest category', () {
    final now = DateTime(2026, 11, 24);
    final facts = reportFacts(
      rows: [
        _row(
          id: 1,
          amount: 300,
          type: 'income',
          categoryId: 2,
          at: DateTime(2026, 11, 1),
        ),
        _row(
          id: 2,
          amount: 400,
          type: 'expense',
          categoryId: 1,
          at: DateTime(2026, 11, 2),
        ),
        _row(
          id: 3,
          amount: 100,
          type: 'expense',
          categoryId: 3,
          at: DateTime(2026, 11, 3),
        ),
      ],
      range: ReportRange.month(now),
      previous: ReportRange.month(DateTime(2026, 10)),
      now: now,
      categoryName: name,
    );
    expect(facts.tips.map((tip) => tip.kind), contains(TipKind.overspent));
    final category = facts.tips.firstWhere(
      (tip) => tip.kind == TipKind.categoryShare,
    );
    expect(category.label, 'Food');
    expect(category.percent, 80);
    expect(
      facts.tips.firstWhere((tip) => tip.kind == TipKind.overspent).amount,
      200,
    );
  });

  test('a lower spend and a kept buffer are both noticed', () {
    final now = DateTime(2026, 11, 24);
    final facts = reportFacts(
      rows: [
        _row(
          id: 1,
          amount: 1000,
          type: 'income',
          categoryId: 2,
          at: DateTime(2026, 11, 1),
        ),
        _row(
          id: 2,
          amount: 200,
          type: 'expense',
          categoryId: 1,
          at: DateTime(2026, 11, 2),
        ),
        _row(
          id: 3,
          amount: 800,
          type: 'expense',
          categoryId: 1,
          at: DateTime(2026, 10, 4),
        ),
      ],
      range: ReportRange.month(now),
      previous: ReportRange.month(DateTime(2026, 10)),
      now: now,
      categoryName: name,
    );
    expect(facts.spendChange, closeTo(-0.75, 0.001));
    expect(facts.saveRate, closeTo(0.8, 0.001));
    expect(facts.tips.map((tip) => tip.kind), contains(TipKind.spendingDown));
    expect(facts.tips.map((tip) => tip.kind), contains(TipKind.healthyBuffer));
  });

  test('the month pace warns when the daily rate will pass the balance', () {
    final now = DateTime(2026, 11, 24);
    final facts = reportFacts(
      rows: [
        _row(
          id: 1,
          amount: 220,
          type: 'income',
          categoryId: 2,
          at: DateTime(2026, 11, 1),
        ),
        _row(
          id: 2,
          amount: 200,
          type: 'expense',
          categoryId: 1,
          at: DateTime(2026, 11, 2),
        ),
      ],
      range: ReportRange.month(now),
      previous: ReportRange.month(DateTime(2026, 10)),
      now: now,
      categoryName: name,
    );
    expect(facts.tips.map((tip) => tip.kind), contains(TipKind.pace));
  });
}
