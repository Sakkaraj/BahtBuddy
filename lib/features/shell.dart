import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'add/add_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  var _homeWasOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshNews();
  }

  void _refreshNews() {
    final posts = ref.read(moneyPostsProvider);
    if (posts.isLoading) return;
    ref.read(moneyPostsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final onHome = widget.navigationShell.currentIndex == 0;
    if (onHome && !_homeWasOpen) {
      _homeWasOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshNews();
      });
    } else if (!onHome) {
      _homeWasOpen = false;
    }
    final l10n = AppLocalizations.of(context);
    final look = BuddyLook.of(context);
    final items = [
      _NavSpec(Icons.home_rounded, l10n.navHome, look.accent),
      _NavSpec(Icons.receipt_long_rounded, l10n.navHistory, Color(0xFF1E4B7A)),
      _NavSpec(Icons.pie_chart_rounded, l10n.navReports, Color(0xFFC4A35A)),
      _NavSpec(Icons.settings_rounded, l10n.navSettings, bahtSky),
    ];
    return BuddyBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.navigationShell,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    groupedSurface(context).withValues(alpha: 0.94),
                    Color.alphaBlend(
                      const Color(0xFF1E4B7A).withValues(alpha: 0.14),
                      groupedSurface(context),
                    ),
                    Color.alphaBlend(
                      look.accent.withValues(alpha: 0.16),
                      groupedSurface(context),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12324F).withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i == 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _AddOrb(
                            tooltip: l10n.navAdd,
                            onTap: () => showAddActions(context, ref),
                          ),
                        ),
                      Expanded(
                        child: _NavButton(
                          spec: items[i],
                          selected: widget.navigationShell.currentIndex == i,
                          onTap: () => widget.navigationShell.goBranch(
                            i,
                            initialLocation:
                                i == widget.navigationShell.currentIndex,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? spec.color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: Icon(
                spec.icon,
                color: selected
                    ? spec.color
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? spec.color
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOrb extends StatelessWidget {
  const _AddOrb({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bahtInk, BuddyLook.of(context).accent],
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
