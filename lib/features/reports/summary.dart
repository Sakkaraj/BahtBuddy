import '../../data/db/app_database.dart';

class ReportRange {
  const ReportRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  static ReportRange day(DateTime now) {
    final start = DateTime(now.year, now.month, now.day);
    return ReportRange(start, start.add(const Duration(days: 1)));
  }

  static ReportRange week(DateTime now) {
    final startDay = DateTime(now.year, now.month, now.day);
    final monday = startDay.subtract(Duration(days: startDay.weekday - 1));
    return ReportRange(monday, monday.add(const Duration(days: 7)));
  }

  static ReportRange month(DateTime now) {
    return ReportRange(
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1),
    );
  }

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}

class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
  });

  final double income;
  final double expense;
  final Map<int, double> expenseByCategory;

  double get balance => income - expense;
}

PeriodSummary summarize(List<MoneyTransaction> rows, ReportRange range) {
  var income = 0.0;
  var expense = 0.0;
  final byCategory = <int, double>{};
  for (final row in rows) {
    if (!range.contains(row.occurredAt)) continue;
    if (row.type == 'income') {
      income += row.amount;
      continue;
    }
    expense += row.amount;
    byCategory[row.categoryId] = (byCategory[row.categoryId] ?? 0) + row.amount;
  }
  return PeriodSummary(
    income: income,
    expense: expense,
    expenseByCategory: byCategory,
  );
}
