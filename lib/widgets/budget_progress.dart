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
    this.color,
    this.icon,
    this.onTap,
  });

  final String name;
  final double spent;
  final double limit;
  final Locale locale;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final remaining = (limit - spent).clamp(0.0, limit);
    final base = color ?? bahtAccent;
    final barColor = ratio >= 1
        ? bahtExpense
        : ratio >= 0.8
        ? bahtSun
        : base;
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
              if (icon != null) ...[
                Icon(icon, size: 18, color: barColor),
                const SizedBox(width: 8),
              ],
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: barColor,
                backgroundColor: barColor.withValues(alpha: 0.16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: barColor),
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
