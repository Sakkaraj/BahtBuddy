import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = CupertinoIcons.tray,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF12324F), Color(0xFF0E9F8A)],
                  ),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(16),
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          if (secondaryLabel != null && onSecondary != null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: onSecondary,
              child: Text(
                secondaryLabel!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class MoneyText extends StatelessWidget {
  const MoneyText(
    this.value, {
    super.key,
    this.style,
    this.income,
  });

  final String value;
  final TextStyle? style;
  final bool? income;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: (style ?? Theme.of(context).textTheme.headlineMedium)?.copyWith(
        color: income == null
            ? null
            : amountColor(context, income: income!),
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
