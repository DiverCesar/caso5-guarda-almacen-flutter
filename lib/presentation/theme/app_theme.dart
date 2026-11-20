import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores solicitada
  static const Color fondo = Color(0xFFF6F7F9); // Gris humo muy claro
  static const Color superficie = Color(0xFFFFFFFF); // Blanco puro
  static const Color borde = Color(0xFFE2E8F0); // Borde sutil 1px
  static const Color primario = Color(0xFF0F172A); // Azul pizarra oscuro
  static const Color acento = Color(0xFF2563EB); // Azul acero
  static const Color textoSecundario = Color(0xFF64748B); // Slate suave
  static const Color textoPrincipal = Color(0xFF0F172A);

  // Estados semánticos
  static const Color badgeDisponibleBg = Color(0xFFECFDF5);
  static const Color badgeDisponibleText = Color(0xFF065F46);
  static const Color badgeDisponibleBorder = Color(0xFFA7F3D0);

  static const Color badgeEntregadoBg = Color(0xFFEFF6FF);
  static const Color badgeEntregadoText = Color(0xFF1E40AF);
  static const Color badgeEntregadoBorder = Color(0xFFBFDBFE);

  static const Color badgeMantenimientoBg = Color(0xFFFFFBEB);
  static const Color badgeMantenimientoText = Color(0xFF92400E);
  static const Color badgeMantenimientoBorder = Color(0xFFFDE68A);

  static const Color badgeBajaBg = Color(0xFFFEF2F2);
  static const Color badgeBajaText = Color(0xFF991B1B);
  static const Color badgeBajaBorder = Color(0xFFFECACA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: fondo,
      colorScheme: const ColorScheme.light(
        primary: primario,
        secondary: acento,
        surface: superficie,
        error: Color(0xFFDC2626),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textoPrincipal,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: superficie,
        foregroundColor: primario,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primario,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        shape: Border(
          bottom: BorderSide(color: borde, width: 1),
        ),
      ),
      cardTheme: const CardThemeData(
        color: superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: borde, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borde, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: acento, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        labelStyle: const TextStyle(color: textoSecundario, fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primario,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primario,
          side: const BorderSide(color: borde, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primario,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
