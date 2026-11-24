import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
    date: DateTime.parse(json['date'] as String),
    bahtPerUnit: perUnit,
  );
}

class ExchangeRates {
  static const _url =
      'https://api.frankfurter.app/latest?from=EUR&to=THB,USD,JPY,CNY,GBP,SGD';

  static Future<ExchangeBoard?> load() async {
    try {
      final fresh = await fetch();
      await _write(fresh);
      return fresh;
    } catch (_) {
      return _read();
    }
  }

  static Future<ExchangeBoard> fetch() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_url));
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
