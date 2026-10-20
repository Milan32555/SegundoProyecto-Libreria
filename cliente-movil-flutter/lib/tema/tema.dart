import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

export 'tokens.dart';

/// Esquema de color de Material 3 escrito a mano desde los tokens (no generado con fromSeed):
/// así la app usa exactamente los mismos colores que el cliente web.
const ColorScheme esquemaLibreria = ColorScheme(
  brightness: Brightness.light,
  primary: kMarca600,
  onPrimary: kGris0,
  primaryContainer: kMarca50,
  onPrimaryContainer: kMarca600,
  secondary: kGris600,
  onSecondary: kGris0,
  secondaryContainer: kGris100,
  onSecondaryContainer: kGris900,
  tertiary: kInfoPunto,
  onTertiary: kGris0,
  error: kPeligro600,
  onError: kGris0,
  errorContainer: kPeligroFondo,
  onErrorContainer: kPeligroTexto,
  surface: kGris0,
  onSurface: kGris900,
  onSurfaceVariant: kGris600,
  surfaceContainerLowest: kGris0,
  surfaceContainerLow: kGris25,
  surfaceContainer: kGris50,
  surfaceContainerHigh: kGris50,
  surfaceContainerHighest: kGris100,
  outline: kGris400,
  outlineVariant: kGris100,
  inverseSurface: kGris900,
  onInverseSurface: kGris25,
  inversePrimary: kMarca100,
  surfaceTint: Colors.transparent,
);

/// Escala tipográfica (IBM Plex Sans), la misma del cliente web: 12 · 13 · 14 · 16 · 20 · 24 · 30.
const TextTheme textosLibreria = TextTheme(
  displaySmall: TextStyle(fontSize: 30, height: 38 / 30, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: kGris900),
  headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: kGris900),
  titleLarge: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: kGris900),
  titleMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, color: kGris900),
  titleSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: kGris900),
  bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, color: kGris900),
  bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, color: kGris900),
  bodySmall: TextStyle(fontSize: 12, height: 16 / 12, color: kGris600),
  labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: kGris900),
  labelMedium: TextStyle(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, color: kGris800),
  labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: kGris600),
);

ThemeData construirTema() {
  OutlineInputBorder borde(Color color, [double ancho = 1]) =>
      OutlineInputBorder(borderRadius: Radios.control, borderSide: BorderSide(color: color, width: ancho));

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquemaLibreria,
    fontFamily: fuenteUi,
    textTheme: textosLibreria,
    scaffoldBackgroundColor: kGris25,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: kGris25,
      foregroundColor: kGris900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: fuenteUi, fontSize: 16, fontWeight: FontWeight.w600, color: kGris900),
      shape: Border(bottom: BorderSide(color: kGris100)),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    iconTheme: const IconThemeData(color: kGris600, size: 20),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kGris0,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: Espacio.e3, vertical: 14),
      border: borde(kGris400),
      enabledBorder: borde(kGris400),
      focusedBorder: borde(kMarca600, 2),
      errorBorder: borde(kPeligro600),
      focusedErrorBorder: borde(kPeligro600, 2),
      disabledBorder: borde(kGris100),
      labelStyle: const TextStyle(color: kGris600, fontSize: 14),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (estados) => TextStyle(
          color: estados.contains(WidgetState.error)
              ? kPeligro600
              : estados.contains(WidgetState.focused)
              ? kMarca600
              : kGris600,
          fontWeight: FontWeight.w500,
        ),
      ),
      hintStyle: const TextStyle(color: kGris500, fontSize: 14),
      helperStyle: const TextStyle(color: kGris500, fontSize: 12, height: 16 / 12),
      errorStyle: const TextStyle(color: kPeligro600, fontSize: 12, height: 16 / 12),
      helperMaxLines: 2,
      errorMaxLines: 2,
      prefixIconColor: kGris500,
      suffixIconColor: kGris500,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kMarca600,
        foregroundColor: kGris0,
        disabledBackgroundColor: kGris100,
        disabledForegroundColor: kGris500,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: Espacio.e4),
        shape: const RoundedRectangleBorder(borderRadius: Radios.control),
        textStyle: const TextStyle(fontFamily: fuenteUi, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kGris900,
        backgroundColor: kGris0,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: Espacio.e4),
        side: const BorderSide(color: kGris200),
        shape: const RoundedRectangleBorder(borderRadius: Radios.control),
        textStyle: const TextStyle(fontFamily: fuenteUi, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kMarca600,
        shape: const RoundedRectangleBorder(borderRadius: Radios.control),
        textStyle: const TextStyle(fontFamily: fuenteUi, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kMarca600,
      foregroundColor: kGris0,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: Radios.dialogo),
    ),
    cardTheme: const CardThemeData(
      color: kGris0,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: Radios.panel, side: BorderSide(color: kGris100)),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: kGris0,
      selectedColor: kMarca50,
      disabledColor: kGris50,
      side: BorderSide(color: kGris200),
      shape: RoundedRectangleBorder(borderRadius: Radios.control),
      labelStyle: TextStyle(fontFamily: fuenteUi, fontSize: 14, fontWeight: FontWeight.w500, color: kGris800),
      secondaryLabelStyle: TextStyle(fontFamily: fuenteUi, fontSize: 14, fontWeight: FontWeight.w600, color: kMarca600),
      padding: EdgeInsets.symmetric(horizontal: Espacio.e2, vertical: Espacio.e1),
      showCheckmark: false,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected) ? kMarca50 : kGris0),
        foregroundColor: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected) ? kMarca600 : kGris600),
        side: const WidgetStatePropertyAll(BorderSide(color: kGris200)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radios.control)),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: fuenteUi, fontWeight: FontWeight.w600, fontSize: 14)),
        minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: kGris50,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kMarca50,
      indicatorShape: const RoundedRectangleBorder(borderRadius: Radios.control),
      tileHeight: 44,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (e) => TextStyle(
          fontFamily: fuenteUi,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: e.contains(WidgetState.selected) ? kMarca600 : kGris800,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (e) => IconThemeData(size: 18, color: e.contains(WidgetState.selected) ? kMarca600 : kGris500),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: kGris50,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(12))),
    ),
    dividerTheme: const DividerThemeData(color: kGris100, thickness: 1, space: 1),
    listTileTheme: const ListTileThemeData(
      textColor: kGris900,
      iconColor: kGris500,
      contentPadding: EdgeInsets.symmetric(horizontal: Espacio.e4),
      titleTextStyle: TextStyle(fontFamily: fuenteUi, fontSize: 15, fontWeight: FontWeight.w500, color: kGris900),
      subtitleTextStyle: TextStyle(fontFamily: fuenteUi, fontSize: 13, color: kGris600),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kGris900,
      contentTextStyle: TextStyle(fontFamily: fuenteUi, color: kGris25, fontSize: 14, height: 20 / 14),
      actionTextColor: kMarca100,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Radios.panel),
      showCloseIcon: true,
      closeIconColor: kGris200,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kGris0,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: kGris200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: kGris0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: Radios.dialogo),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: kGris0,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: kMarca600,
      headerForegroundColor: kGris0,
      shape: RoundedRectangleBorder(borderRadius: Radios.dialogo),
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: kGris0,
      shape: RoundedRectangleBorder(borderRadius: Radios.dialogo),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(kGris0),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radios.panel)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kMarca600, linearTrackColor: kGris100),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: const WidgetStatePropertyAll(kGris0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith(
        (e) => BorderSide(color: e.contains(WidgetState.focused) ? kMarca600 : kGris400, width: e.contains(WidgetState.focused) ? 2 : 1),
      ),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radios.panel)),
      constraints: const BoxConstraints(minHeight: 48),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Espacio.e3)),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: fuenteUi, fontSize: 15, color: kGris900)),
      hintStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: fuenteUi, fontSize: 15, color: kGris500)),
    ),
  );
}
