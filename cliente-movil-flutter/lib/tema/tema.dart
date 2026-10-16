import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Identidad visual: "papel y tinta" ─────────────────────────────────────────
// Fondo crema como las páginas de un libro, texto color tinta, verde de las
// lámparas de biblioteca como color principal y dorado (como el de los lomos)
// para precios y detalles.
const kPapel = Color(0xFFF6F1E6);
const kHoja = Color(0xFFFFFDF8);
const kPergamino = Color(0xFFEFE7D6);
const kPergaminoOscuro = Color(0xFFE4D9C3);
const kTinta = Color(0xFF1E2430);
const kTinta2 = Color(0xFF515867);
const kTinta3 = Color(0xFF6E7280);
const kBorde = Color(0xFFE6DCC8);
const kBorde2 = Color(0xFFD5C9B0);

const kPrimario = Color(0xFF1F5C4A); // verde biblioteca
const kPrimarioOscuro = Color(0xFF133B30);
const kDorado = Color(0xFFA8741F);
const kCrema = Color(0xFFF6EBD3); // texto sobre el verde

// Estados (tonos que se leen sobre papel).
const kVerde = Color(0xFF2E7D4F);
const kAzul = Color(0xFF2F5DA8);
const kNaranja = Color(0xFFB45F12);
const kRojo = Color(0xFFB3261E);

/// Tipografía serif para títulos (incluida en assets/fuentes, licencia OFL).
const fuenteTitulos = 'Lora';

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

/// Sombra cálida y suave para las tarjetas destacadas.
const sombraSuave = [BoxShadow(color: Color(0x1A5B4A2E), blurRadius: 18, offset: Offset(0, 6))];

/// Etiqueta pequeña en mayúsculas que encabeza secciones y datos (LIBRO, ISBN…).
const estiloEtiqueta = TextStyle(color: kTinta3, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2);

ThemeData construirTema() {
  OutlineInputBorder bordeCampo(Color color, [double ancho = 1]) => OutlineInputBorder(
    borderRadius: Redondeo.campo,
    borderSide: BorderSide(color: color, width: ancho),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kPapel,
    colorScheme: const ColorScheme.light(
      primary: kPrimario,
      onPrimary: Colors.white,
      secondary: kDorado,
      onSecondary: Colors.white,
      surface: kHoja,
      onSurface: kTinta,
      surfaceContainerHighest: kPergamino,
      error: kRojo,
      onError: Colors.white,
      outline: kBorde2,
      outlineVariant: kBorde,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kPapel,
      foregroundColor: kTinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      // También define la barra de navegación del sistema: transparente, con íconos oscuros sobre el papel.
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      titleTextStyle: TextStyle(fontFamily: fuenteTitulos, color: kTinta, fontSize: 22, fontWeight: FontWeight.w700),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: fuenteTitulos,
        color: kTinta,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(fontFamily: fuenteTitulos, color: kTinta, fontSize: 25, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: kTinta, fontSize: 17, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: kTinta, fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: kTinta, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: kTinta2, fontSize: 14, height: 1.45),
      bodySmall: TextStyle(color: kTinta3, fontSize: 12, height: 1.3),
    ),
    iconTheme: const IconThemeData(color: kTinta2),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kHoja,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: bordeCampo(kBorde2),
      enabledBorder: bordeCampo(kBorde2),
      focusedBorder: bordeCampo(kPrimario, 1.6),
      errorBorder: bordeCampo(kRojo, 1.4),
      focusedErrorBorder: bordeCampo(kRojo, 1.6),
      labelStyle: const TextStyle(color: kTinta3, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: kPrimario, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(color: kTinta3, fontSize: 14),
      prefixIconColor: kTinta3,
      suffixIconColor: kTinta2,
      errorStyle: const TextStyle(color: kRojo, fontSize: 12, height: 1.3),
      errorMaxLines: 3,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimario,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kPergaminoOscuro,
        disabledForegroundColor: kTinta3,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: Redondeo.campo),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kTinta,
        backgroundColor: kHoja,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: kBorde2),
        shape: const RoundedRectangleBorder(borderRadius: Redondeo.campo),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kPrimario)),
    cardTheme: const CardThemeData(
      color: kHoja,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Redondeo.tarjeta,
        side: BorderSide(color: kBorde),
      ),
    ),
    dividerTheme: const DividerThemeData(color: kBorde, thickness: 1, space: 1),
    drawerTheme: const DrawerThemeData(
      backgroundColor: kPapel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
    ),
    listTileTheme: const ListTileThemeData(textColor: kTinta, iconColor: kTinta2),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kTinta,
      contentTextStyle: TextStyle(color: kPapel, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.campo),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(kPergamino),
      headingTextStyle: TextStyle(color: kTinta3, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
      dataTextStyle: TextStyle(color: kTinta, fontSize: 14),
      headingRowHeight: 44,
      dataRowMinHeight: 58,
      dataRowMaxHeight: 68,
      horizontalMargin: 16,
      columnSpacing: 28,
      dividerThickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPrimario, linearTrackColor: kPergamino),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected) ? kPrimario : kHoja,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.selected) ? Colors.white : kTinta2,
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: kBorde2)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Redondeo.campo)),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700)),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: kHoja,
      headerBackgroundColor: kPrimario,
      headerForegroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.hero),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: kHoja,
      shape: RoundedRectangleBorder(borderRadius: Redondeo.hero),
    ),
  );
}
