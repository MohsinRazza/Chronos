import 'package:flutter/material.dart';

class ShadColors {
  // Zinc Light Palette
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color foregroundLight = Color(0xFF09090B);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardForegroundLight = Color(0xFF09090B);
  static const Color popoverLight = Color(0xFFFFFFFF);
  static const Color popoverForegroundLight = Color(0xFF09090B);
  static const Color primaryLight = Color(0xFF09090B);
  static const Color primaryForegroundLight = Color(0xFFFAFAFA);
  static const Color secondaryLight = Color(0xFFF4F4F5);
  static const Color secondaryForegroundLight = Color(0xFF18181B);
  static const Color mutedLight = Color(0xFFF4F4F5);
  static const Color mutedForegroundLight = Color(0xFF71717A);
  static const Color accentLight = Color(0xFFF4F4F5);
  static const Color accentForegroundLight = Color(0xFF18181B);
  static const Color destructiveLight = Color(0xFFEF4444);
  static const Color destructiveForegroundLight = Color(0xFFFAFAFA);
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color inputLight = Color(0xFFE4E4E7);
  static const Color ringLight = Color(0xFF18181B);

  // Zinc Dark Palette
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color foregroundDark = Color(0xFFFAFAFA);
  static const Color cardDark = Color(0xFF09090B);
  static const Color cardForegroundDark = Color(0xFFFAFAFA);
  static const Color popoverDark = Color(0xFF09090B);
  static const Color popoverForegroundDark = Color(0xFFFAFAFA);
  static const Color primaryDark = Color(0xFFFAFAFA);
  static const Color primaryForegroundDark = Color(0xFF09090B);
  static const Color secondaryDark = Color(0xFF27272A);
  static const Color secondaryForegroundDark = Color(0xFFFAFAFA);
  static const Color mutedDark = Color(0xFF27272A);
  static const Color mutedForegroundDark = Color(0xFFA1A1AA);
  static const Color accentDark = Color(0xFF27272A);
  static const Color accentForegroundDark = Color(0xFFFAFAFA);
  static const Color destructiveDark = Color(0xFF7F1D1D);
  static const Color destructiveForegroundDark = Color(0xFFFAFAFA);
  static const Color borderDark = Color(0xFF27272A);
  static const Color inputDark = Color(0xFF27272A);
  static const Color ringDark = Color(0xFFD4D4D8);

  // Event Categories & Colors
  static const Color work = Color(0xFF3B82F6);        // Blue
  static const Color personal = Color(0xFF10B981);    // Emerald
  static const Color health = Color(0xFFEF4444);      // Red
  static const Color education = Color(0xFFF59E0B);   // Amber
  static const Color finance = Color(0xFF8B5CF6);     // Purple
  static const Color travel = Color(0xFFEC4899);      // Pink
}

class ShadTheme {
  final bool isDark;
  
  ShadTheme({required this.isDark});

  Color get background => isDark ? ShadColors.backgroundDark : ShadColors.backgroundLight;
  Color get foreground => isDark ? ShadColors.foregroundDark : ShadColors.foregroundLight;
  Color get card => isDark ? ShadColors.cardDark : ShadColors.cardLight;
  Color get cardForeground => isDark ? ShadColors.cardForegroundDark : ShadColors.cardForegroundLight;
  Color get popover => isDark ? ShadColors.popoverDark : ShadColors.popoverLight;
  Color get popoverForeground => isDark ? ShadColors.popoverForegroundDark : ShadColors.popoverForegroundLight;
  Color get primary => isDark ? ShadColors.primaryDark : ShadColors.primaryLight;
  Color get primaryForeground => isDark ? ShadColors.primaryForegroundDark : ShadColors.primaryForegroundLight;
  Color get secondary => isDark ? ShadColors.secondaryDark : ShadColors.secondaryLight;
  Color get secondaryForeground => isDark ? ShadColors.secondaryForegroundDark : ShadColors.secondaryForegroundLight;
  Color get muted => isDark ? ShadColors.mutedDark : ShadColors.mutedLight;
  Color get mutedForeground => isDark ? ShadColors.mutedForegroundDark : ShadColors.mutedForegroundLight;
  Color get accent => isDark ? ShadColors.accentDark : ShadColors.accentLight;
  Color get accentForeground => isDark ? ShadColors.accentForegroundDark : ShadColors.accentForegroundLight;
  Color get destructive => isDark ? ShadColors.destructiveDark : ShadColors.destructiveLight;
  Color get destructiveForeground => isDark ? ShadColors.destructiveForegroundDark : ShadColors.destructiveForegroundLight;
  Color get border => isDark ? ShadColors.borderDark : ShadColors.borderLight;
  Color get input => isDark ? ShadColors.inputDark : ShadColors.inputLight;
  Color get ring => isDark ? ShadColors.ringDark : ShadColors.ringLight;

  static ShadTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ShadTheme(isDark: brightness == Brightness.dark);
  }

  ThemeData get themeData {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: border,
      dialogBackgroundColor: popover,
      dialogTheme: DialogThemeData(
        backgroundColor: popover,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: popover,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        dividerColor: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: popover,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        error: destructive,
        onError: destructiveForeground,
        background: background,
        onBackground: foreground,
        surface: card,
        onSurface: cardForeground,
        outline: border,
        outlineVariant: border,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
        fontFamily: 'Inter',
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
