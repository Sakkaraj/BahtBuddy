import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/db/app_database.dart';

const bahtAccent = Color(0xFF146C54);
const bahtIncome = Color(0xFF1B7F6B);
const bahtExpense = Color(0xFFC0392B);

ThemeData bahtTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: bahtAccent,
    brightness: brightness,
  );
  final grouped = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFF2F2F7);
  final surface = brightness == Brightness.dark
      ? const Color(0xFF1C1C1E)
      : Colors.white;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(surface: surface, surfaceContainerLowest: grouped),
    scaffoldBackgroundColor: grouped,
    appBarTheme: AppBarTheme(
      backgroundColor: grouped,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    dividerColor: brightness == Brightness.dark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFC6C6C8),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bahtAccent, width: 1.5),
      ),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: bahtAccent,
      scaffoldBackgroundColor: grouped,
    ),
  );
}

Color groupedBackground(BuildContext context) {
  return CupertinoColors.systemGroupedBackground.resolveFrom(context);
}

Color groupedSurface(BuildContext context) {
  return CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
}

const categoryColors = <Color>[
  Color(0xFF1B7F6B),
  Color(0xFFE09F3E),
  Color(0xFF3D5A80),
  Color(0xFF9B2226),
  Color(0xFF6A4C93),
  Color(0xFF2A9D8F),
  Color(0xFFBC6C25),
  Color(0xFF577590),
  Color(0xFF4C956C),
];

String categoryLabel(Category category, Locale locale) =>
    locale.languageCode == 'th' ? category.nameTh : category.nameEn;

String formatBaht(Locale locale, double amount) {
  return NumberFormat.currency(
    locale: locale.languageCode == 'th' ? 'th' : 'en',
    symbol: '฿',
    decimalDigits: 2,
  ).format(amount);
}

String formatSignedBaht(Locale locale, double amount, {required bool income}) {
  final value = formatBaht(locale, amount);
  return income ? '+$value' : '−$value';
}

String formatWhen(Locale locale, DateTime date) {
  final pattern = DateFormat.yMMMd(locale.languageCode).add_Hm();
  return pattern.format(date);
}

String formatDay(Locale locale, DateTime date) {
  return DateFormat.yMMMEd(locale.languageCode).format(date);
}

String formatTime(Locale locale, DateTime date) {
  return DateFormat.Hm(locale.languageCode).format(date);
}

DateTime dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

Color amountColor(BuildContext context, {required bool income}) {
  return income ? bahtIncome : Theme.of(context).colorScheme.error;
}
