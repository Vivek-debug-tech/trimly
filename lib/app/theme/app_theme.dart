import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color deepTeal = Color(0xFF006064);
  static const Color brushedSteel = Color(0xFF90A4AE);
  static const Color amberGold = Color(0xFFFFB300);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepTeal,
          brightness: Brightness.light,
          primary: deepTeal,
          secondary: amberGold,
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFE9F0F1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: deepTeal,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: deepTeal,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: deepTeal,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: deepTeal,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF1C2A2D),
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF42575B),
            height: 1.45,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFCFCFC),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: deepTeal.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        dividerColor: const Color(0xFFE4ECEE),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEAF2F3),
          selectedColor: deepTeal,
          secondarySelectedColor: amberGold,
          labelStyle: const TextStyle(color: deepTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide.none,
        ),
      );
}
