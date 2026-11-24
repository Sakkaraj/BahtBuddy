import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/clock.dart';
import '../core/format.dart';
import '../data/db/app_database.dart';
import '../features/reports/summary.dart';
import '../l10n/app_localizations.dart';
import 'motion.dart';

class SpendTrendCard extends StatefulWidget {
  const SpendTrendCard({
    super.key,
    required this.rows,
    required this.categories,
    required this.now,
    required this.onTap,
  });

  final List<MoneyTransaction> rows;
  final List<Category> categories;
  final DateTime now;
  final VoidCallback onTap;

  @override
  State<SpendTrendCard> createState() => _SpendTrendCardState();
}

class _SpendTrendCardState extends State<SpendTrendCard> {
  var _income = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final month = summarize(widget.rows, ReportRange.month(widget.now));
    final previous = summarize(
      widget.rows,
      ReportRange.month(DateTime(widget.now.year, widget.now.month - 1)),
    );
    final throughToday = ReportRange(
      DateTime(widget.now.year, widget.now.month),
      DateTime(widget.now.year, widget.now.month, widget.now.day).add(const Duration(days: 1)),
    );
    final series = dailySeries(widget.rows, throughToday);
    final daysSoFar = series.isEmpty ? 1 : series.length;
    final current = _income ? month.income : month.expense;
    final prior = _income ? previous.income : previous.expense;
    final daily = current / daysSoFar;
    final monthEnd = DateTime(widget.now.year, widget.now.month + 1);
    final daysRemaining = monthEnd
        .difference(DateTime(widget.now.year, widget.now.month, widget.now.day))
        .inDays;
    final ranked = (_income ? month.incomeByCategory : month.expenseByCategory)
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    Category? top;
    if (ranked.isNotEmpty) {
      for (final category in widget.categories) {
        if (category.id == ranked.first.key) top = category;
      }
    }
    final accent = _income ? bahtIncome : bahtExpense;
    return PopCard(
      child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: cardWash(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: BuddyLook.of(context).orbA.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        selectedBackgroundColor: accent.withValues(alpha: 0.16),
                        selectedForegroundColor: accent,
                      ),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: false, label: Text(l10n.expense)),
                        ButtonSegment(value: true, label: Text(l10n.income)),
                      ],
                      selected: {_income},
                      onSelectionChanged: (value) =>
                          setState(() => _income = value.first),
                    ),
                  ),
                  TextButton(onPressed: widget.onTap, child: Text(l10n.seeAll)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _income ? l10n.income : l10n.spentThisMonth,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF8A819C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatBaht(locale, current),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _comparison(l10n, current, prior),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _comparisonColor(current, prior),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _MoneyCharts(
                series: series,
                showIncome: _income,
                ranked: ranked,
                categories: widget.categories,
                locale: locale,
                total: current,
              ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Insight(
                        label: l10n.dailyAverage,
                        value: formatBaht(locale, daily),
                      ),
                    ),
                    Expanded(
                      child: _Insight(
                        label: l10n.topCategory,
                        value: top == null
                            ? '—'
                            : categoryLabel(top, locale),
                      ),
                    ),
                    Expanded(
                      child: _Insight(
                        label: l10n.thisMonth,
                        value: l10n.daysLeft('$daysRemaining'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  String _comparison(AppLocalizations l10n, double current, double previous) {
    if (previous == 0) {
      if (current == 0) return l10n.sameAsLastMonth;
      return _income ? l10n.noIncomeLastMonth : l10n.noSpendingLastMonth;
    }
    final ratio = (current - previous) / previous;
    if (ratio.abs() < 0.005) return l10n.sameAsLastMonth;
    final percent = (ratio.abs() * 100).toStringAsFixed(0);
    final signed = ratio > 0 ? '+$percent%' : '−$percent%';
    return l10n.comparedWithLastMonth(signed);
  }

  Color _comparisonColor(double current, double previous) {
    if (previous == 0) return const Color(0xFF8A819C);
    final ratio = (current - previous) / previous;
    if (ratio.abs() < 0.005) return const Color(0xFF8A819C);
    if (_income) return ratio > 0 ? bahtIncome : bahtExpense;
    return ratio > 0 ? bahtExpense : bahtIncome;
  }
}

enum _ChartKind { pie, line, bars }

class _MoneyCharts extends StatefulWidget {
  const _MoneyCharts({
    required this.series,
    required this.showIncome,
    required this.ranked,
    required this.categories,
    required this.locale,
    required this.total,
  });

  final List<DayPoint> series;
  final bool showIncome;
  final List<MapEntry<int, double>> ranked;
  final List<Category> categories;
  final Locale locale;
  final double total;

  @override
  State<_MoneyCharts> createState() => _MoneyChartsState();
}

class _MoneyChartsState extends State<_MoneyCharts> {
  _ChartKind _kind = _ChartKind.line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SegmentedButton<_ChartKind>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _ChartKind.pie,
              icon: const Icon(Icons.pie_chart_rounded, size: 18),
              label: Text(l10n.byCategory, overflow: TextOverflow.ellipsis),
            ),
            ButtonSegment(
              value: _ChartKind.line,
              icon: const Icon(Icons.show_chart_rounded, size: 18),
              label: Text(l10n.overTime, overflow: TextOverflow.ellipsis),
            ),
            ButtonSegment(
              value: _ChartKind.bars,
              icon: const Icon(Icons.bar_chart_rounded, size: 18),
              label: Text(l10n.byDay, overflow: TextOverflow.ellipsis),
            ),
          ],
          selected: {_kind},
          onSelectionChanged: (value) => setState(() => _kind = value.first),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 176,
          child: switch (_kind) {
            _ChartKind.pie => _PieChart(
                ranked: widget.ranked,
                categories: widget.categories,
                locale: widget.locale,
                total: widget.total,
              ),
            _ChartKind.line => _TrendChart(
                series: widget.series,
                showIncome: widget.showIncome,
              ),
            _ChartKind.bars => _FlowBars(
                series: widget.series,
                showIncome: widget.showIncome,
              ),
          },
        ),
      ],
    );
  }
}

class _PieChart extends StatefulWidget {
  const _PieChart({
    required this.ranked,
    required this.categories,
    required this.locale,
    required this.total,
  });

  final List<MapEntry<int, double>> ranked;
  final List<Category> categories;
  final Locale locale;
  final double total;

  @override
  State<_PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<_PieChart> {
  var _touched = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ranked = widget.ranked;
    final total = widget.total;
    final locale = widget.locale;
    if (ranked.isEmpty || total <= 0) {
      return Center(
        child: Text(
          l10n.reportsEmpty,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8A819C),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index =
                      response?.touchedSection?.touchedSectionIndex ?? -1;
                  if (index != _touched) setState(() => _touched = index);
                },
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 28,
              sections: [
                for (var i = 0; i < ranked.length; i++)
                  PieChartSectionData(
                    value: ranked[i].value,
                    color: categoryStyle(_key(ranked[i].key)).color,
                    radius: i == _touched ? 36 : 22,
                    title: i == _touched
                        ? formatBaht(locale, ranked[i].value)
                        : '',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final entry in ranked.take(4))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: categoryStyle(_key(entry.key)).color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _name(entry.key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Text(
                        l10n.percentValue(
                          ((entry.value / total) * 100).toStringAsFixed(0),
                        ),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String? _key(int id) {
    for (final category in widget.categories) {
      if (category.id == id) return category.key;
    }
    return null;
  }

  String _name(int id) {
    for (final category in widget.categories) {
      if (category.id == id) return categoryLabel(category, widget.locale);
    }
    return '';
  }
}

class _FlowBars extends StatelessWidget {
  const _FlowBars({required this.series, required this.showIncome});

  final List<DayPoint> series;
  final bool showIncome;

  @override
  Widget build(BuildContext context) {
    final points = series.isEmpty ? [DayPoint(zoneNow(), 0, 0)] : series;
    var peak = 1.0;
    for (final point in points) {
      final value = showIncome ? point.income : point.expense;
      if (value > peak) peak = value;
    }
    final compact = points.length > 12;
    return BarChart(
      BarChartData(
        maxY: peak * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0E1C2F),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = points[group.x.toInt()].day.day;
              return BarTooltipItem(
                '$day\n${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              );
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: showIncome ? points[i].income : points[i].expense,
                  width: compact ? 4 : 8,
                  color: showIncome ? bahtIncome : bahtExpense,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 18,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                if (compact && index % 5 != 0 && index != points.length - 1) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${points[index].day.day}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF8A819C)),
                );
              },
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF8A819C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.series, required this.showIncome});

  final List<DayPoint> series;
  final bool showIncome;

  @override
  Widget build(BuildContext context) {
    final points = series.isEmpty
        ? [DayPoint(zoneNow(), 0, 0)]
        : series;
    final color = showIncome ? bahtIncome : const Color(0xFF1E4B7A);
    var peak = 1.0;
    for (final point in points) {
      final value = showIncome ? point.income : point.expense;
      if (value > peak) peak = value;
    }
    final compact = points.length > 10;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: peak * 1.25,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return [
                for (final spot in spots)
                  LineTooltipItem(
                    spot.y.toStringAsFixed(0),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ];
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                if (compact && index % 5 != 0 && index != points.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${points[index].day.day}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF8A819C)),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(
                  i.toDouble(),
                  showIncome ? points[i].income : points[i].expense,
                ),
            ],
            isCurved: points.length > 2,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: points.length <= 10),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }
}
