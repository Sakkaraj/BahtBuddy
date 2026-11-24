import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/glass_photo_card.dart';
import '../../widgets/motion.dart';
import '../../widgets/offer_banner.dart';
import 'summary.dart';
import 'tips.dart';

enum _Period { day, week, month }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Period _period = _Period.month;
  var _income = false;
  var _pieTouch = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    ref.watch(timeZoneProvider);
    final rows = ref.watch(transactionsProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final now = zoneNow();
    final range = switch (_period) {
      _Period.day => ReportRange.day(now),
      _Period.week => ReportRange.week(now),
      _Period.month => ReportRange.month(now),
    };
    final previous = switch (_period) {
      _Period.day => ReportRange.day(now.subtract(const Duration(days: 1))),
      _Period.week => ReportRange.week(now.subtract(const Duration(days: 7))),
      _Period.month => ReportRange.month(DateTime(now.year, now.month - 1)),
    };
    final facts = reportFacts(
      rows: rows,
      range: range,
      previous: previous,
      now: now,
      categoryName: (id) {
        final match = categories.where((category) => category.id == id);
        if (match.isEmpty) return l10n.category;
        return categoryLabel(match.first, locale);
      },
    );
    final summary = summarize(rows, range);
    final byCategory = _income
        ? summary.incomeByCategory
        : summary.expenseByCategory;
    final selectedTotal = _income ? summary.income : summary.expense;
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BbScaffold(
      title: l10n.navReports,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Center(
              child: CupertinoSlidingSegmentedControl<_Period>(
                groupValue: _period,
                children: {
                  _Period.day: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(l10n.today),
                  ),
                  _Period.week: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(l10n.thisWeek),
                  ),
                  _Period.month: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(l10n.thisMonth),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) setState(() => _period = value);
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Center(
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _income,
                children: {
                  false: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(l10n.expense),
                  ),
                  true: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(l10n.income),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) setState(() => _income = value);
                },
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: OfferBanner()),
        SliverList(
            delegate: SliverChildListDelegate([
              _ReportHero(
                income: summary.income,
                expense: summary.expense,
                balance: summary.balance,
              ),
              _GlanceCard(facts: facts),
              _TipCard(tips: facts.tips),
              BbGroupedSection(
                header: l10n.byCategory,
                children: [
                  if (selectedTotal <= 0)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.reportsEmpty)),
                    )
                  else ...[
                    PopCard(
                      child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: SizedBox(
                        height: 188,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    final index = response
                                            ?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1;
                                    if (index != _pieTouch) {
                                      setState(() => _pieTouch = index);
                                    }
                                  },
                                ),
                                sectionsSpace: 3,
                                centerSpaceRadius: 58,
                                sections: [
                                  for (var i = 0; i < entries.length; i++)
                                    PieChartSectionData(
                                      value: entries[i].value,
                                      color: categoryStyle(
                                        categories
                                            .where((c) => c.id == entries[i].key)
                                            .map((c) => c.key)
                                            .firstOrNull,
                                      ).color,
                                      title: i == _pieTouch
                                          ? formatBaht(locale, entries[i].value)
                                          : '',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      radius: i == _pieTouch ? 42 : 28,
                                    ),
                                ],
                              ),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatBaht(locale, selectedTotal),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  _income ? l10n.income : l10n.expense,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: CupertinoColors.secondaryLabel
                                            .resolveFrom(context),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                    for (var i = 0; i < entries.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: categoryStyle(
                                    categories
                                        .where((c) => c.id == entries[i].key)
                                        .map((c) => c.key)
                                        .firstOrNull,
                                  ).color,
                                  radius: 6,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    categoryLabel(
                                      categories.firstWhere(
                                        (c) => c.id == entries[i].key,
                                      ),
                                      locale,
                                    ),
                                  ),
                                ),
                                Text(
                                  l10n.percentValue(
                                    ((entries[i].value / selectedTotal) * 100)
                                        .toStringAsFixed(0),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: CupertinoColors.secondaryLabel
                                            .resolveFrom(context),
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Text(formatBaht(locale, entries[i].value)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: entries[i].value / selectedTotal,
                                minHeight: 6,
                                backgroundColor: categoryStyle(
                                  categories
                                      .where((c) => c.id == entries[i].key)
                                      .map((c) => c.key)
                                      .firstOrNull,
                                ).color.withValues(alpha: 0.15),
                                color: categoryStyle(
                                  categories
                                      .where((c) => c.id == entries[i].key)
                                      .map((c) => c.key)
                                      .firstOrNull,
                                ).color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
              BbGroupedSection(
                header: l10n.overTime,
                children: [
                  if (_income)
                    _IncomeOverTime(
                      points: dailySeries(rows, range),
                      locale: locale,
                      totalLabel: l10n.runningTotal,
                      total: formatBaht(locale, summary.income),
                    )
                  else ...[
                    SizedBox(
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 12, 4),
                        child: _OverTimeLine(
                          points: dailySeries(rows, range),
                          showIncome: false,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                        child: _OverTimeChart(
                          points: dailySeries(rows, range),
                          locale: locale,
                          showIncome: false,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
            ]),
          ),
      ],
    );
  }
}

class _IncomeOverTime extends StatelessWidget {
  const _IncomeOverTime({
    required this.points,
    required this.locale,
    required this.totalLabel,
    required this.total,
  });

  final List<DayPoint> points;
  final Locale locale;
  final String totalLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    final spots = points.isEmpty ? [DayPoint(zoneNow(), 0, 0)] : points;
    final daily = [for (final point in spots) point.income];
    final cumulative = <double>[];
    var running = 0.0;
    for (final value in daily) {
      running += value;
      cumulative.add(running);
    }
    var peak = cumulative.isEmpty ? 1.0 : cumulative.last;
    if (peak < 1) peak = 1;
    final step = _axisStep(peak);
    final maxY = (peak / step).ceil() * step;
    final compact = spots.length > 10;
    var marked = -1;
    var markedValue = 0.0;
    for (var i = 0; i < daily.length; i++) {
      if (daily[i] > markedValue) {
        marked = i;
        markedValue = daily[i];
      }
    }
    final bar = LineChartBarData(
      spots: [
        for (var i = 0; i < cumulative.length; i++)
          FlSpot(i.toDouble(), cumulative[i]),
      ],
      isCurved: false,
      color: bahtIncome,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, bar) => daily[spot.x.toInt()] > 0,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 5,
          color: Colors.white,
          strokeWidth: 3,
          strokeColor: bahtIncome,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bahtIncome.withValues(alpha: 0.28),
            bahtIncome.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                totalLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const Spacer(),
              Text(
                total,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: bahtIncome,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY.toDouble(),
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: step.toDouble(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: bahtIncome.withValues(alpha: 0.12),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                showingTooltipIndicators: marked < 0
                    ? const []
                    : [
                        ShowingTooltipIndicators([
                          LineBarSpot(bar, 0, bar.spots[marked]),
                        ]),
                      ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0E7C72),
                    tooltipBorderRadius: BorderRadius.circular(10),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touched) {
                      return [
                        for (final spot in touched)
                          daily[spot.x.toInt()] <= 0
                              ? null
                              : LineTooltipItem(
                                  formatBaht(locale, daily[spot.x.toInt()]),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                      ];
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      interval: step.toDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > maxY) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _axisLabel(value),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF5E7082),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= spots.length) {
                          return const SizedBox.shrink();
                        }
                        if (compact &&
                            index % 5 != 0 &&
                            index != spots.length - 1 &&
                            index != marked) {
                          return const SizedBox.shrink();
                        }
                        if (!compact && spots.length > 7 && index % 2 != 0) {
                          return const SizedBox.shrink();
                        }
                        final day = spots[index].day;
                        final text = compact
                            ? '${day.day}'
                            : DateFormat.E(locale.languageCode).format(day);
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF5E7082),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [bar],
              ),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }
}

double _axisStep(double peak) {
  if (peak <= 50) return 10;
  if (peak <= 200) return 50;
  if (peak <= 1000) return 100;
  if (peak <= 5000) return 500;
  return 1000;
}

String _axisLabel(double value) {
  if (value >= 1000) {
    final scaled = value / 1000;
    final text = scaled == scaled.roundToDouble()
        ? scaled.toStringAsFixed(0)
        : scaled.toStringAsFixed(1);
    return '${text}k';
  }
  return value.toStringAsFixed(0);
}

class _OverTimeLine extends StatelessWidget {
  const _OverTimeLine({required this.points, required this.showIncome});

  final List<DayPoint> points;
  final bool showIncome;

  @override
  Widget build(BuildContext context) {
    final spots = points.isEmpty ? [DayPoint(zoneNow(), 0, 0)] : points;
    final color = showIncome ? bahtIncome : bahtExpense;
    var peak = 1.0;
    for (final point in spots) {
      final value = showIncome ? point.income : point.expense;
      if (value > peak) peak = value;
    }
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: peak * 1.25,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0E1C2F),
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  spot.y.toStringAsFixed(0),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: peak * 1.25 / 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: color.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < spots.length; i++)
                FlSpot(
                  i.toDouble(),
                  showIncome ? spots[i].income : spots[i].expense,
                ),
            ],
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, bar) => spot.y > 0,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3.5,
                color: color,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.38),
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

class _OverTimeChart extends StatelessWidget {
  const _OverTimeChart({
    required this.points,
    required this.locale,
    required this.showIncome,
  });

  final List<DayPoint> points;
  final Locale locale;
  final bool showIncome;

  @override
  Widget build(BuildContext context) {
    final color = showIncome ? bahtIncome : bahtExpense;
    var peak = 1.0;
    for (final point in points) {
      final value = showIncome ? point.income : point.expense;
      if (value > peak) peak = value;
    }
    final compact = points.length > 10;
    return BarChart(
      BarChartData(
        maxY: peak * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0E1C2F),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = points[group.x.toInt()].day.day;
              return BarTooltipItem(
                '$day\n${formatBaht(locale, rod.toY)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                BarChartRodData(
                  toY: showIncome ? points[i].income : points[i].expense,
                  width: compact ? 6 : 12,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      color.withValues(alpha: 0.35),
                      color,
                    ],
                  ),
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
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                if (compact && index % 5 != 0) return const SizedBox.shrink();
                final day = points[index].day;
                final text = compact
                    ? '${day.day}'
                    : DateFormat.E(locale.languageCode).format(day);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(text, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final ink = BuddyLook.of(context).bannerInk;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final total = income + expense;
    return GlassPhotoCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.balance,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ink.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatBaht(locale, balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FlowStat(
                    label: l10n.income,
                    value: formatBaht(locale, income),
                    accent: bahtIncome,
                    ink: ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FlowStat(
                    label: l10n.expense,
                    value: formatBaht(locale, expense),
                    accent: bahtExpense,
                    ink: ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 8,
                child: total <= 0
                    ? ColoredBox(color: ink.withValues(alpha: 0.16))
                    : Row(
                        children: [
                          if (income > 0)
                            Expanded(
                              flex: (income * 100).round().clamp(1, 100000),
                              child: const ColoredBox(color: bahtIncome),
                            ),
                          if (expense > 0)
                            Expanded(
                              flex: (expense * 100).round().clamp(1, 100000),
                              child: const ColoredBox(color: bahtExpense),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
    );
  }
}

class _FlowStat extends StatelessWidget {
  const _FlowStat({
    required this.label,
    required this.value,
    required this.accent,
    required this.ink,
  });

  final String label;
  final String value;
  final Color accent;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ink.withValues(alpha: 0.75),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlanceCard extends StatelessWidget {
  const _GlanceCard({required this.facts});

  final PeriodFacts facts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final kept = facts.saveRate == null
        ? '—'
        : '${(facts.saveRate! * 100).round()}%';
    final change = facts.spendChange == null
        ? '—'
        : '${facts.spendChange! >= 0 ? '+' : '−'}${(facts.spendChange!.abs() * 100).round()}%';
    return BbGroupedSection(
      header: l10n.reportGlance,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              _Fact(
                label: l10n.keptShare,
                value: kept,
                color: (facts.saveRate ?? 0) < 0 ? bahtExpense : bahtIncome,
              ),
              _Fact(
                label: l10n.perDay,
                value: formatBaht(locale, facts.dailyExpense),
                color: const Color(0xFF1E4B7A),
              ),
              _Fact(
                label: l10n.vsLastPeriod,
                value: change,
                color: (facts.spendChange ?? 0) > 0.05
                    ? bahtExpense
                    : bahtIncome,
              ),
              _Fact(
                label: l10n.recordCount,
                value: '${facts.records}',
                color: const Color(0xFF1E4B7A),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tips});

  final List<SpendingTip> tips;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return BbGroupedSection(
      header: l10n.forYou,
      children: [
        for (final tip in tips)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _tipColor(tip.kind).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _tipIcon(tip.kind),
                    color: _tipColor(tip.kind),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _tipText(l10n, locale, tip),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Color _tipColor(TipKind kind) {
  return switch (kind) {
    TipKind.overspent ||
    TipKind.missingIncome ||
    TipKind.spendingUp ||
    TipKind.thinBuffer ||
    TipKind.pace => bahtExpense,
    TipKind.noSpending ||
    TipKind.spendingDown ||
    TipKind.healthyBuffer => bahtIncome,
    TipKind.empty ||
    TipKind.steady ||
    TipKind.categoryShare ||
    TipKind.largest => const Color(0xFF1E4B7A),
  };
}

IconData _tipIcon(TipKind kind) {
  return switch (kind) {
    TipKind.empty => Icons.edit_note_rounded,
    TipKind.steady => Icons.balance_rounded,
    TipKind.overspent => Icons.trending_up_rounded,
    TipKind.missingIncome => Icons.account_balance_wallet_outlined,
    TipKind.noSpending => Icons.savings_outlined,
    TipKind.categoryShare => Icons.pie_chart_outline_rounded,
    TipKind.spendingUp => Icons.arrow_upward_rounded,
    TipKind.spendingDown => Icons.arrow_downward_rounded,
    TipKind.thinBuffer => Icons.shield_outlined,
    TipKind.healthyBuffer => Icons.verified_outlined,
    TipKind.pace => Icons.speed_rounded,
    TipKind.largest => Icons.receipt_long_rounded,
  };
}

String _tipText(AppLocalizations l10n, Locale locale, SpendingTip tip) {
  final amount = formatBaht(locale, tip.amount);
  final percent = '${tip.percent}%';
  return switch (tip.kind) {
    TipKind.empty => l10n.tipEmpty,
    TipKind.steady => l10n.tipSteady,
    TipKind.overspent => l10n.tipOverspent(amount),
    TipKind.missingIncome => l10n.tipMissingIncome,
    TipKind.noSpending => l10n.tipNoSpending,
    TipKind.categoryShare => l10n.tipCategory(tip.label, percent),
    TipKind.spendingUp => l10n.tipSpendUp(percent),
    TipKind.spendingDown => l10n.tipSpendDown(percent),
    TipKind.thinBuffer => l10n.tipThin(percent),
    TipKind.healthyBuffer => l10n.tipHealthy(percent),
    TipKind.pace => l10n.tipPace(amount),
    TipKind.largest => l10n.tipLargest(amount, tip.label),
  };
}
