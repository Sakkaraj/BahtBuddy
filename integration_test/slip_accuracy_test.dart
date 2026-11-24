import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/features/slips/slip_parser.dart';
import 'package:project/features/slips/slip_score.dart';
import 'package:project/services/slip_ocr.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rendered slips recover amount, date, recipient, and reference', (
    tester,
  ) async {
    final manifest = jsonDecode(
      await rootBundle.loadString('assets/slip_corpus/manifest.json'),
    ) as List<dynamic>;
    final directory = await getTemporaryDirectory();
    final ocr = SlipOcr();
    var amount = 0;
    var date = 0;
    var recipient = 0;
    var reference = 0;
    var complete = 0;
    final misses = <String>[];

    for (final row in manifest) {
      final slip = row as Map<String, dynamic>;
      final name = slip['file'] as String;
      final data = await rootBundle.load('assets/slip_corpus/$name');
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      final draft = SlipParser.parse(await ocr.recognize(file.path));
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
      if (score.amount) amount += 1;
      if (score.date) date += 1;
      if (score.recipient) recipient += 1;
      if (score.reference) reference += 1;
      if (score.complete) {
        complete += 1;
      } else {
        misses.add(
          '$name amount=${draft.amount} date=${draft.date} '
          'to=${draft.recipient} ref=${draft.reference}',
        );
      }
    }

    final total = manifest.length;
    // ignore: avoid_print
    print(
      'SLIP_ACCURACY total=$total complete=$complete '
      'amount=$amount date=$date recipient=$recipient reference=$reference',
    );
    for (final miss in misses) {
      // ignore: avoid_print
      print('SLIP_MISS $miss');
    }
    expect(amount, 20);
    expect(date, 20);
    expect(recipient, greaterThanOrEqualTo(19));
    expect(reference, greaterThanOrEqualTo(19));
    expect(complete, greaterThanOrEqualTo(18));
  });
}
