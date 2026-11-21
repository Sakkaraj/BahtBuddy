import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/empty_state.dart';
import 'summary.dart';

enum _Period { day, week, month }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Period _period = _Period.month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final rows = ref.watch(transactionsProvider).asData?.value ?? [];
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final now = DateTime.now();
    final range = switch (_period) {
      _Period.day => ReportRange.day(now),
      _Period.week => ReportRange.week(now),
      _Period.month => ReportRange.month(now),
    };
    final summary = summarize(rows, range);
    final entries = summary.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final empty = summary.income == 0 && summary.expense == 0;
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
        if (empty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: CupertinoIcons.chart_pie,
              message: l10n.reportsEmpty,
            ),
          )
        else
          SliverList(
            delegate: SliverChildListDelegate([
              BbGroupedSection(
                header: l10n.incomeVsExpense,
                footer: '${l10n.balance}: ${formatBaht(locale, summary.balance)}',
                children: [
                  SizedBox(
                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.income,
                                  color: bahtIncome,
                                  width: 36,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.expense,
                                  color: Theme.of(context).colorScheme.error,
                                  width: 36,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    value == 0 ? l10n.income : l10n.expense,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (summary.expense > 0)
                BbGroupedSection(
                  header: l10n.byCategory,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final side = constraints.maxWidth;
                                final hole = side * 0.28;
                                final thickness = side * 0.14;
                                return PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: hole,
                                    sections: [
                                      for (var i = 0; i < entries.length; i++)
                                        PieChartSectionData(
                                          value: entries[i].value,
                                          color: categoryColors[
                                              i % categoryColors.length],
                                          title: '',
                                          radius: thickness,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < entries.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  categoryColors[i % categoryColors.length],
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
                                ((entries[i].value / summary.expense) * 100)
                                    .toStringAsFixed(0),
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: CupertinoColors.secondaryLabel
                                        .resolveFrom(context),
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Text(formatBaht(locale, entries[i].value)),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
            ]),
          ),
      ],
    );
  }
}
