import 'package:flutter/material.dart';

abstract final class AppColors {
  static const emerald = Color(0xFF176B52);
  static const emeraldDark = Color(0xFF6EC5A3);
  static const ivory = Color(0xFFF7F4EC);
  static const charcoal = Color(0xFF111815);
  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF1A2420);
  static const lightText = Color(0xFF17211D);
  static const darkText = Color(0xFFF4F1E8);
  static const lightMuted = Color(0xFF68746E);
  static const darkMuted = Color(0xFFAAB6B0);
  static const lightBorder = Color(0xFFE2DED2);
  static const darkBorder = Color(0xFF314039);
  static const gold = Color(0xFFC89B3C);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.emeraldDark : AppColors.emerald,
      onPrimary: isDark ? AppColors.charcoal : Colors.white,
      secondary: isDark ? const Color(0xFFD8B766) : AppColors.gold,
      onSecondary: AppColors.charcoal,
      error: isDark ? const Color(0xFFE18484) : const Color(0xFF9B3F3F),
      onError: Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkText : AppColors.lightText,
    );
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.charcoal : AppColors.ivory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.charcoal : AppColors.ivory,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
            fontWeight: FontWeight.w700,
          );
        }),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    );
  }
}
