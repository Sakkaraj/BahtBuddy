import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Stored preference that means "use the phone's time zone".
const autoTimeZone = 'auto';

const _preferredZones = [
  'Asia/Bangkok',
  'Asia/Singapore',
  'Asia/Hong_Kong',
  'Asia/Tokyo',
  'Asia/Seoul',
  'Asia/Shanghai',
  'Asia/Kolkata',
  'Asia/Dubai',
  'Europe/London',
  'Europe/Paris',
  'Europe/Berlin',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'Australia/Sydney',
  'Pacific/Auckland',
  'UTC',
];

bool _ready = false;
String timeZoneChoice = autoTimeZone;
tz.Location? _active;

/// Loads the IANA database. The same Dart data is used on Android and iOS.
void initClock() {
  if (_ready) return;
  tzdata.initializeTimeZones();
  _ready = true;
  _active = tz.getLocation(zoneIdForOffset(DateTime.now().timeZoneOffset));
  tz.setLocalLocation(_active!);
}

tz.Location get activeZone {
  initClock();
  return _active!;
}

String get activeZoneId => activeZone.name;

/// IANA ids, sorted, for the settings list.
List<String> timeZoneIds() {
  initClock();
  final names = tz.timeZoneDatabase.locations.keys.toList()..sort();
  return names;
}

/// The phone's IANA id. Falls back to a zone with the same offset.
Future<String> deviceTimeZoneId() async {
  initClock();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.getLocation(info.identifier);
    return info.identifier;
  } catch (_) {
    return zoneIdForOffset(DateTime.now().timeZoneOffset);
  }
}

/// Applies [choice], which is [autoTimeZone] or an IANA id such as Asia/Bangkok.
Future<void> applyTimeZone(String choice) async {
  initClock();
  timeZoneChoice = choice;
  final id = choice == autoTimeZone ? await deviceTimeZoneId() : choice;
  _active = _location(id);
  tz.setLocalLocation(_active!);
}

/// Pins the clock without asking the phone. Used by tests and by a saved choice.
void useTimeZone(String id) {
  initClock();
  timeZoneChoice = id;
  _active = _location(id);
  tz.setLocalLocation(_active!);
}

tz.Location _location(String id) {
  final name = id == 'UTC' || id == 'GMT' ? 'Etc/UTC' : id;
  try {
    return tz.getLocation(name);
  } catch (_) {
    if (name == 'Etc/UTC') return tz.UTC;
    return tz.getLocation(zoneIdForOffset(DateTime.now().timeZoneOffset));
  }
}

/// A known zone whose current offset matches [offset].
String zoneIdForOffset(Duration offset) {
  for (final name in _preferredZones) {
    final location = tz.getLocation(name);
    if (tz.TZDateTime.now(location).timeZoneOffset == offset) return name;
  }
  for (final location in tz.timeZoneDatabase.locations.values) {
    if (tz.TZDateTime.now(location).timeZoneOffset == offset) {
      return location.name;
    }
  }
  return 'UTC';
}

/// Wall-clock fields in the active zone, as a plain [DateTime].
DateTime zoneWall(DateTime instant) {
  final zoned = tz.TZDateTime.from(instant, activeZone);
  return DateTime(
    zoned.year,
    zoned.month,
    zoned.day,
    zoned.hour,
    zoned.minute,
    zoned.second,
    zoned.millisecond,
    zoned.microsecond,
  );
}

DateTime zoneNow() => zoneWall(DateTime.now());

/// Reads [wall]'s calendar fields as the active zone and returns that instant.
tz.TZDateTime zoneInstant(DateTime wall) {
  return tz.TZDateTime(
    activeZone,
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
    wall.second,
    wall.millisecond,
    wall.microsecond,
  );
}

/// `yyyy-MM-dd` from a wall-clock value. Dated APIs use this day.
String zoneDateStamp(DateTime wall) {
  final year = wall.year.toString().padLeft(4, '0');
  final month = wall.month.toString().padLeft(2, '0');
  final day = wall.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// ISO-8601 timestamp with the active zone's current offset.
String zoneIso(DateTime instant) {
  final zoned = tz.TZDateTime.from(instant, activeZone);
  String two(int value) => value.toString().padLeft(2, '0');
  final offset = zoned.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '${zoneDateStamp(DateTime(zoned.year, zoned.month, zoned.day))}'
      'T${two(zoned.hour)}:${two(zoned.minute)}:${two(zoned.second)}'
      '$sign$hours:$minutes';
}

String zoneGmt(String id) {
  final offset = tz.TZDateTime.now(_location(id)).timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs();
  final minutes = offset.inMinutes.abs() % 60;
  if (minutes == 0) return 'GMT$sign$hours';
  return 'GMT$sign$hours:${minutes.toString().padLeft(2, '0')}';
}

String zoneLabel(String id) => id.replaceAll('_', ' ');

String zoneCity(String id) => id.split('/').last.replaceAll('_', ' ');
