import 'package:flutter/material.dart';

import '../../tema/tema.dart';

/// Color que identifica cada estado de un ejemplar.
Color colorEstado(String estado) => switch (estado) {
  'DISPONIBLE' => kVerde,
  'PRESTADO' => kAzul,
  'DANIADO' => kNaranja,
  'DADO_DE_BAJA' => kRojo,
  _ => kTexto2,
};

/// Etiqueta pequeña en mayúsculas que encabeza una sección.
class EtiquetaSeccion extends StatelessWidget {
  const EtiquetaSeccion(this.texto, {super.key, this.color = kTexto3});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(texto.toUpperCase(), style: estiloEtiqueta.copyWith(color: color));
}

/// Encabezado de cada pantalla: etiqueta, título grande y una línea de ayuda.
class EncabezadoPantalla extends StatelessWidget {
  const EncabezadoPantalla({super.key, required this.etiqueta, required this.titulo, this.descripcion});

  final String etiqueta;
  final String titulo;
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacio.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EtiquetaSeccion(etiqueta, color: kAcento),
          const SizedBox(height: Espacio.xs),
          Text(titulo, style: texto.headlineSmall),
          if (descripcion != null) ...[const SizedBox(height: Espacio.xs), Text(descripcion!, style: texto.bodyMedium)],
        ],
      ),
    );
  }
}

/// Tarjeta principal de una pantalla: superficie con degradado suave y radio 20.
class TarjetaHero extends StatelessWidget {
  const TarjetaHero({super.key, required this.child, this.colorBorde = kBorde2});

  final Widget child;
  final Color colorBorde;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: Redondeo.hero,
        border: Border.all(color: colorBorde),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kSuperficie3, kSuperficie],
        ),
      ),
      child: child,
    );
  }
}

/// Ícono dentro de un cuadro redondeado con el color de acento tenue.
class IconoAcento extends StatelessWidget {
  const IconoAcento(this.icono, {super.key, this.color = kAcento, this.tamano = 44});

  final IconData icono;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tamano * 0.3),
      ),
      child: Icon(icono, color: color, size: tamano * 0.5),
    );
  }
}

/// Pastilla de color para estados y categorías (Disponible, Ficción…).
class Pastilla extends StatelessWidget {
  const Pastilla(this.texto, {super.key, this.color = kAcento});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum TipoAviso { error, exito, advertencia }

/// Mensaje destacado dentro de la pantalla (errores del servidor, advertencias…).
class Aviso extends StatelessWidget {
  const Aviso(this.mensaje, {super.key, this.tipo = TipoAviso.error});

  final String mensaje;
  final TipoAviso tipo;

  @override
  Widget build(BuildContext context) {
    final (color, icono) = switch (tipo) {
      TipoAviso.error => (kRojo, Icons.error_outline_rounded),
      TipoAviso.exito => (kVerde, Icons.check_circle_outline_rounded),
      TipoAviso.advertencia => (kNaranja, Icons.warning_amber_rounded),
    };
    return Container(
      margin: const EdgeInsets.only(top: Espacio.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: Redondeo.campo,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(mensaje, style: TextStyle(color: color, fontSize: 14, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

/// Pantalla vacía o sin resultados.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.mensaje});

  final IconData icono;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacio.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoAcento(icono, color: kTexto3, tamano: 64),
          const SizedBox(height: Espacio.md),
          Text(mensaje, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Campo de búsqueda por clave (ISBN o código) + botón "Buscar".
/// Lo usan los casos de uso que exigen buscar el objeto antes de actuar.
class BuscadorClave extends StatelessWidget {
  const BuscadorClave({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    required this.onBuscar,
    required this.cargando,
  });

  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final VoidCallback onBuscar;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(labelText: etiqueta, prefixIcon: Icon(icono)),
          onSubmitted: (_) => onBuscar(),
        ),
        const SizedBox(height: Espacio.md),
        FilledButton.icon(
          onPressed: cargando ? null : onBuscar,
          icon: cargando
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.4, color: kTexto3))
              : const Icon(Icons.search_rounded),
          label: const Text('Buscar'),
        ),
      ],
    );
  }
}

/// Fila de chips de selección única (género, estado). Con [textoTodos] agrega
/// la opción "todos" (valor null), útil para filtros.
class SelectorChips extends StatelessWidget {
  const SelectorChips({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.etiquetaDe,
    required this.alSeleccionar,
    this.textoTodos,
    this.desplazable = false,
  });

  final List<String> opciones;
  final String? seleccionado;
  final String Function(String) etiquetaDe;
  final ValueChanged<String?> alSeleccionar;
  final String? textoTodos;
  final bool desplazable;

  Widget _chip(String texto, bool activo, VoidCallback alTocar) {
    return ChoiceChip(
      label: Text(texto),
      selected: activo,
      showCheckmark: false,
      onSelected: (_) => alTocar(),
      backgroundColor: kSuperficie2,
      selectedColor: kAcento,
      side: BorderSide(color: activo ? kAcento : kBorde2),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: activo ? kFondo : kTexto2, fontWeight: activo ? FontWeight.w800 : FontWeight.w600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      if (textoTodos != null) _chip(textoTodos!, seleccionado == null, () => alSeleccionar(null)),
      for (final opcion in opciones) _chip(etiquetaDe(opcion), seleccionado == opcion, () => alSeleccionar(opcion)),
    ];
    if (!desplazable) {
      return Wrap(spacing: Espacio.sm, runSpacing: Espacio.sm, children: chips);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: Espacio.sm),
              child: chip,
            ),
        ],
      ),
    );
  }
}

/// Muestra que la lista se actualiza sola (patrón Observer).
class IndicadorEnVivo extends StatelessWidget {
  const IndicadorEnVivo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: kVerde,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: kVerde.withValues(alpha: 0.6), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'En vivo',
          style: TextStyle(color: kVerde, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Celda de tabla con un dato principal y uno secundario debajo.
class CeldaDoble extends StatelessWidget {
  const CeldaDoble({super.key, required this.principal, required this.secundario});

  final String principal;
  final String secundario;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          principal,
          style: const TextStyle(color: kTexto, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(secundario, style: const TextStyle(color: kTexto3, fontSize: 12)),
      ],
    );
  }
}

/// Pista para el usuario: la grilla tiene más columnas a la derecha.
class PistaDesplazamiento extends StatelessWidget {
  const PistaDesplazamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.swipe_left_rounded, size: 16, color: kTexto3),
        SizedBox(width: 6),
        Text('Desliza la tabla para ver todas las columnas', style: TextStyle(color: kTexto3, fontSize: 12)),
      ],
    );
  }
}
