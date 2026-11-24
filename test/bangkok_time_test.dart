import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/clock.dart';
import 'package:project/core/format.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/features/history/history_filter.dart';
import 'package:project/features/reports/summary.dart';

void main() {
  setUp(() => useTimeZone('Asia/Bangkok'));

  test('20:00 UTC is 03:00 the next morning in Bangkok', () {
    final instant = DateTime.utc(2026, 11, 23, 20);
    final wall = zoneWall(instant);

    expect(wall, DateTime(2026, 11, 24, 3));
    expect(zoneDateStamp(wall), '2026-11-24');
    expect(zoneIso(instant), '2026-11-24T03:00:00+07:00');
    expect(dayKey(instant), DateTime(2026, 11, 24));
    expect(ReportRange.day(DateTime(2026, 11, 24)).contains(instant), isTrue);
    expect(ReportRange.day(DateTime(2026, 11, 23)).contains(instant), isFalse);
  });

  test('history dates follow the Bangkok day across midnight UTC', () {
    final row = MoneyTransaction(
      id: 1,
      amount: 20,
      type: 'expense',
      categoryId: 1,
      occurredAt: DateTime.utc(2026, 11, 23, 18),
      note: '',
      recipient: null,
      slipReference: null,
      imagePath: null,
    );
    expect(
      HistoryFilter(from: DateTime(2026, 11, 24), to: DateTime(2026, 11, 24))
          .matches(row),
      isTrue,
    );
    expect(
      HistoryFilter(from: DateTime(2026, 11, 23), to: DateTime(2026, 11, 23))
          .matches(row),
      isFalse,
    );
  });

  test('a picked Bangkok clock is stored as that Bangkok instant', () {
    final stored = zoneInstant(DateTime(2026, 11, 24, 19, 30));
    expect(stored.timeZoneOffset, const Duration(hours: 7));
    expect(zoneWall(stored), DateTime(2026, 11, 24, 19, 30));
    expect(stored.toUtc(), DateTime.utc(2026, 11, 24, 12, 30));
  });

  test('choosing UTC keeps that same UTC evening on the same day', () {
    useTimeZone('UTC');
    final instant = DateTime.utc(2026, 11, 23, 20);
    expect(zoneWall(instant), DateTime(2026, 11, 23, 20));
    expect(zoneIso(instant), '2026-11-23T20:00:00+00:00');
    expect(ReportRange.day(DateTime(2026, 11, 23)).contains(instant), isTrue);
  });
}
