import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/db/app_database.dart';

const bahtFont = 'PlusJakartaSans';
const bahtAccent = Color(0xFF0E9F8A);
const bahtInk = Color(0xFF0E1C2F);
const bahtInkDark = Color(0xFFF4F7FA);
const bahtMuted = Color(0xFF5E7082);
const bahtMutedDark = Color(0xFF9AA8B5);
const bahtIncome = Color(0xFF12B981);
const bahtExpense = Color(0xFFFF5A6A);
const bahtSun = Color(0xFFFFB020);
const bahtSky = Color(0xFF3B82F6);

ThemeData bahtTheme(BuddyLook look) {
  final brightness = look.brightness;
  final dark = brightness == Brightness.dark;
  final ink = dark ? bahtInkDark : bahtInk;
  final muted = dark ? bahtMutedDark : bahtMuted;
  final scheme = ColorScheme.fromSeed(
    seedColor: bahtAccent,
    brightness: brightness,
  ).copyWith(
    primary: bahtAccent,
    surface: look.surface,
    surfaceContainerLowest: look.grouped,
    onSurface: ink,
    onSurfaceVariant: muted,
  );
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.android,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      },
    ),
    fontFamily: bahtFont,
    colorScheme: scheme,
    textTheme: _bahtType(ink, muted),
    scaffoldBackgroundColor: look.grouped,
    appBarTheme: AppBarTheme(
      backgroundColor: look.grouped,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: bahtFont,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: ink,
      ),
    ),
    dividerColor: dark ? const Color(0xFF2C3440) : const Color(0xFFE3E8EE),
    cardTheme: CardThemeData(
      color: look.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: bahtAccent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: bahtAccent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: bahtFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: ink,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: look.surface,
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
      scaffoldBackgroundColor: look.grouped,
      textTheme: CupertinoTextThemeData(
        primaryColor: bahtAccent,
        textStyle: TextStyle(
          fontFamily: bahtFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ink,
          height: 1.35,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: bahtFont,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: ink,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: bahtFont,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.1,
          color: ink,
        ),
        actionTextStyle: const TextStyle(
          fontFamily: bahtFont,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: bahtAccent,
        ),
      ),
    ),
    extensions: [look],
  );
}

class BahtScrollBehavior extends MaterialScrollBehavior {
  const BahtScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

TextTheme _bahtType(Color ink, Color muted) {
  return TextTheme(
    displaySmall: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w800,
      fontSize: 36,
      letterSpacing: -1.2,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: ink,
    ),
    titleSmall: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: ink,
    ),
    bodySmall: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w500,
      color: muted,
    ),
    labelLarge: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: ink,
    ),
    labelMedium: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
    labelSmall: TextStyle(
      fontFamily: bahtFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: muted,
    ),
  );
}

class BuddyLook extends ThemeExtension<BuddyLook> {
  const BuddyLook({
    required this.brightness,
    required this.grouped,
    required this.surface,
    required this.canvas,
    required this.orbA,
    required this.orbB,
    required this.banner,
    required this.bannerInk,
    required this.bannerFilled,
  });

  final Brightness brightness;
  final Color grouped;
  final Color surface;
  final LinearGradient canvas;
  final Color orbA;
  final Color orbB;
  final LinearGradient banner;
  final Color bannerInk;
  final bool bannerFilled;

  static const color = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFE7F6EF),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB7F0D8), Color(0xFFE5FFF3), Color(0xFFCFF6E4)],
    ),
    orbA: Color(0xFF10B981),
    orbB: Color(0xFF047857),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF065F46), Color(0xFF0E9F8A), Color(0xFF34D399)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
  );

  static const white = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFF7F7F7),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
    ),
    orbA: Color(0xFFE5E7EB),
    orbB: Color(0xFFF3F4F6),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
    ),
    bannerInk: Color(0xFF111827),
    bannerFilled: false,
  );

  static const ocean = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFE8F1FB),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFFBFDBFE), Color(0xFFE8F2FF), Color(0xFFD6E6FA)],
    ),
    orbA: Color(0xFF2563EB),
    orbB: Color(0xFF38BDF8),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B3A82), Color(0xFF1D4ED8), Color(0xFF38BDF8)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
  );

  static const night = BuddyLook(
    brightness: Brightness.dark,
    grouped: Color(0xFF0B1220),
    surface: Color(0xFF172554),
    canvas: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E3A8A), Color(0xFF172554), Color(0xFF0B1220)],
    ),
    orbA: Color(0xFF3B82F6),
    orbB: Color(0xFF60A5FA),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF1D4ED8)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
  );

  static const black = BuddyLook(
    brightness: Brightness.dark,
    grouped: Color(0xFF000000),
    surface: Color(0xFF14120E),
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF000000), Color(0xFF050504), Color(0xFF120E08)],
    ),
    orbA: Color(0xFFC4A35A),
    orbB: Color(0xFF6B5424),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A1408), Color(0xFF3D3218), Color(0xFFC4A35A)],
    ),
    bannerInk: Color(0xFFFFF8E8),
    bannerFilled: true,
  );

  static BuddyLook of(BuildContext context) {
    return Theme.of(context).extension<BuddyLook>() ?? color;
  }

  static const day = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFEEF1F4),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE4E9EF), Color(0xFFF7F8FA), Color(0xFFE7EBEF)],
    ),
    orbA: Color(0xFF8AA0B8),
    orbB: Color(0xFFC5D0DC),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1C2B3A), Color(0xFF2C4158)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
  );

  static BuddyLook forId(String id) {
    return switch (id) {
      'white' || 'light' => white,
      'black' => black,
      'ocean' => ocean,
      'dark' => night,
      'system' => day,
      'color' => color,
      _ => color,
    };
  }

  @override
  BuddyLook copyWith({
    Brightness? brightness,
    Color? grouped,
    Color? surface,
    LinearGradient? canvas,
    Color? orbA,
    Color? orbB,
    LinearGradient? banner,
    Color? bannerInk,
    bool? bannerFilled,
  }) {
    return BuddyLook(
      brightness: brightness ?? this.brightness,
      grouped: grouped ?? this.grouped,
      surface: surface ?? this.surface,
      canvas: canvas ?? this.canvas,
      orbA: orbA ?? this.orbA,
      orbB: orbB ?? this.orbB,
      banner: banner ?? this.banner,
      bannerInk: bannerInk ?? this.bannerInk,
      bannerFilled: bannerFilled ?? this.bannerFilled,
    );
  }

  @override
  BuddyLook lerp(ThemeExtension<BuddyLook>? other, double t) {
    if (other is! BuddyLook) return this;
    return t < 0.5 ? this : other;
  }
}

class BuddyBackdrop extends StatelessWidget {
  const BuddyBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final look = BuddyLook.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: look.canvas),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(color: look.orbA, size: 340),
          ),
          Positioned(
            left: -110,
            top: 180,
            child: _Glow(color: look.orbB, size: 280),
          ),
          Positioned(
            right: -40,
            bottom: 40,
            child: _Glow(color: look.orbA, size: 220),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.55),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

Color groupedBackground(BuildContext context) {
  return Theme.of(context).scaffoldBackgroundColor;
}

Color groupedSurface(BuildContext context) {
  return Theme.of(context).colorScheme.surface;
}

const categoryColors = <Color>[
  Color(0xFFFF6B6B),
  Color(0xFF4D96FF),
  Color(0xFFFF8A3D),
  Color(0xFF1E4B7A),
  Color(0xFFFF5DA2),
  Color(0xFF2EC4B6),
  Color(0xFF3DDC97),
  Color(0xFFF5C542),
  Color(0xFF94A3B8),
];

class CategoryStyle {
  const CategoryStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}

CategoryStyle categoryStyle(String? key) {
  return switch (key) {
    'food' => const CategoryStyle(Icons.restaurant_rounded, Color(0xFFFF6B6B)),
    'transport' => const CategoryStyle(
      Icons.directions_bus_rounded,
      Color(0xFF4D96FF),
    ),
    'shopping' => const CategoryStyle(
      Icons.shopping_bag_rounded,
      Color(0xFFFF8A3D),
    ),
    'bills' => const CategoryStyle(Icons.receipt_long_rounded, Color(0xFF1E4B7A)),
    'entertainment' => const CategoryStyle(
      Icons.movie_rounded,
      Color(0xFFFF5DA2),
    ),
    'health' => const CategoryStyle(Icons.favorite_rounded, Color(0xFF2EC4B6)),
    'education' => const CategoryStyle(Icons.school_rounded, Color(0xFF3DDC97)),
    'salary' => const CategoryStyle(Icons.payments_rounded, Color(0xFF12B981)),
    'bonus' => const CategoryStyle(Icons.workspace_premium_rounded, Color(0xFFC4A35A)),
    'freelance' => const CategoryStyle(Icons.laptop_mac_rounded, Color(0xFF0E9F8A)),
    'gift' => const CategoryStyle(Icons.card_giftcard_rounded, Color(0xFF3B82F6)),
    'interest' => const CategoryStyle(Icons.savings_rounded, Color(0xFF1E4B7A)),
    'refund' => const CategoryStyle(Icons.replay_rounded, Color(0xFF0E7C72)),
    'other_income' => const CategoryStyle(Icons.account_balance_wallet_rounded, Color(0xFF5E7082)),
    _ => const CategoryStyle(Icons.category_rounded, Color(0xFF94A3B8)),
  };
}

LinearGradient buddyCanvas(BuildContext context) => BuddyLook.of(context).canvas;

LinearGradient cardWash(BuildContext context) {
  final look = BuddyLook.of(context);
  final base = look.surface;
  final dark = look.brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      base,
      Color.alphaBlend(
        look.orbA.withValues(alpha: dark ? 0.28 : 0.12),
        base,
      ),
      Color.alphaBlend(
        look.orbB.withValues(alpha: dark ? 0.2 : 0.1),
        base,
      ),
    ],
  );
}

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
