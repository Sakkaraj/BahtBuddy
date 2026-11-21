import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/db/app_database.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.title,
    required this.locale,
    this.onTap,
    this.onLongPress,
    this.showDate = true,
  });

  final MoneyTransaction transaction;
  final String title;
  final Locale locale;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final income = transaction.type == 'income';
    final subtitleParts = <String>[
      if (showDate) formatTime(locale, transaction.occurredAt),
      if (transaction.recipient != null && transaction.recipient!.isNotEmpty)
        transaction.recipient!,
      if (transaction.note.isNotEmpty) transaction.note,
    ];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatSignedBaht(
                  locale,
                  transaction.amount,
                  income: income,
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amountColor(context, income: income),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
