import 'package:drift/drift.dart';

import '../../features/slips/category_suggester.dart';
import '../db/app_database.dart';

enum SaveStatus { saved, duplicate }

class TransactionDraft {
  const TransactionDraft({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.occurredAt,
    this.note = '',
    this.recipient,
    this.slipReference,
    this.imagePath,
  });

  final int? id;
  final double amount;
  final String type;
  final int categoryId;
  final DateTime occurredAt;
  final String note;
  final String? recipient;
  final String? slipReference;
  final String? imagePath;
}

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Future<SaveStatus> save(TransactionDraft draft) async {
    final reference = _blankToNull(draft.slipReference);
    if (reference != null) {
      final existing = await _db.transactionByReference(reference);
      if (existing != null && existing.id != draft.id) {
        return SaveStatus.duplicate;
      }
    }
    final companion = MoneyTransactionsCompanion(
      amount: Value(draft.amount),
      type: Value(draft.type),
      categoryId: Value(draft.categoryId),
      occurredAt: Value(draft.occurredAt),
      note: Value(draft.note),
      recipient: Value(_blankToNull(draft.recipient)),
      slipReference: Value(reference),
      imagePath: Value(_blankToNull(draft.imagePath)),
    );
    if (draft.id == null) {
      await _db.insertTransaction(companion);
    } else {
      await _db.updateTransaction(draft.id!, companion);
    }
    final recipient = _blankToNull(draft.recipient);
    if (recipient != null) {
      await _db.learnRecipient(
        CategorySuggester.normalize(recipient),
        draft.categoryId,
      );
    }
    return SaveStatus.saved;
  }

  Future<String?> suggestKey(String? recipient) async {
    final normalized = CategorySuggester.normalize(recipient ?? '');
    String? learnedKey;
    if (normalized.isNotEmpty) {
      final id = await _db.learnedCategoryId(normalized);
      if (id != null) {
        final categories = await _db.allCategories();
        for (final category in categories) {
          if (category.id == id) {
            learnedKey = category.key;
            break;
          }
        }
      }
    }
    return CategorySuggester.suggest(
      recipient: recipient,
      learnedKey: learnedKey,
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
