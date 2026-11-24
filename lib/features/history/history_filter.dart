import '../../data/db/app_database.dart';

class HistoryFilter {
  const HistoryFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.from,
    this.to,
    this.minAmount,
    this.maxAmount,
  });

  final String query;
  final String? type;
  final int? categoryId;
  final DateTime? from;
  final DateTime? to;
  final double? minAmount;
  final double? maxAmount;

  bool get isActive =>
      categoryId != null ||
      from != null ||
      to != null ||
      minAmount != null ||
      maxAmount != null;

  bool matches(MoneyTransaction row, {String categoryText = ''}) {
    if (type != null && row.type != type) return false;
    if (categoryId != null && row.categoryId != categoryId) return false;
    if (from != null && row.occurredAt.isBefore(from!)) return false;
    if (to != null) {
      final end = DateTime(to!.year, to!.month, to!.day + 1);
      if (!row.occurredAt.isBefore(end)) return false;
    }
    if (minAmount != null && row.amount < minAmount!) return false;
    if (maxAmount != null && row.amount > maxAmount!) return false;
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    final haystack =
        '${row.note} ${row.recipient ?? ''} ${row.slipReference ?? ''} $categoryText'
            .toLowerCase();
    return haystack.contains(needle);
  }
}
