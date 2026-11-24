import '../../core/clock.dart';
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

  bool contains(DateTime date) {
    final wall = zoneWall(date);
    return !wall.isBefore(start) && wall.isBefore(end);
  }
}

class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
    required this.incomeByCategory,
  });

  final double income;
  final double expense;
  final Map<int, double> expenseByCategory;
  final Map<int, double> incomeByCategory;

  double get balance => income - expense;
}

class DayPoint {
  const DayPoint(this.day, this.income, this.expense);

  final DateTime day;
  final double income;
  final double expense;
}

List<DayPoint> dailySeries(List<MoneyTransaction> rows, ReportRange range) {
  final count = range.end.difference(range.start).inDays.clamp(1, 62);
  final income = List<double>.filled(count, 0);
  final expense = List<double>.filled(count, 0);
  final origin = DateTime(range.start.year, range.start.month, range.start.day);
  for (final row in rows) {
    if (!range.contains(row.occurredAt)) continue;
    final wall = zoneWall(row.occurredAt);
    final day = DateTime(wall.year, wall.month, wall.day);
    final index = day.difference(origin).inDays;
    if (index < 0 || index >= count) continue;
    if (row.type == 'income') {
      income[index] += row.amount;
    } else {
      expense[index] += row.amount;
    }
  }
  return [
    for (var i = 0; i < count; i++)
      DayPoint(origin.add(Duration(days: i)), income[i], expense[i]),
  ];
}

PeriodSummary summarize(List<MoneyTransaction> rows, ReportRange range) {
  var income = 0.0;
  var expense = 0.0;
  final expenseByCategory = <int, double>{};
  final incomeByCategory = <int, double>{};
  for (final row in rows) {
    if (!range.contains(row.occurredAt)) continue;
    if (row.type == 'income') {
      income += row.amount;
      incomeByCategory[row.categoryId] =
          (incomeByCategory[row.categoryId] ?? 0) + row.amount;
      continue;
    }
    expense += row.amount;
    expenseByCategory[row.categoryId] =
        (expenseByCategory[row.categoryId] ?? 0) + row.amount;
  }
  return PeriodSummary(
    income: income,
    expense: expense,
    expenseByCategory: expenseByCategory,
    incomeByCategory: incomeByCategory,
  );
}
