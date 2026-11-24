import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/db/app_database.dart';
import 'clock.dart';

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

/// The same calendar the Android build shows, including on iPhone.
Future<DateTime?> showBuddyDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    initialEntryMode: DatePickerEntryMode.calendar,
    builder: _androidChrome,
  );
}

/// The same clock the Android build shows, including on iPhone.
Future<TimeOfDay?> showBuddyTime(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.dial,
    builder: _androidChrome,
  );
}

Widget _androidChrome(BuildContext context, Widget? child) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(platform: TargetPlatform.android),
    child: child ?? const SizedBox.shrink(),
  );
}

ThemeData bahtTheme(BuddyLook look) {
  final brightness = look.brightness;
  final dark = brightness == Brightness.dark;
  final ink = dark ? bahtInkDark : bahtInk;
  final muted = dark ? bahtMutedDark : bahtMuted;
  final scheme = ColorScheme.fromSeed(
    seedColor: look.accent,
    brightness: brightness,
  ).copyWith(
    primary: look.accent,
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
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: look.accent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: look.accent.withValues(alpha: 0.18),
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
        borderSide: BorderSide(color: look.accent, width: 1.5),
      ),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: look.accent,
      scaffoldBackgroundColor: look.grouped,
      textTheme: CupertinoTextThemeData(
        primaryColor: look.accent,
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
        actionTextStyle: TextStyle(
          fontFamily: bahtFont,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: look.accent,
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
    required this.accent,
    required this.banner,
    required this.bannerInk,
    required this.bannerFilled,
    required this.cardImage,
    required this.glass,
  });

  final Brightness brightness;
  final Color grouped;
  final Color surface;
  final LinearGradient canvas;
  final Color orbA;
  final Color orbB;
  final Color accent;
  final LinearGradient banner;
  final Color bannerInk;
  final bool bannerFilled;
  final String cardImage;

  /// Frosted tint over [cardImage]. Light enough that the photograph stays visible.
  final List<Color> glass;

  static const color = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFD1FAE5),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6EE7B7), Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
    ),
    orbA: Color(0xFF10B981),
    orbB: Color(0xFF34D399),
    accent: Color(0xFF059669),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF047857), Color(0xFF10B981), Color(0xFF6EE7B7)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
    cardImage: 'assets/theme_color.jpg',
    glass: [Color(0x4D047857), Color(0x73065F46)],
  );

  static const white = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFF4FFFB),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA), Color(0xFFE0F7F4)],
    ),
    orbA: Color(0xFF5EEAD4),
    orbB: Color(0xFFF5C542),
    accent: Color(0xFF0E9F8A),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF8FFFD), Color(0xFFE7F8F4), Color(0xFFD6F3EC)],
    ),
    bannerInk: Color(0xFF0E1C2F),
    bannerFilled: false,
    cardImage: 'assets/theme_white.jpg',
    glass: [Color(0xC7FFFFFF), Color(0xB8E7F6F2)],
  );

  static const ocean = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFD7F3FF),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF7DD3FC), Color(0xFFE0F7FF), Color(0xFFBAE6FD)],
    ),
    orbA: Color(0xFF0284C7),
    orbB: Color(0xFF22D3EE),
    accent: Color(0xFF0284C7),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF22D3EE)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
    cardImage: 'assets/theme_ocean.jpg',
    glass: [Color(0x4D0369A1), Color(0x730B3A82)],
  );

  static const night = BuddyLook(
    brightness: Brightness.dark,
    grouped: Color(0xFF070E1C),
    surface: Color(0xFF13284A),
    canvas: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D4ED8), Color(0xFF0F2744), Color(0xFF070E1C)],
    ),
    orbA: Color(0xFF38BDF8),
    orbB: Color(0xFF22D3EE),
    accent: Color(0xFF38BDF8),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF38BDF8)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
    cardImage: 'assets/theme_dark.jpg',
    glass: [Color(0x661E3A8A), Color(0x99070E1C)],
  );

  static const black = BuddyLook(
    brightness: Brightness.dark,
    grouped: Color(0xFF000000),
    surface: Color(0xFF1A140C),
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF000000), Color(0xFF120E08), Color(0xFF3A2A10)],
    ),
    orbA: Color(0xFFF5C542),
    orbB: Color(0xFFE8B84A),
    accent: Color(0xFFE8B84A),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A1408), Color(0xFF6B4E16), Color(0xFFF5C542)],
    ),
    bannerInk: Color(0xFFFFF8E8),
    bannerFilled: true,
    cardImage: 'assets/theme_black.jpg',
    glass: [Color(0x660A0906), Color(0x996B4E16)],
  );

  static BuddyLook of(BuildContext context) {
    return Theme.of(context).extension<BuddyLook>() ?? color;
  }

  static const day = BuddyLook(
    brightness: Brightness.light,
    grouped: Color(0xFFE7EEF6),
    surface: Colors.white,
    canvas: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFCBD5E1), Color(0xFFF8FAFC), Color(0xFFD6E4F0)],
    ),
    orbA: Color(0xFF1E4B7A),
    orbB: Color(0xFF38BDF8),
    accent: Color(0xFF0E9F8A),
    banner: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F2744), Color(0xFF1E4B7A), Color(0xFF38BDF8)],
    ),
    bannerInk: Colors.white,
    bannerFilled: true,
    cardImage: 'assets/theme_day.jpg',
    glass: [Color(0x591C2B3A), Color(0x800F2744)],
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
    Color? accent,
    LinearGradient? banner,
    Color? bannerInk,
    bool? bannerFilled,
    String? cardImage,
    List<Color>? glass,
  }) {
    return BuddyLook(
      brightness: brightness ?? this.brightness,
      grouped: grouped ?? this.grouped,
      surface: surface ?? this.surface,
      canvas: canvas ?? this.canvas,
      orbA: orbA ?? this.orbA,
      orbB: orbB ?? this.orbB,
      accent: accent ?? this.accent,
      banner: banner ?? this.banner,
      bannerInk: bannerInk ?? this.bannerInk,
      bannerFilled: bannerFilled ?? this.bannerFilled,
      cardImage: cardImage ?? this.cardImage,
      glass: glass ?? this.glass,
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
  return pattern.format(zoneWall(date));
}

String formatDay(Locale locale, DateTime date) {
  return DateFormat.yMMMEd(locale.languageCode).format(date);
}

String formatTime(Locale locale, DateTime date) {
  return DateFormat.Hm(locale.languageCode).format(zoneWall(date));
}

DateTime dayKey(DateTime date) {
  final wall = zoneWall(date);
  return DateTime(wall.year, wall.month, wall.day);
}

Color amountColor(BuildContext context, {required bool income}) {
  return income ? bahtIncome : Theme.of(context).colorScheme.error;
}
