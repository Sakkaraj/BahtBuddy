import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers.dart';
import 'services/budget_alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final alerts = await LocalBudgetAlerts.create();
  runApp(
    ProviderScope(
      overrides: [budgetAlertsProvider.overrideWithValue(alerts)],
      child: const BahtBuddyApp(),
    ),
  );
}
