import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/clock.dart';

class BudgetAlerts {
  Future<void> notify({
    required int id,
    required String title,
    required String body,
  }) async {}

  Future<void> setDailyReminder({
    required bool enabled,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {}
}

class LocalBudgetAlerts implements BudgetAlerts {
  LocalBudgetAlerts(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _dailyId = 1;

  static Future<LocalBudgetAlerts> create() async {
    initClock();
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    return LocalBudgetAlerts(plugin);
  }

  @override
  Future<void> notify({
    required int id,
    required String title,
    required String body,
  }) async {
    await _request();
    await _plugin.show(
      id: 1000 + id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'bahtbuddy_budget',
          'Budgets',
          channelDescription: 'Budget alerts and reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> setDailyReminder({
    required bool enabled,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.cancel(id: _dailyId);
    if (!enabled) return;
    await _request();
    final now = tz.TZDateTime.now(activeZone);
    var scheduled = tz.TZDateTime(
      activeZone,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _dailyId,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'bahtbuddy_budget',
          'Budgets',
          channelDescription: 'Budget alerts and reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _request() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
  }
}
