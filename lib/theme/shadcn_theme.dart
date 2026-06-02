import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColorPalette {
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color border;
  final Color input;
  final Color ring;

  const ThemeColorPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
  });
}

class ShadColors {
  // Zinc Light Palette (Default)
  static const ThemeColorPalette zincLight = ThemeColorPalette(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF09090B),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF18181B),
  );

  // Zinc Dark Palette
  static const ThemeColorPalette zincDark = ThemeColorPalette(
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    card: Color(0xFF09090B),
    cardForeground: Color(0xFFFAFAFA),
    popover: Color(0xFF09090B),
    popoverForeground: Color(0xFFFAFAFA),
    primary: Color(0xFFFAFAFA),
    primaryForeground: Color(0xFF09090B),
    secondary: Color(0xFF27272A),
    secondaryForeground: Color(0xFFFAFAFA),
    muted: Color(0xFF27272A),
    mutedForeground: Color(0xFFA1A1AA),
    accent: Color(0xFF27272A),
    accentForeground: Color(0xFFFAFAFA),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFF27272A),
    input: Color(0xFF27272A),
    ring: Color(0xFFD4D4D8),
  );

  // Olive Light Palette
  static const ThemeColorPalette oliveLight = ThemeColorPalette(
    background: Color(0xFFFAFDF6),
    foreground: Color(0xFF1D280E),
    card: Color(0xFFFAFDF6),
    cardForeground: Color(0xFF1D280E),
    popover: Color(0xFFFAFDF6),
    popoverForeground: Color(0xFF1D280E),
    primary: Color(0xFF3F6212),
    primaryForeground: Color(0xFFFAFDF6),
    secondary: Color(0xFFEBF3DE),
    secondaryForeground: Color(0xFF3F6212),
    muted: Color(0xFFEBF3DE),
    mutedForeground: Color(0xFF5B6E4A),
    accent: Color(0xFFEBF3DE),
    accentForeground: Color(0xFF3F6212),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE2EAD6),
    input: Color(0xFFE2EAD6),
    ring: Color(0xFF3F6212),
  );

  // Olive Dark Palette
  static const ThemeColorPalette oliveDark = ThemeColorPalette(
    background: Color(0xFF090D05),
    foreground: Color(0xFFECF9DB),
    card: Color(0xFF090D05),
    cardForeground: Color(0xFFECF9DB),
    popover: Color(0xFF090D05),
    popoverForeground: Color(0xFFECF9DB),
    primary: Color(0xFFBEF264),
    primaryForeground: Color(0xFF1A2E05),
    secondary: Color(0xFF1B260E),
    secondaryForeground: Color(0xFFBEF264),
    muted: Color(0xFF1B260E),
    mutedForeground: Color(0xFF819A62),
    accent: Color(0xFF1B260E),
    accentForeground: Color(0xFFBEF264),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFF223012),
    input: Color(0xFF223012),
    ring: Color(0xFFBEF264),
  );

  // Sky Light Palette
  static const ThemeColorPalette skyLight = ThemeColorPalette(
    background: Color(0xFFF7FAFC),
    foreground: Color(0xFF0F1E2D),
    card: Color(0xFFF7FAFC),
    cardForeground: Color(0xFF0F1E2D),
    popover: Color(0xFFF7FAFC),
    popoverForeground: Color(0xFF0F1E2D),
    primary: Color(0xFF0284C7),
    primaryForeground: Color(0xFFF7FAFC),
    secondary: Color(0xFFE3EFF9),
    secondaryForeground: Color(0xFF0284C7),
    muted: Color(0xFFE3EFF9),
    mutedForeground: Color(0xFF50687E),
    accent: Color(0xFFE3EFF9),
    accentForeground: Color(0xFF0284C7),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFDFEAF5),
    input: Color(0xFFDFEAF5),
    ring: Color(0xFF0284C7),
  );

  // Sky Dark Palette
  static const ThemeColorPalette skyDark = ThemeColorPalette(
    background: Color(0xFF040A12),
    foreground: Color(0xFFE0F2FE),
    card: Color(0xFF040A12),
    cardForeground: Color(0xFFE0F2FE),
    popover: Color(0xFF040A12),
    popoverForeground: Color(0xFFE0F2FE),
    primary: Color(0xFF38BDF8),
    primaryForeground: Color(0xFF031E2C),
    secondary: Color(0xFF0E1E2F),
    secondaryForeground: Color(0xFF38BDF8),
    muted: Color(0xFF0E1E2F),
    mutedForeground: Color(0xFF718EAB),
    accent: Color(0xFF0E1E2F),
    accentForeground: Color(0xFF38BDF8),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFF142B44),
    input: Color(0xFF142B44),
    ring: Color(0xFF38BDF8),
  );

  // Cyan Light Palette
  static const ThemeColorPalette cyanLight = ThemeColorPalette(
    background: Color(0xFFF5FCFD),
    foreground: Color(0xFF0D2125),
    card: Color(0xFFF5FCFD),
    cardForeground: Color(0xFF0D2125),
    popover: Color(0xFFF5FCFD),
    popoverForeground: Color(0xFF0D2125),
    primary: Color(0xFF0891B2),
    primaryForeground: Color(0xFFF5FCFD),
    secondary: Color(0xFFE1F5F8),
    secondaryForeground: Color(0xFF0891B2),
    muted: Color(0xFFE1F5F8),
    mutedForeground: Color(0xFF4C6A70),
    accent: Color(0xFFE1F5F8),
    accentForeground: Color(0xFF0891B2),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFDCF2F6),
    input: Color(0xFFDCF2F6),
    ring: Color(0xFF0891B2),
  );

  // Cyan Dark Palette
  static const ThemeColorPalette cyanDark = ThemeColorPalette(
    background: Color(0xFF020B0D),
    foreground: Color(0xFFECFEFF),
    card: Color(0xFF020B0D),
    cardForeground: Color(0xFFECFEFF),
    popover: Color(0xFF020B0D),
    popoverForeground: Color(0xFFECFEFF),
    primary: Color(0xFF22D3EE),
    primaryForeground: Color(0xFF022026),
    secondary: Color(0xFF092026),
    secondaryForeground: Color(0xFF22D3EE),
    muted: Color(0xFF092026),
    mutedForeground: Color(0xFF6B969E),
    accent: Color(0xFF092026),
    accentForeground: Color(0xFF22D3EE),
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFF0E303A),
    input: Color(0xFF0E303A),
    ring: Color(0xFF22D3EE),
  );

  // Event Categories & Colors
  static const Color work = Color(0xFF3B82F6);        // Blue
  static const Color personal = Color(0xFF10B981);    // Emerald
  static const Color health = Color(0xFFEF4444);      // Red
  static const Color education = Color(0xFFF59E0B);   // Amber
  static const Color finance = Color(0xFF8B5CF6);     // Purple
  static const Color travel = Color(0xFFEC4899);      // Pink
}

class ShadThemeExtension extends ThemeExtension<ShadThemeExtension> {
  final String preset;

  const ShadThemeExtension({required this.preset});

  @override
  ShadThemeExtension copyWith({String? preset}) {
    return ShadThemeExtension(preset: preset ?? this.preset);
  }

  @override
  ShadThemeExtension lerp(ThemeExtension<ShadThemeExtension>? other, double t) {
    if (other is! ShadThemeExtension) return this;
    return ShadThemeExtension(preset: other.preset);
  }
}

class ShadTheme {
  final bool isDark;
  final String preset;
  
  ShadTheme({required this.isDark, this.preset = 'zinc'});

  ThemeColorPalette get palette {
    if (isDark) {
      switch (preset) {
        case 'olive': return ShadColors.oliveDark;
        case 'sky': return ShadColors.skyDark;
        case 'cyan': return ShadColors.cyanDark;
        default: return ShadColors.zincDark;
      }
    } else {
      switch (preset) {
        case 'olive': return ShadColors.oliveLight;
        case 'sky': return ShadColors.skyLight;
        case 'cyan': return ShadColors.cyanLight;
        default: return ShadColors.zincLight;
      }
    }
  }

  Color get background => palette.background;
  Color get foreground => palette.foreground;
  Color get card => palette.card;
  Color get cardForeground => palette.cardForeground;
  Color get popover => palette.popover;
  Color get popoverForeground => palette.popoverForeground;
  Color get primary => palette.primary;
  Color get primaryForeground => palette.primaryForeground;
  Color get secondary => palette.secondary;
  Color get secondaryForeground => palette.secondaryForeground;
  Color get muted => palette.muted;
  Color get mutedForeground => palette.mutedForeground;
  Color get accent => palette.accent;
  Color get accentForeground => palette.accentForeground;
  Color get destructive => palette.destructive;
  Color get destructiveForeground => palette.destructiveForeground;
  Color get border => palette.border;
  Color get input => palette.input;
  Color get ring => palette.ring;

  static ShadTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final ext = theme.extension<ShadThemeExtension>();
    final preset = ext?.preset ?? 'zinc';
    return ShadTheme(isDark: brightness == Brightness.dark, preset: preset);
  }

  ThemeData get themeData {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: border,
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      dialogBackgroundColor: popover,
      dialogTheme: DialogThemeData(
        backgroundColor: popover,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actionsPadding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
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
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      extensions: [
        ShadThemeExtension(preset: preset),
      ],
    );
  }
}
