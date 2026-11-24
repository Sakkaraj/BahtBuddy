import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/slips/slip_parser.dart';
import 'package:project/features/slips/slip_score.dart';

void main() {
  test('every labeled slip text parses to its recorded fields', () {
    final manifest = jsonDecode(
      File('assets/slip_corpus/manifest.json').readAsStringSync(),
    ) as List<dynamic>;
    expect(manifest, hasLength(20));
    for (final row in manifest) {
      final slip = row as Map<String, dynamic>;
      final draft = SlipParser.parse(slip['text'] as String);
      final score = scoreSlip(
        amount: draft.amount,
        date: draft.date,
        recipient: draft.recipient,
        reference: draft.reference,
        expectedAmount: (slip['amount'] as num).toDouble(),
        expectedDate: DateTime.parse(slip['date'] as String),
        expectedRecipient: slip['recipient'] as String,
        expectedReference: slip['reference'] as String,
      );
      expect(score.complete, isTrue, reason: slip['file'] as String);
    }
  });
}
