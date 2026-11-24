import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/data/db/app_database.dart';
import 'package:project/features/entry/entry_screen.dart';
import 'package:project/features/slips/slip_parser.dart';
import 'package:project/l10n/app_localizations.dart';
import 'package:project/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpEntry(WidgetTester tester, {EntryArgs? args}) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EntryScreen(args: args),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('manual entry saves an expense', (tester) async {
    await pumpEntry(tester);
    await tester.enterText(find.byKey(const Key('amount-field')), '65');
    await tester.ensureVisible(find.byKey(const Key('save-entry')));
    await tester.ensureVisible(find.byKey(const Key('save-entry')));
    await tester.tap(find.byKey(const Key('save-entry')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final rows = await database.allTransactions();
    expect(rows, hasLength(1));
    expect(rows.single.amount, 65);
    expect(rows.single.type, 'expense');
    final categories = await database.allCategories();
    final food = categories.firstWhere((c) => c.key == 'food');
    expect(rows.single.categoryId, food.id);
    await disposeTree(tester);
  });

  testWidgets('slip confirmation keeps parsed fields', (tester) async {
    await pumpEntry(
      tester,
      args: EntryArgs(
        draft: const SlipDraft(
          amount: 65,
          recipient: '7-Eleven',
          reference: 'REF123456',
          rawText: 'sample',
        ),
      ),
    );

    expect(find.text('65.00'), findsOneWidget);
    expect(find.text('7-Eleven'), findsOneWidget);
    expect(find.text('REF123456'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('save-entry')));
    await tester.ensureVisible(find.byKey(const Key('save-entry')));
    await tester.tap(find.byKey(const Key('save-entry')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final rows = await database.allTransactions();
    expect(rows.single.amount, 65);
    expect(rows.single.recipient, '7-Eleven');
    expect(rows.single.slipReference, 'REF123456');
    final food = (await database.allCategories()).firstWhere(
      (c) => c.key == 'food',
    );
    expect(rows.single.categoryId, food.id);
    await disposeTree(tester);
  });
}
