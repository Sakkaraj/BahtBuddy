import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../features/reports/summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/budget_progress.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_row.dart';
import '../add/add_screen.dart';
import '../entry/entry_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final budgets = ref.watch(budgetsProvider);
    return BbScaffold(
      title: l10n.appTitle,
      trailing: BbAddButton(onPressed: () => showAddActions(context, ref)),
      slivers: [
        transactions.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(child: Text('$error')),
          ),
          data: (rows) {
            final now = DateTime.now();
            final today = summarize(rows, ReportRange.day(now));
            final month = summarize(rows, ReportRange.month(now));
            final names = {
              for (final category in categories.asData?.value ?? <Category>[])
                category.id: category,
            };
            final budgetRows = budgets.asData?.value ?? <Budget>[];
            return SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: groupedSurface(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.monthBalance,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                ),
                          ),
                          const SizedBox(height: 4),
                          MoneyText(
                            formatBaht(locale, month.balance),
                            income: month.balance >= 0,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _StatCell(
                                label: l10n.today,
                                value: formatBaht(locale, today.expense),
                              ),
                              _StatCell(
                                label: l10n.income,
                                value: formatBaht(locale, month.income),
                                income: true,
                              ),
                              _StatCell(
                                label: l10n.expense,
                                value: formatBaht(locale, month.expense),
                                income: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (budgetRows.isNotEmpty)
                  BbGroupedSection(
                    header: l10n.budgets,
                    headerTrailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/budgets'),
                      child: Text(l10n.seeAll),
                    ),
                    children: [
                      for (final budget in budgetRows)
                        BudgetProgress(
                          name: names[budget.categoryId] == null
                              ? ''
                              : categoryLabel(
                                  names[budget.categoryId]!,
                                  locale,
                                ),
                          spent: month.expenseByCategory[budget.categoryId] ?? 0,
                          limit: budget.monthlyLimit,
                          locale: locale,
                          onTap: () => context.push('/budgets'),
                        ),
                    ],
                  ),
                BbGroupedSection(
                  header: l10n.recent,
                  headerTrailing: rows.isEmpty
                      ? null
                      : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => context.go('/history'),
                          child: Text(l10n.seeAll),
                        ),
                  children: rows.isEmpty
                      ? [
                          EmptyState(
                            message: l10n.emptyTransactions,
                            actionLabel: l10n.emptyAddCta,
                            onAction: () => showAddActions(context, ref),
                          ),
                        ]
                      : [
                          for (final row in rows.take(5))
                            TransactionRow(
                              transaction: row,
                              title: names[row.categoryId] == null
                                  ? row.note
                                  : categoryLabel(
                                      names[row.categoryId]!,
                                      locale,
                                    ),
                              locale: locale,
                              onTap: () => context.push(
                                '/entry',
                                extra: EntryArgs(existing: row),
                              ),
                            ),
                        ],
                ),
                const SizedBox(height: 24),
              ]),
            );
          },
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value, this.income});

  final String label;
  final String value;
  final bool? income;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: income == null
                  ? null
                  : amountColor(context, income: income!),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
