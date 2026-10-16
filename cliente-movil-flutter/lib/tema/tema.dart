import 'package:flutter/material.dart';

// ── Paleta ───────────────────────────────────────────────────────────────────
// Oscuro cálido con acento amarillo (misma línea visual que Base Gym).
const kFondo = Color(0xFF14120E);
const kSuperficie = Color(0xFF1C1A15);
const kSuperficie2 = Color(0xFF242019);
const kSuperficie3 = Color(0xFF2C271E);
const kAcento = Color(0xFFFFCC00);
const kTexto = Color(0xFFF5F1E8);
const kTexto2 = Color(0xFFB8B2A8);
const kTexto3 = Color(0xFF8A8375);
const kBorde = Color(0x12FFFFFF);
const kBorde2 = Color(0x1FFFFFFF);
const kRojo = Color(0xFFFF5C5C);
const kVerde = Color(0xFF3CC47A);
const kAzul = Color(0xFF5AA8FF);
const kNaranja = Color(0xFFFFA45C);

// ── Medidas ──────────────────────────────────────────────────────────────────
class Espacio {
  Espacio._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class Redondeo {
  Redondeo._();
  static const campo = BorderRadius.all(Radius.circular(12));
  static const tarjeta = BorderRadius.all(Radius.circular(16));
  static const hero = BorderRadius.all(Radius.circular(20));
}

/// Etiqueta pequeña en mayúsculas que encabeza secciones y datos (LIBRO, ISBN…).
const estiloEtiqueta = TextStyle(color: kTexto3, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2);

ThemeData construirTema() {
  OutlineInputBorder bordeCampo(Color color, [double ancho = 1]) => OutlineInputBorder(
    borderRadius: Redondeo.campo,
    borderSide: BorderSide(color: color, width: ancho),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kFondo,
    colorScheme: const ColorScheme.dark(
      primary: kAcento,
      onPrimary: kFondo,
      secondary: kAcento,
      onSecondary: kFondo,
      surface: kSuperficie,
      onSurface: kTexto,
      surfaceContainerHighest: kSuperficie3,
      error: kRojo,
      onError: Colors.white,
      outline: kBorde2,
      outlineVariant: kBorde,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kFondo,
      foregroundColor: kTexto,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: kTexto, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(color: kTexto, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
      headlineSmall: TextStyle(color: kTexto, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
      titleLarge: TextStyle(color: kTexto, fontSize: 17, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: kTexto, fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: kTexto, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: kTexto2, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: kTexto3, fontSize: 12, height: 1.3),
    ),
    iconTheme: const IconThemeData(color: kTexto2),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSuperficie2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: bordeCampo(kBorde2),
      enabledBorder: bordeCampo(kBorde2),
      focusedBorder: bordeCampo(kAcento, 1.5),
      errorBorder: bordeCampo(kRojo, 1.5),
      focusedErrorBorder: bordeCampo(kRojo, 1.5),
      labelStyle: const TextStyle(color: kTexto3, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: kAcento, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: kTexto3, fontSize: 14),
      prefixIconColor: kTexto3,
      suffixIconColor: kTexto2,
      errorStyle: const TextStyle(color: kRojo, fontSize: 12, height: 1.3),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kAcento,
        foregroundColor: kFondo,
        disabledBackgroundColor: kSuperficie3,
        disabledForegroundColor: kTexto3,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: Redondeo.campo),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kTexto,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: kBorde2),
        shape: const RoundedRectangleBorder(borderRadius: Redondeo.campo),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kAcento)),
    cardTheme: const CardThemeData(
      color: kSuperficie,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Redondeo.tarjeta,
        side: BorderSide(color: kBorde),
      ),
    ),
    dividerTheme: const DividerThemeData(color: kBorde, thickness: 1, space: 1),
    drawerTheme: const DrawerThemeData(
      backgroundColor: kSuperficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
    ),
    listTileTheme: const ListTileThemeData(textColor: kTexto, iconColor: kTexto2),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kSuperficie3,
      contentTextStyle: TextStyle(color: kTexto, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.campo),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(kSuperficie2),
      headingTextStyle: TextStyle(color: kTexto3, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
      dataTextStyle: TextStyle(color: kTexto, fontSize: 14),
      headingRowHeight: 44,
      dataRowMinHeight: 58,
      dataRowMaxHeight: 68,
      horizontalMargin: 16,
      columnSpacing: 28,
      dividerThickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kAcento, linearTrackColor: kSuperficie2),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected) ? kAcento : kSuperficie2,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected) ? kFondo : kTexto2,
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: kBorde2)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Redondeo.campo)),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700)),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: kSuperficie,
      headerBackgroundColor: kSuperficie2,
      headerForegroundColor: kTexto,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.hero),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: kSuperficie,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.hero),
    ),
  );
}
