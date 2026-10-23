import 'package:flutter/material.dart';

abstract final class Palette {
  static const purple = Color(0xFF6A56F6),
      muted = Color(0xFF9592AE),
      red = Color(0xFFFC5962),
      ink = Color(0xFF232132);
}

ThemeData beatrixTheme(bool dark) {
  final surface = dark ? const Color(0xFF151522) : Colors.white;
  final soft = dark ? const Color(0xFF252536) : const Color(0xFFF4F4F6);
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.purple,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: Palette.purple,
    surface: surface,
    onSurface: dark ? Colors.white : Palette.ink,
    surfaceContainerHighest: soft,
    outlineVariant: dark ? const Color(0xFF303042) : const Color(0xFFF0F0F3),
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Jakarta',
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Jakarta',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: scheme.onSurface,
      ),
    ),
    dividerColor: scheme.outlineVariant,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 13, height: 1.65),
      bodySmall: TextStyle(fontSize: 11, color: Palette.muted, height: 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        textStyle: const TextStyle(
          fontFamily: 'Jakarta',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        side: BorderSide(color: scheme.outlineVariant),
        foregroundColor: scheme.onSurface,
        textStyle: const TextStyle(
          fontFamily: 'Jakarta',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: soft,
      hintStyle: const TextStyle(color: Palette.muted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Palette.purple),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? soft : Palette.ink,
    ),
  );
}
