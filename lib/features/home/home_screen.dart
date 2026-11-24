import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../features/reports/summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/home_layout.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/budget_progress.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/motion.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/promo_banner.dart';
import '../../widgets/spend_trend_card.dart';
import '../../widgets/exchange_rate_card.dart';
import '../add/add_screen.dart';
import '../entry/entry_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _editing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final budgets = ref.watch(budgetsProvider);
    return BbScaffold(
      title: l10n.appTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _editing = !_editing),
            child: _editing
                ? Text(
                    l10n.done,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )
                : const Icon(Icons.dashboard_customize_outlined, size: 24),
          ),
          if (!_editing)
            BbAddButton(onPressed: () => showAddActions(context, ref)),
        ],
      ),
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
            final monthEnd = DateTime(now.year, now.month + 1);
            final daysRemaining = monthEnd
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;
            final pace = _paceLabel(l10n, locale, month.balance, daysRemaining);
            final names = {
              for (final category in categories.asData?.value ?? <Category>[])
                category.id: category,
            };
            final budgetRows = budgets.asData?.value ?? <Budget>[];
            final spend = month.expenseByCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final order = ref.watch(homeLayoutProvider).maybeWhen(
              data: (value) => value,
              orElse: () => HomeLayout.defaults,
            );
            final sections = <String, Widget>{
              'tips': const Appear(child: PromoBanner()),
              'balance': Appear(
                  child: _BalanceHero(
                    monthLabel: l10n.monthBalance,
                    balance: formatBaht(locale, month.balance),
                    todayLabel: l10n.today,
                    todayValue: formatBaht(locale, today.expense),
                    incomeLabel: l10n.income,
                    incomeValue: formatBaht(locale, month.income),
                    expenseLabel: l10n.expense,
                    expenseValue: formatBaht(locale, month.expense),
                    pace: pace,
                  ),
                ),
              'rates': const Appear(
                  delay: Duration(milliseconds: 40),
                  child: ExchangeRateCard(),
                ),
              'shortcuts': Appear(
                  delay: const Duration(milliseconds: 80),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                label: l10n.camera,
                                icon: Icons.photo_camera_rounded,
                                colors: const [Color(0xFF14B8A6), Color(0xFF0E9F8A)],
                                onTap: () => scanSlip(
                                  context,
                                  ref,
                                  ImageSource.camera,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                label: l10n.gallery,
                                icon: Icons.photo_library_rounded,
                                colors: const [Color(0xFF1E4B7A), Color(0xFF163A5F)],
                                onTap: () => scanSlip(
                                  context,
                                  ref,
                                  ImageSource.gallery,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickAction(
                                label: l10n.expense,
                                icon: Icons.remove_rounded,
                                colors: const [Color(0xFFFF7A86), Color(0xFFFF5A6A)],
                                onTap: () => context.push(
                                  '/entry',
                                  extra: const EntryArgs(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickAction(
                                label: l10n.income,
                                icon: Icons.add_rounded,
                                colors: const [Color(0xFF34D399), Color(0xFF12B981)],
                                onTap: () => context.push(
                                  '/entry',
                                  extra: const EntryArgs(initialType: 'income'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              'spending': Appear(
                  delay: const Duration(milliseconds: 100),
                  child: SpendTrendCard(
                    rows: rows,
                    categories: categories.asData?.value ?? const <Category>[],
                    now: now,
                    onTap: () => context.go('/reports'),
                  ),
                ),
              'categories': spend.isEmpty
                  ? _WaitingCard(message: l10n.cardWaiting)
                  : Appear(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 8, 16, 8),
                          child: Text(
                            l10n.byCategory.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  letterSpacing: 0.4,
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: spend.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final entry = spend[index];
                              final category = names[entry.key];
                              final style = categoryStyle(category?.key);
                              final share = month.expense == 0
                                  ? 0
                                  : entry.value / month.expense;
                              return PressScale(
                                onTap: () => context.go('/reports'),
                                child: Container(
                                  width: 148,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: cardWash(context),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: style.color
                                                .withValues(alpha: 0.18),
                                            child: Icon(
                                              style.icon,
                                              size: 16,
                                              color: style.color,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            l10n.percentValue(
                                              (share * 100).toStringAsFixed(0),
                                            ),
                                            style: TextStyle(
                                              color: style.color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        category == null
                                            ? l10n.category
                                            : categoryLabel(category, locale),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      Text(
                                        formatBaht(locale, entry.value),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              'budgets': budgetRows.isEmpty
                  ? _WaitingCard(message: l10n.cardWaiting)
                  : BbGroupedSection(
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
                          color: categoryStyle(
                            names[budget.categoryId]?.key,
                          ).color,
                          icon: categoryStyle(names[budget.categoryId]?.key).icon,
                          onTap: () => context.push('/budgets'),
                        ),
                    ],
                  ),
              'recent': BbGroupedSection(
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
                            message: l10n.emptyHint,
                            actionLabel: l10n.emptyAddCta,
                            onAction: () => showAddActions(context, ref),
                            secondaryLabel: l10n.sampleSlip,
                            onSecondary: () => readSampleSlip(context, ref),
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
                              categoryKey: names[row.categoryId]?.key,
                              locale: locale,
                              onTap: () => context.push(
                                '/entry',
                                extra: EntryArgs(existing: row),
                              ),
                            ),
                        ],
                ),
            };
            bool shown(String id) {
              if (_editing) return true;
              if (id == 'categories') return spend.isNotEmpty;
              if (id == 'budgets') return budgetRows.isNotEmpty;
              return sections.containsKey(id);
            }

            final visible = [
              for (final id in order)
                if (shown(id) && sections[id] != null) sections[id]!,
            ];
            if (_editing) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: _ArrangeHint(
                      onReset: () =>
                          ref.read(homeLayoutProvider.notifier).reset(),
                    ),
                  ),
                  SliverReorderableList(
                    itemCount: order.length,
                    onReorderItem: (oldIndex, newIndex) {
                      ref
                          .read(homeLayoutProvider.notifier)
                          .move(oldIndex, newIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final lift = Curves.easeOut.transform(animation.value);
                          return Transform.scale(
                            scale: 1 + (0.015 * lift),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 12 * lift,
                              shadowColor: Colors.black38,
                              borderRadius: BorderRadius.circular(28),
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final id = order[index];
                      return _ArrangeTile(
                        key: ValueKey(id),
                        index: index,
                        title: _cardTitle(l10n, id),
                        child: sections[id] ?? const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            }
            return SliverList(
              delegate: SliverChildListDelegate([
                ...visible,
                const SizedBox(height: 24),
              ]),
            );
          },
        ),
      ],
    );
  }
}

String _paceLabel(
  AppLocalizations l10n,
  Locale locale,
  double balance,
  int daysRemaining,
) {
  if (balance < 0) return l10n.overIncome(formatBaht(locale, balance.abs()));
  if (balance == 0) return l10n.nothingLeft;
  final perDay = balance / (daysRemaining <= 0 ? 1 : daysRemaining);
  return l10n.safePerDay(formatBaht(locale, perDay));
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.monthLabel,
    required this.balance,
    required this.todayLabel,
    required this.todayValue,
    required this.incomeLabel,
    required this.incomeValue,
    required this.expenseLabel,
    required this.expenseValue,
    required this.pace,
  });

  final String monthLabel;
  final String balance;
  final String todayLabel;
  final String todayValue;
  final String incomeLabel;
  final String incomeValue;
  final String expenseLabel;
  final String expenseValue;
  final String pace;

  @override
  Widget build(BuildContext context) {
    final look = BuddyLook.of(context);
    final ink = look.bannerInk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: look.banner,
          borderRadius: BorderRadius.circular(28),
          border: look.bannerFilled
              ? null
              : Border.all(color: ink.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: look.orbA.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ink.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.86, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
                child: Text(
                  balance,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _GlassStat(label: todayLabel, value: todayValue),
                  const SizedBox(width: 8),
                  _GlassStat(label: incomeLabel, value: incomeValue),
                  const SizedBox(width: 8),
                  _GlassStat(label: expenseLabel, value: expenseValue),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  pace,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ink = BuddyLook.of(context).bannerInk;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: ink.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ink.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _cardTitle(AppLocalizations l10n, String id) {
  return switch (id) {
    'tips' => l10n.cardTips,
    'balance' => l10n.monthBalance,
    'rates' => l10n.exchangeRates,
    'shortcuts' => l10n.cardShortcuts,
    'spending' => l10n.cardSpending,
    'categories' => l10n.byCategory,
    'budgets' => l10n.budgets,
    'recent' => l10n.recent,
    _ => id,
  };
}

class _ArrangeHint extends StatelessWidget {
  const _ArrangeHint({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          gradient: cardWash(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              Icons.drag_indicator_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.arrangeHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              onPressed: onReset,
              child: Text(l10n.resetLayout),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrangeTile extends StatelessWidget {
  const _ArrangeTile({
    super.key,
    required this.index,
    required this.title,
    required this.child,
  });

  final int index;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ReorderableDragStartListener(
            index: index,
            child: Listener(
              onPointerDown: (_) => HapticFeedback.selectionClick(),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: groupedSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12324F).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_indicator_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(child: child),
      ],
    );
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: cardWash(context),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}
