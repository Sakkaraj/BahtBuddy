import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';

class BbGroupedSection extends StatelessWidget {
  const BbGroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.headerTrailing,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final dividerColor = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null || headerTrailing != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
              child: Row(
                children: [
                  if (header != null)
                    Expanded(
                      child: Text(
                        header!.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                          letterSpacing: 0.4,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  ?headerTrailing,
                ],
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: groupedSurface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      color: dividerColor,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                footer!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BbRow extends StatelessWidget {
  const BbRow({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
