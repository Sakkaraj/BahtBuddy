import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/pin_hash.dart';

void main() {
  test('a new hash matches only the same pin', () {
    final stored = hashPin('135790');
    expect(pinMatches('135790', stored), isTrue);
    expect(pinMatches('135791', stored), isFalse);
    expect(pinHashIsCurrent(stored), isTrue);
    expect(hashPin('135790'), isNot(stored));
  });

  test('an older unsalted hash still unlocks', () {
    final legacy = sha256.convert(utf8.encode('bahtbuddy::246810')).toString();
    expect(pinMatches('246810', legacy), isTrue);
    expect(pinMatches('246811', legacy), isFalse);
    expect(pinHashIsCurrent(legacy), isFalse);
  });
}
