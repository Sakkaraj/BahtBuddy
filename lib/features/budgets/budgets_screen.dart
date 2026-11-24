import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/budget_progress.dart';
import '../reports/summary.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final budgets = ref.watch(budgetsProvider).asData?.value ?? [];
    final rows = ref.watch(transactionsProvider).asData?.value ?? [];
    final month = summarize(rows, ReportRange.month(DateTime.now()));
    final expenseCategories = categories.where((c) => !c.isIncome).toList();
    return BuddyBackdrop(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.budgets),
      ),
      body: ListView(
        children: [
          BbGroupedSection(
            children: [
              for (final category in expenseCategories)
                _BudgetTile(
                  category: category,
                  locale: locale,
                  spent: month.expenseByCategory[category.id] ?? 0,
                  budget: _budgetFor(budgets, category.id),
                  onTap: () => _edit(context, ref, category, budgets),
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Budget? _budgetFor(List<Budget> budgets, int categoryId) {
    for (final row in budgets) {
      if (row.categoryId == categoryId) return row;
    }
    return null;
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Category category,
    List<Budget> budgets,
  ) async {
    final l10n = AppLocalizations.of(context);
    Budget? existing;
    for (final row in budgets) {
      if (row.categoryId == category.id) existing = row;
    }
    final controller = TextEditingController(
      text: existing == null ? '' : existing.monthlyLimit.toStringAsFixed(0),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.monthlyLimit),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.monthlyLimit,
            prefixText: '฿ ',
          ),
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.removeBudget),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.saveBudget),
          ),
        ],
      ),
    );
    final limit = double.tryParse(controller.text);
    controller.dispose();
    if (saved == true && limit != null && limit > 0) {
      await ref.read(databaseProvider).upsertBudget(category.id, limit);
    } else if (saved == false) {
      await ref.read(databaseProvider).deleteBudgetFor(category.id);
    }
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.category,
    required this.locale,
    required this.spent,
    required this.budget,
    required this.onTap,
  });

  final Category category;
  final Locale locale;
  final double spent;
  final Budget? budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (budget != null) {
      final style = categoryStyle(category.key);
      return BudgetProgress(
        name: categoryLabel(category, locale),
        spent: spent,
        limit: budget!.monthlyLimit,
        locale: locale,
        color: style.color,
        icon: style.icon,
        onTap: onTap,
      );
    }
    final style = categoryStyle(category.key);
    return BbRow(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: style.color.withValues(alpha: 0.16),
            child: Icon(style.icon, size: 16, color: style.color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(categoryLabel(category, locale))),
          Text(
            l10n.noBudget,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ],
      ),
    );
  }
}
