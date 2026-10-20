import 'package:flutter/material.dart';

// Sistema de diseño de Librería: tokens.
//
// Son los mismos valores del cliente web (cliente-web-react/src/estilos/tokens.css): si se
// cambia uno aquí, se cambia también allá. El contraste AA de cada par texto/fondo se comprueba
// con scripts/verificar-contraste.py.
//
// Reglas de uso:
//  - Neutros para casi todo; la marca solo en acciones primarias, selección y foco.
//  - Los estados de un ejemplar se distinguen por la forma (insignia con punto + texto) y no
//    solo por el color.
//  - Espaciado en múltiplos de 4; radios pequeños; bordes de 1 px en lugar de sombras.

// ── Neutros (escala cálida) ─────────────────────────────────────────────────
const kGris0 = Color(0xFFFFFFFF); // superficie: paneles, tablas, campos
const kGris25 = Color(0xFFFAFAF9); // fondo de la pantalla
const kGris50 = Color(0xFFF5F5F4); // fondo sutil: menú, encabezado de tabla
const kGris100 = Color(0xFFE7E5E4); // bordes de paneles y divisores
const kGris200 = Color(0xFFD6D3D1); // bordes de botones secundarios
const kGris400 = Color(0xFF8F8882); // borde de campos (3,5:1)
const kGris500 = Color(0xFF78716C); // texto terciario (4,8:1)
const kGris600 = Color(0xFF57534E); // texto secundario (7,6:1)
const kGris800 = Color(0xFF292524);
const kGris900 = Color(0xFF1C1917); // texto principal (17,5:1)

// ── Marca: verde bosque ─────────────────────────────────────────────────────
const kMarca50 = Color(0xFFEDF5F1);
const kMarca100 = Color(0xFFD3E7DD);
const kMarca600 = Color(0xFF1F5C4A); // botón primario, selección, foco (7,8:1)
const kMarca700 = Color(0xFF174A3B);

// ── Semánticos (fondo · punto · texto) ──────────────────────────────────────
const kExitoFondo = Color(0xFFE8F5EC), kExitoPunto = Color(0xFF1A7F37), kExitoTexto = Color(0xFF116329); // Disponible
const kInfoFondo = Color(0xFFE9F1FB), kInfoPunto = Color(0xFF2F6FBF), kInfoTexto = Color(0xFF1D4E89); // Prestado
const kAvisoFondo = Color(0xFFFDF1DC), kAvisoPunto = Color(0xFFB86E00), kAvisoTexto = Color(0xFF7A4300); // Dañado
const kNeutroFondo = Color(0xFFEFEDEB), kNeutroPunto = Color(0xFF78716C), kNeutroTexto = Color(0xFF4A4541); // Dado de baja
const kPeligroFondo = Color(0xFFFDEDEC);
const kPeligroBorde = Color(0xFFF3C4C0);
const kPeligroTexto = Color(0xFF9B1C1C);
const kPeligro600 = Color(0xFFB42318);

// ── Tipografía ──────────────────────────────────────────────────────────────
const fuenteUi = 'IBMPlexSans'; // toda la interfaz
const fuenteLibro = 'Literata'; // títulos de libros y logotipo

/// Cifras tabulares: los números de tablas y totales quedan alineados.
const cifrasTabulares = [FontFeature.tabularFigures()];

// ── Espaciado (múltiplos de 4) ──────────────────────────────────────────────
class Espacio {
  Espacio._();
  static const double e1 = 4;
  static const double e2 = 8;
  static const double e3 = 12;
  static const double e4 = 16;
  static const double e6 = 24;
  static const double e8 = 32;
  static const double e12 = 48;
}

// ── Radios ──────────────────────────────────────────────────────────────────
class Radios {
  Radios._();
  static const control = BorderRadius.all(Radius.circular(6)); // botones, campos
  static const panel = BorderRadius.all(Radius.circular(8)); // paneles, tablas, menús
  static const dialogo = BorderRadius.all(Radius.circular(12)); // diálogos y hojas inferiores
}

// ── Elevación (solo dos niveles) ────────────────────────────────────────────
const elevacion1 = [BoxShadow(color: Color(0x0F1C1917), blurRadius: 2, offset: Offset(0, 1))];
const elevacion2 = [BoxShadow(color: Color(0x291C1917), blurRadius: 32, offset: Offset(0, 12))];
