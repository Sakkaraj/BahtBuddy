import '../../data/db/app_database.dart';
import 'summary.dart';

enum TipKind {
  empty,
  steady,
  overspent,
  missingIncome,
  noSpending,
  categoryShare,
  spendingUp,
  spendingDown,
  thinBuffer,
  healthyBuffer,
  pace,
  largest,
}

class SpendingTip {
  const SpendingTip({
    required this.kind,
    this.amount = 0,
    this.percent = 0,
    this.label = '',
  });

  final TipKind kind;
  final double amount;
  final int percent;
  final String label;
}

class PeriodFacts {
  const PeriodFacts({
    required this.records,
    required this.dailyExpense,
    required this.spendChange,
    required this.saveRate,
    required this.tips,
  });

  final int records;
  final double dailyExpense;

  /// Change in spending versus the previous period. Null when that period
  /// had no spending to compare.
  final double? spendChange;

  /// Share of income still left. Null when this period has no income.
  final double? saveRate;
  final List<SpendingTip> tips;
}

class _Ranked {
  const _Ranked(this.rank, this.tip);

  final int rank;
  final SpendingTip tip;
}

PeriodFacts reportFacts({
  required List<MoneyTransaction> rows,
  required ReportRange range,
  required ReportRange previous,
  required DateTime now,
  required String Function(int categoryId) categoryName,
}) {
  final current = summarize(rows, range);
  final prior = summarize(rows, previous);
  final records = rows.where((row) => range.contains(row.occurredAt)).length;
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final periodDays = range.end.difference(start).inDays.clamp(1, 62);
  var elapsed = today.difference(start).inDays + 1;
  if (elapsed < 1) elapsed = 1;
  if (elapsed > periodDays) elapsed = periodDays;
  final daily = current.expense / elapsed;
  final spendChange = prior.expense <= 0
      ? null
      : (current.expense - prior.expense) / prior.expense;
  final saveRate = current.income <= 0 ? null : current.balance / current.income;

  final ranked = <_Ranked>[];
  if (records == 0) {
    ranked.add(const _Ranked(1000, SpendingTip(kind: TipKind.empty)));
  } else {
    if (current.expense > current.income && current.income > 0) {
      ranked.add(
        _Ranked(
          100,
          SpendingTip(
            kind: TipKind.overspent,
            amount: current.expense - current.income,
          ),
        ),
      );
    } else if (current.expense > 0 && current.income <= 0) {
      ranked.add(const _Ranked(95, SpendingTip(kind: TipKind.missingIncome)));
    } else if (current.income > 0 && current.expense <= 0) {
      ranked.add(const _Ranked(70, SpendingTip(kind: TipKind.noSpending)));
    }

    if (current.expense > 0 && current.expenseByCategory.isNotEmpty) {
      final top = current.expenseByCategory.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      final share = top.value / current.expense;
      if (share >= 0.4) {
        ranked.add(
          _Ranked(
            80,
            SpendingTip(
              kind: TipKind.categoryShare,
              amount: top.value,
              percent: (share * 100).round(),
              label: categoryName(top.key),
            ),
          ),
        );
      }
      MoneyTransaction? biggest;
      for (final row in rows) {
        if (!range.contains(row.occurredAt) || row.type == 'income') continue;
        if (biggest == null || row.amount > biggest.amount) biggest = row;
      }
      if (biggest != null &&
          current.expenseByCategory.length > 1 &&
          biggest.amount / current.expense >= 0.45) {
        ranked.add(
          _Ranked(
            55,
            SpendingTip(
              kind: TipKind.largest,
              amount: biggest.amount,
              label: categoryName(biggest.categoryId),
            ),
          ),
        );
      }
    }

    if (spendChange != null && spendChange >= 0.15) {
      ranked.add(
        _Ranked(
          65,
          SpendingTip(
            kind: TipKind.spendingUp,
            percent: (spendChange * 100).round(),
          ),
        ),
      );
    } else if (spendChange != null && spendChange <= -0.15) {
      ranked.add(
        _Ranked(
          60,
          SpendingTip(
            kind: TipKind.spendingDown,
            percent: (spendChange.abs() * 100).round(),
          ),
        ),
      );
    }

    if (saveRate != null && current.expense > 0) {
      if (saveRate >= 0 && saveRate < 0.1) {
        ranked.add(
          _Ranked(
            75,
            SpendingTip(
              kind: TipKind.thinBuffer,
              percent: (saveRate * 100).round(),
            ),
          ),
        );
      } else if (saveRate >= 0.2) {
        ranked.add(
          _Ranked(
            50,
            SpendingTip(
              kind: TipKind.healthyBuffer,
              percent: (saveRate * 100).round(),
            ),
          ),
        );
      }
    }

    final left = range.end.difference(today).inDays - 1;
    if (left > 0 &&
        periodDays > 1 &&
        current.expense > 0 &&
        current.balance >= 0) {
      final projected = daily * left;
      if (projected > current.balance + 0.5) {
        ranked.add(
          _Ranked(
            85,
            SpendingTip(kind: TipKind.pace, amount: projected - current.balance),
          ),
        );
      }
    }

    if (ranked.isEmpty) {
      ranked.add(const _Ranked(10, SpendingTip(kind: TipKind.steady)));
    }
  }

  ranked.sort((a, b) => b.rank.compareTo(a.rank));
  final tips = <SpendingTip>[];
  for (final item in ranked) {
    if (tips.length == 3) break;
    if (tips.any((tip) => tip.kind == item.tip.kind)) continue;
    final blocked = item.tip.kind == TipKind.healthyBuffer &&
        tips.any(
          (tip) =>
              tip.kind == TipKind.overspent ||
              tip.kind == TipKind.thinBuffer ||
              tip.kind == TipKind.pace,
        );
    final overspentBlocksThin = item.tip.kind == TipKind.thinBuffer &&
        tips.any((tip) => tip.kind == TipKind.overspent);
    if (blocked || overspentBlocksThin) continue;
    tips.add(item.tip);
  }

  return PeriodFacts(
    records: records,
    dailyExpense: daily,
    spendChange: spendChange,
    saveRate: saveRate,
    tips: tips,
  );
}
