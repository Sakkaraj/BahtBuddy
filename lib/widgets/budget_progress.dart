import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../l10n/app_localizations.dart';

class BudgetProgress extends StatelessWidget {
  const BudgetProgress({
    super.key,
    required this.name,
    required this.spent,
    required this.limit,
    required this.locale,
    this.onTap,
  });

  final String name;
  final double spent;
  final double limit;
  final Locale locale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final remaining = (limit - spent).clamp(0.0, limit);
    final color = ratio >= 1
        ? Theme.of(context).colorScheme.error
        : ratio >= 0.8
        ? const Color(0xFFE09F3E)
        : bahtAccent;
    final caption = spent > limit
        ? l10n.overBudget
        : l10n.remainingOf(formatBaht(locale, remaining));
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
              ),
              Text(
                l10n.spentOf(
                  formatBaht(locale, spent),
                  formatBaht(locale, limit),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: 0.18),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
