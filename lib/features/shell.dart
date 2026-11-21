import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/format.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: groupedBackground(context),
      body: navigationShell,
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: navigationShell.currentIndex,
        activeColor: bahtAccent,
        backgroundColor: groupedSurface(context).withValues(alpha: 0.94),
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.house),
            activeIcon: const Icon(CupertinoIcons.house_fill),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.list_bullet),
            activeIcon: const Icon(CupertinoIcons.list_bullet),
            label: l10n.navHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_pie),
            activeIcon: const Icon(CupertinoIcons.chart_pie_fill),
            label: l10n.navReports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            activeIcon: const Icon(CupertinoIcons.settings_solid),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
