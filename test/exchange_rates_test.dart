import 'package:flutter_test/flutter_test.dart';
import 'package:project/services/exchange_rates.dart';

void main() {
  test('converts European Central Bank quotes into baht per unit', () {
    const body = '''
{"amount":1.0,"base":"EUR","date":"2026-11-23","rates":{"CNY":7.2905,"GBP":0.83673,"JPY":174.01,"SGD":1.4124,"THB":37.242,"USD":1.0939}}
''';
    final board = parseFrankfurter(body);
    expect(board.bahtPerUnit['EUR'], closeTo(37.242, 0.001));
    expect(board.bahtPerUnit['USD'], closeTo(37.242 / 1.0939, 0.001));
    expect(board.bahtPerUnit['JPY'], closeTo(37.242 / 174.01, 0.0001));
    expect(board.date, DateTime(2026, 11, 23));
    expect(
      ExchangeRates.frankfurterUrl(DateTime(2026, 11, 24, 19)),
      'https://api.frankfurter.app/2026-11-24?from=EUR&to=THB,USD,JPY,CNY,GBP,SGD',
    );
    expect(
      foreignFromBaht(board, 'USD', 280),
      closeTo(280 / (37.242 / 1.0939), 0.001),
    );
    expect(foreignFromBaht(board, 'USD', 0), 0);
  });
}
