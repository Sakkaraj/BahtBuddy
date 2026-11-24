import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_row.dart';
import '../add/add_screen.dart';
import '../entry/entry_screen.dart';
import 'history_filter.dart';

DateTime _zoneDay() {
  final now = zoneNow();
  return DateTime(now.year, now.month, now.day);
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  HistoryFilter _filter = const HistoryFilter();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    ref.watch(timeZoneProvider);
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    return BbScaffold(
      title: l10n.navHistory,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _openFilters(categories),
            child: Icon(
              _filter.isActive
                  ? CupertinoIcons.line_horizontal_3_decrease_circle_fill
                  : CupertinoIcons.line_horizontal_3_decrease_circle,
            ),
          ),
          BbAddButton(onPressed: () => showAddActions(context, ref)),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CupertinoSearchTextField(
              controller: _search,
              placeholder: l10n.searchHint,
              onChanged: (value) =>
                  setState(() => _filter = _copy(query: value)),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Center(
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: _filter.type ?? '',
                children: {
                  '': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(l10n.allRecords),
                  ),
                  'expense': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(l10n.expense),
                  ),
                  'income': Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(l10n.income),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) return;
                  setState(
                    () => _filter = _copy(
                      type: value.isEmpty ? null : value,
                      setType: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_filter.isActive)
          SliverToBoxAdapter(child: _FilterChips(
            filter: _filter,
            categories: categories,
            locale: locale,
            onChanged: (filter) => setState(() => _filter = filter),
          )),
        transactions.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(child: Text('$error')),
          ),
          data: (rows) {
            final visible = rows.where((row) {
              final category = _category(categories, row.categoryId);
              final names = category == null
                  ? ''
                  : '${category.nameEn} ${category.nameTh}';
              return _filter.matches(row, categoryText: names);
            }).toList();
            if (visible.isEmpty) {
              final narrowed =
                  _filter.query.trim().isNotEmpty ||
                  _filter.isActive ||
                  _filter.type != null;
              return SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: CupertinoIcons.search,
                  message: narrowed
                      ? l10n.noMatches
                      : l10n.emptyTransactions,
                  actionLabel: narrowed ? null : l10n.emptyAddCta,
                  onAction: narrowed
                      ? null
                      : () => showAddActions(context, ref),
                ),
              );
            }
            final groups = <DateTime, List<MoneyTransaction>>{};
            for (final row in visible) {
              groups.putIfAbsent(dayKey(row.occurredAt), () => []).add(row);
            }
            return SliverList(
              delegate: SliverChildListDelegate([
                for (final entry in groups.entries)
                  BbGroupedSection(
                    header: formatDay(locale, entry.key),
                    children: [
                      for (final row in entry.value)
                        Dismissible(
                          key: ValueKey(row.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(),
                          onDismissed: (_) => ref
                              .read(databaseProvider)
                              .deleteTransaction(row.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Theme.of(context).colorScheme.error,
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: TransactionRow(
                            transaction: row,
                            title: _title(categories, row, locale),
                            categoryKey: _category(categories, row.categoryId)?.key,
                            locale: locale,
                            showDate: false,
                            onTap: () => context.push(
                              '/entry',
                              extra: EntryArgs(existing: row),
                            ),
                            onLongPress: () => _delete(row),
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

  String _title(List<Category> categories, MoneyTransaction row, Locale locale) {
    final category = _category(categories, row.categoryId);
    return category == null ? row.note : categoryLabel(category, locale);
  }

  Category? _category(List<Category> categories, int id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  HistoryFilter _copy({String? query, String? type, bool setType = false}) {
    return HistoryFilter(
      query: query ?? _filter.query,
      type: setType ? type : _filter.type,
      categoryId: _filter.categoryId,
      from: _filter.from,
      to: _filter.to,
      minAmount: _filter.minAmount,
      maxAmount: _filter.maxAmount,
    );
  }

  Future<bool> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _delete(MoneyTransaction row) async {
    if (await _confirmDelete()) {
      await ref.read(databaseProvider).deleteTransaction(row.id);
    }
  }

  Future<void> _openFilters(List<Category> categories) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    var categoryId = _filter.categoryId;
    var from = _filter.from;
    var to = _filter.to;
    final min = TextEditingController(
      text: _filter.minAmount?.toString() ?? '',
    );
    final max = TextEditingController(
      text: _filter.maxAmount?.toString() ?? '',
    );
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.filters,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: categoryId,
                    decoration: InputDecoration(labelText: l10n.category),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.allCategories),
                      ),
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(categoryLabel(category, locale)),
                        ),
                    ],
                    onChanged: (value) => setLocal(() => categoryId = value),
                  ),
                  ListTile(
                    title: Text(l10n.from),
                    subtitle: Text(
                      from == null ? '—' : formatDay(locale, from!),
                    ),
                    onTap: () async {
                      final picked = await showBuddyDate(
                        context,
                        initialDate: from ?? _zoneDay(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setLocal(() => from = picked);
                    },
                  ),
                  ListTile(
                    title: Text(l10n.to),
                    subtitle: Text(to == null ? '—' : formatDay(locale, to!)),
                    onTap: () async {
                      final picked = await showBuddyDate(
                        context,
                        initialDate: to ?? _zoneDay(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setLocal(() => to = picked);
                    },
                  ),
                  TextField(
                    controller: min,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: l10n.minAmount),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: max,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: l10n.maxAmount),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.clearFilters),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.apply),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted) return;
    setState(() {
      if (applied == true) {
        _filter = HistoryFilter(
          query: _search.text,
          type: _filter.type,
          categoryId: categoryId,
          from: from,
          to: to,
          minAmount: double.tryParse(min.text),
          maxAmount: double.tryParse(max.text),
        );
      } else if (applied == false) {
        _filter = HistoryFilter(query: _search.text, type: _filter.type);
      }
    });
    min.dispose();
    max.dispose();
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.categories,
    required this.locale,
    required this.onChanged,
  });

  final HistoryFilter filter;
  final List<Category> categories;
  final Locale locale;
  final ValueChanged<HistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[];
    if (filter.categoryId != null) {
      Category? category;
      for (final row in categories) {
        if (row.id == filter.categoryId) category = row;
      }
      chips.add(
        InputChip(
          label: Text(
            category == null
                ? l10n.filterCategoryChip
                : categoryLabel(category, locale),
          ),
          onDeleted: () => onChanged(
            HistoryFilter(
              query: filter.query,
              type: filter.type,
              from: filter.from,
              to: filter.to,
              minAmount: filter.minAmount,
              maxAmount: filter.maxAmount,
            ),
          ),
        ),
      );
    }
    if (filter.from != null) {
      chips.add(
        InputChip(
          label: Text('${l10n.from} ${formatDay(locale, filter.from!)}'),
          onDeleted: () => onChanged(
            HistoryFilter(
              query: filter.query,
              type: filter.type,
              categoryId: filter.categoryId,
              to: filter.to,
              minAmount: filter.minAmount,
              maxAmount: filter.maxAmount,
            ),
          ),
        ),
      );
    }
    if (filter.to != null) {
      chips.add(
        InputChip(
          label: Text('${l10n.to} ${formatDay(locale, filter.to!)}'),
          onDeleted: () => onChanged(
            HistoryFilter(
              query: filter.query,
              type: filter.type,
              categoryId: filter.categoryId,
              from: filter.from,
              minAmount: filter.minAmount,
              maxAmount: filter.maxAmount,
            ),
          ),
        ),
      );
    }
    if (filter.minAmount != null) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.minAmount} ${formatBaht(locale, filter.minAmount!)}',
          ),
          onDeleted: () => onChanged(
            HistoryFilter(
              query: filter.query,
              type: filter.type,
              categoryId: filter.categoryId,
              from: filter.from,
              to: filter.to,
              maxAmount: filter.maxAmount,
            ),
          ),
        ),
      );
    }
    if (filter.maxAmount != null) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.maxAmount} ${formatBaht(locale, filter.maxAmount!)}',
          ),
          onDeleted: () => onChanged(
            HistoryFilter(
              query: filter.query,
              type: filter.type,
              categoryId: filter.categoryId,
              from: filter.from,
              to: filter.to,
              minAmount: filter.minAmount,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }
}
