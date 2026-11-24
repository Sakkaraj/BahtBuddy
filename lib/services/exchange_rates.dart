import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/clock.dart';

class ExchangeBoard {
  const ExchangeBoard({required this.date, required this.bahtPerUnit});

  final DateTime date;
  final Map<String, double> bahtPerUnit;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'rates': bahtPerUnit,
  };

  static ExchangeBoard fromJson(Map<String, dynamic> json) {
    final rates = (json['rates'] as Map).map(
      (key, value) => MapEntry(key as String, (value as num).toDouble()),
    );
    return ExchangeBoard(
      date: DateTime.parse(json['date'] as String),
      bahtPerUnit: rates,
    );
  }
}

const exchangeCodes = ['USD', 'EUR', 'JPY', 'CNY', 'GBP', 'SGD'];

/// How much [code] the baht [balance] buys at this board.
double foreignFromBaht(ExchangeBoard board, String code, double balance) {
  final bahtPerUnit = board.bahtPerUnit[code];
  if (bahtPerUnit == null || bahtPerUnit == 0) return 0;
  return balance / bahtPerUnit;
}

ExchangeBoard parseFrankfurter(String body) {
  final json = jsonDecode(body) as Map<String, dynamic>;
  final raw = (json['rates'] as Map).map(
    (key, value) => MapEntry(key as String, (value as num).toDouble()),
  );
  final thb = raw['THB'];
  if (thb == null || thb == 0) {
    throw const FormatException('Missing baht rate');
  }
  final perUnit = <String, double>{'EUR': thb};
  for (final code in exchangeCodes) {
    if (code == 'EUR') continue;
    final foreign = raw[code];
    if (foreign == null || foreign == 0) continue;
    perUnit[code] = thb / foreign;
  }
  return ExchangeBoard(
    date: calendarDate(json['date'] as String),
    bahtPerUnit: perUnit,
  );
}

/// Frankfurter sends `yyyy-MM-dd`. Keep that calendar day, not a UTC instant.
DateTime calendarDate(String raw) {
  final date = raw.split('T').first;
  final parts = date.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

class ExchangeRates {
  static const _currencies = 'THB,USD,JPY,CNY,GBP,SGD';
  static const latestUrl =
      'https://api.frankfurter.app/latest?from=EUR&to=$_currencies';

  /// European Central Bank board for 23 November 2026. Used when the phone
  /// has no saved board and the network request fails.
  static const bundledBody =
      '{"amount":1.0,"base":"EUR","date":"2026-11-23","rates":{"CNY":7.2905,"GBP":0.83673,"JPY":174.01,"SGD":1.4124,"THB":37.242,"USD":1.0939}}';

  /// Asks for the rate on the active time zone's calendar day. The bank
  /// publishes on European business days, so a weekend or a day before the
  /// fix returns the previous published date.
  static String frankfurterUrl(DateTime day) {
    return 'https://api.frankfurter.app/${zoneDateStamp(day)}'
        '?from=EUR&to=$_currencies';
  }

  static Future<ExchangeBoard> load() async {
    try {
      final fresh = await fetch();
      await _write(fresh);
      return fresh;
    } catch (_) {
      return await _read() ?? parseFrankfurter(bundledBody);
    }
  }

  static Future<ExchangeBoard> fetch() async {
    try {
      return await _get(frankfurterUrl(zoneNow()));
    } catch (_) {
      return _get(latestUrl);
    }
  }

  static Future<ExchangeBoard> _get(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException('Rate request failed');
      }
      return parseFrankfurter(body);
    } finally {
      client.close();
    }
  }

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/exchange_rates.json');
  }

  static Future<void> _write(ExchangeBoard board) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(board.toJson()));
  }

  static Future<ExchangeBoard?> _read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return ExchangeBoard.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
