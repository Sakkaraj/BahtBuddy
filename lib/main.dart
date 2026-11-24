import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/clock.dart';
import 'data/db/app_database.dart';
import 'providers.dart';
import 'services/budget_alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initClock();
  final opening = AppDatabase();
  try {
    await startOnSystemTheme(opening, rememberTheme: kReleaseMode);
  } finally {
    await opening.close();
  }
  final alerts = await LocalBudgetAlerts.create();
  runApp(
    ProviderScope(
      overrides: [budgetAlertsProvider.overrideWithValue(alerts)],
      child: const BahtBuddyApp(),
    ),
  );
}
