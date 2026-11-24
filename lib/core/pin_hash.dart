import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Iterations for a new PIN hash. High enough to slow a 6-digit search.
const pinHashRounds = 8000;

/// Stored form is `v2.<salt>.<rounds>.<digest>`. Older rows are one SHA-256
/// of `bahtbuddy::` plus the digits, and those still unlock.
String hashPin(String pin) {
  final salt = _salt();
  return 'v2.$salt.$pinHashRounds.${_stretch(pin, salt, pinHashRounds)}';
}

bool pinMatches(String pin, String stored) {
  if (!stored.startsWith('v2.')) {
    return sha256.convert(utf8.encode('bahtbuddy::$pin')).toString() == stored;
  }
  final parts = stored.split('.');
  if (parts.length != 4) return false;
  final rounds = int.tryParse(parts[2]);
  if (rounds == null || rounds < 1 || rounds > 100000) return false;
  return _stretch(pin, parts[1], rounds) == parts[3];
}

bool pinHashIsCurrent(String stored) =>
    stored.startsWith('v2.') && stored.split('.').elementAtOrNull(2) == '$pinHashRounds';

String _salt() {
  final random = Random.secure();
  return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
}

String _stretch(String pin, String salt, int rounds) {
  List<int> digest = utf8.encode('$salt::$pin');
  for (var i = 0; i < rounds; i++) {
    digest = sha256.convert(digest).bytes;
  }
  return base64Url.encode(digest);
}
