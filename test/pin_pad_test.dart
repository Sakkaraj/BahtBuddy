import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/lock/pin_flow.dart';
import 'package:project/l10n/app_localizations.dart';
import 'package:project/widgets/pin_pad.dart';

void main() {
  Future<void> tapPin(WidgetTester tester, String digits) async {
    for (final digit in digits.split('')) {
      await tester.tap(find.byKey(Key('pin-key-$digit')));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 120));
  }

  testWidgets('six taps complete the pin', (tester) async {
    String? completed;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PinPad(
            title: 'Enter PIN',
            onCompleted: (pin) async {
              completed = pin;
              return true;
            },
          ),
        ),
      ),
    );
    await tapPin(tester, '123456');
    expect(completed, '123456');
  });

  testWidgets('confirm mismatch does not pop a new pin', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await PinFlow.push(context, kind: PinFlowKind.set);
              },
              child: const Text('start'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    expect(find.text('Create a 6-digit PIN'), findsOneWidget);

    await tapPin(tester, '111111');
    await tester.pumpAndSettle();
    expect(find.text('Confirm your PIN'), findsOneWidget);

    await tapPin(tester, '222222');
    await tester.pumpAndSettle();
    expect(find.text('Create a 6-digit PIN'), findsOneWidget);
    expect(find.text('PINs did not match. Try again.'), findsOneWidget);
    expect(result, isNull);

    await tapPin(tester, '111111');
    await tester.pumpAndSettle();
    await tapPin(tester, '111111');
    await tester.pumpAndSettle();
    expect(result, '111111');
  });
}
