import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class HomeLayout {
  static const defaults = [
    'tips',
    'balance',
    'rates',
    'shortcuts',
    'spending',
    'categories',
    'budgets',
    'recent',
  ];

  static List<String> normalize(List<String> saved) {
    final seen = <String>{};
    final result = <String>[];
    for (final id in saved) {
      if (defaults.contains(id) && seen.add(id)) result.add(id);
    }
    for (final id in defaults) {
      if (seen.add(id)) result.add(id);
    }
    return result;
  }

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/home_layout.json');
  }

  static Future<List<String>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return defaults;
      final json = jsonDecode(await file.readAsString());
      if (json is! List) return defaults;
      return normalize(json.whereType<String>().toList());
    } catch (_) {
      return defaults;
    }
  }

  static Future<void> save(List<String> order) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(normalize(order)));
  }
}
