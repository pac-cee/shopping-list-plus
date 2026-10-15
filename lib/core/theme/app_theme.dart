import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF006B5B);
  static const ink = Color(0xFF17211F);
  static const muted = Color(0xFF64706D);
  static const canvas = Color(0xFFF3F7F5);
  static const border = Color(0xFFDCE5E1);
  static const danger = Color(0xFFB42318);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: Colors.white,
      error: danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          height: 1.08,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: muted),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCEFEA),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? primary : muted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}
