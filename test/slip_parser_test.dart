import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/budgets/budget_math.dart';
import 'package:project/features/slips/category_suggester.dart';
import 'package:project/features/slips/slip_parser.dart';

void main() {
  test('parses a labeled Thai slip', () {
    final draft = SlipParser.parse('''
โอนเงินสำเร็จ
จำนวนเงิน 65.00 บาท
วันที่ 17/11/2026 12:30
ไปยัง 7-Eleven
เลขที่รายการ 20261117000123
''');
    expect(draft.amount, 65);
    expect(draft.date, DateTime(2026, 11, 17, 12, 30));
    expect(draft.recipient, '7-Eleven');
    expect(draft.reference, '20261117000123');
  });

  test('parses an English PromptPay slip', () {
    final draft = SlipParser.parse('''
PromptPay
Amount: THB 1,250.50
Date: 01 Nov 2026
To: BTS
Ref: ABC123456789
''');
    expect(draft.amount, 1250.50);
    expect(draft.date, DateTime(2026, 11, 1));
    expect(draft.recipient, 'BTS');
    expect(draft.reference, 'ABC123456789');
  });

  test('reads a bare amount when OCR drops the baht label', () {
    final draft = SlipParser.parse('''
65.00
17/11/2026 12:30
To: 7-Eleven
Ref: REF650001
''');
    expect(draft.amount, 65);
    expect(draft.date, DateTime(2026, 11, 17, 12, 30));
    expect(draft.recipient, '7-Eleven');
    expect(draft.reference, 'REF650001');
    expect(
      CategorySuggester.suggest(recipient: draft.recipient),
      'food',
    );
  });

  test('parses a Buddhist-year slip and leaves gaps empty', () {
    final draft = SlipParser.parse('''
โอนเงิน
120.00 บาท
17 พ.ย. 2569
ผู้รับ GrabFood
เลขอ้างอิง TX99887766
''');
    expect(draft.amount, 120);
    expect(draft.date, DateTime(2026, 11, 17));
    expect(draft.recipient, 'GrabFood');
    expect(draft.reference, 'TX99887766');

    final empty = SlipParser.parse('สลิป\nขอบคุณที่ใช้บริการ');
    expect(empty.amount, isNull);
    expect(empty.date, isNull);
    expect(empty.recipient, isNull);
    expect(empty.reference, isNull);
  });

  test('suggests a category and prefers a learned correction', () {
    expect(
      CategorySuggester.suggest(recipient: '7-Eleven Sukhumvit'),
      'food',
    );
    expect(CategorySuggester.suggest(recipient: 'BTS Asok'), 'transport');
    expect(CategorySuggester.suggest(recipient: 'GrabFood'), 'food');
    expect(CategorySuggester.suggest(recipient: 'Grab'), 'transport');
    expect(
      CategorySuggester.suggest(recipient: 'ค่าเทอม มหาวิทยาลัย'),
      'education',
    );
    expect(CategorySuggester.suggest(recipient: 'unknown shop'), isNull);
    expect(
      CategorySuggester.suggest(
        recipient: '7-Eleven',
        learnedKey: 'shopping',
      ),
      'shopping',
    );
  });

  test('budget levels cross 80 and 100 percent once', () {
    expect(budgetLevel(79, 100), BudgetLevel.under);
    expect(budgetLevel(80, 100), BudgetLevel.warning);
    expect(budgetLevel(100, 100), BudgetLevel.reached);
    expect(
      budgetCrossing(previousSpent: 70, nextSpent: 85, limit: 100),
      BudgetCrossing.warning,
    );
    expect(
      budgetCrossing(previousSpent: 90, nextSpent: 110, limit: 100),
      BudgetCrossing.reached,
    );
    expect(
      budgetCrossing(previousSpent: 85, nextSpent: 90, limit: 100),
      BudgetCrossing.none,
    );
  });

  test('duplicate references ignore blanks and the row being edited', () {
    expect(
      isDuplicateReference(
        reference: 'ABC123456',
        existingReference: 'ABC123456',
        existingId: 4,
        editingId: null,
      ),
      isTrue,
    );
    expect(
      isDuplicateReference(
        reference: 'ABC123456',
        existingReference: 'ABC123456',
        existingId: 4,
        editingId: 4,
      ),
      isFalse,
    );
    expect(
      isDuplicateReference(
        reference: '   ',
        existingReference: 'ABC123456',
        existingId: 4,
        editingId: null,
      ),
      isFalse,
    );
  });
}
