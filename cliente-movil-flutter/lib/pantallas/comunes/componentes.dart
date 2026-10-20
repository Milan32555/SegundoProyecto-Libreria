import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../modelos/libro.dart';
import '../../tema/tema.dart';

/// Colores de cada estado de un ejemplar: (fondo, punto, texto).
(Color, Color, Color) coloresEstado(String estado) => switch (estado) {
  'DISPONIBLE' => (kExitoFondo, kExitoPunto, kExitoTexto),
  'PRESTADO' => (kInfoFondo, kInfoPunto, kInfoTexto),
  'DANIADO' => (kAvisoFondo, kAvisoPunto, kAvisoTexto),
  _ => (kNeutroFondo, kNeutroPunto, kNeutroTexto),
};

/// Encabezado de cada pantalla: sección (Libros / Ejemplares), título y una línea de ayuda.
class EncabezadoPantalla extends StatelessWidget {
  const EncabezadoPantalla({super.key, this.seccion, required this.titulo, this.descripcion});

  final String? seccion;
  final String titulo;
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacio.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (seccion != null)
            Text(seccion!, style: textos.labelMedium!.copyWith(color: kGris500)),
          Semantics(header: true, child: Text(titulo, style: textos.headlineSmall)),
          if (descripcion != null) ...[
            const SizedBox(height: Espacio.e1),
            Text(descripcion!, style: textos.bodyMedium!.copyWith(color: kGris600)),
          ],
        ],
      ),
    );
  }
}

/// Superficie blanca con borde fino: agrupa contenido (fichas, formularios, tablas).
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(Espacio.e4)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kGris0,
        borderRadius: Radios.panel,
        border: Border.all(color: kGris100),
      ),
      child: child,
    );
  }
}

/// Estado de un ejemplar: punto + texto, así no depende solo del color.
class InsigniaEstado extends StatelessWidget {
  const InsigniaEstado(this.estado, {super.key, this.texto});

  final String estado;
  final String? texto;

  @override
  Widget build(BuildContext context) {
    final (fondo, punto, color) = coloresEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espacio.e2, vertical: 2),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: punto, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            texto ?? etiquetaEstado(estado),
            style: TextStyle(color: color, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Género de un libro: categoría neutra, sin punto y con borde.
class InsigniaGenero extends StatelessWidget {
  const InsigniaGenero(this.genero, {super.key});

  final String genero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espacio.e2, vertical: 2),
      decoration: BoxDecoration(
        color: kGris25,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kGris100),
      ),
      child: Text(
        etiquetaGenero(genero),
        style: const TextStyle(color: kGris600, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

enum TonoAviso { critico, exito, info }

/// Mensaje dentro de la pantalla: errores del servidor (que no deben perderse) o resultados.
class Aviso extends StatelessWidget {
  const Aviso(this.mensaje, {super.key, this.titulo, this.tono = TonoAviso.critico, this.accion});

  final String mensaje;
  final String? titulo;
  final TonoAviso tono;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde, color, icono) = switch (tono) {
      TonoAviso.critico => (kPeligroFondo, kPeligroBorde, kPeligroTexto, LucideIcons.circleAlert),
      TonoAviso.exito => (kExitoFondo, kExitoFondo, kExitoTexto, LucideIcons.circleCheck),
      TonoAviso.info => (kInfoFondo, kInfoFondo, kInfoTexto, LucideIcons.info),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: Espacio.e4),
        padding: const EdgeInsets.all(Espacio.e3),
        decoration: BoxDecoration(color: fondo, borderRadius: Radios.panel, border: Border.all(color: borde)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icono, size: 18, color: color)),
            const SizedBox(width: Espacio.e3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (titulo != null)
                    Text(titulo!, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(mensaje, style: TextStyle(color: color, fontSize: 14, height: 20 / 14)),
                  if (accion != null) ...[const SizedBox(height: Espacio.e2), accion!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista o búsqueda sin resultados, con una acción útil opcional.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.titulo, this.descripcion, this.accion});

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacio.e8, horizontal: Espacio.e4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 28, color: kGris500),
          const SizedBox(height: Espacio.e3),
          Text(titulo, textAlign: TextAlign.center, style: textos.titleSmall),
          if (descripcion != null) ...[
            const SizedBox(height: Espacio.e1),
            Text(descripcion!, textAlign: TextAlign.center, style: textos.bodyMedium!.copyWith(color: kGris600)),
          ],
          if (accion != null) ...[const SizedBox(height: Espacio.e4), accion!],
        ],
      ),
    );
  }
}

/// Buscar un objeto por su clave (ISBN o código) antes de actuar: lo usan Consultar,
/// Actualizar y Eliminar. Valida que no esté vacío y llama a [onBuscar].
class BuscadorClave extends StatefulWidget {
  const BuscadorClave({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.pista,
    required this.onBuscar,
    required this.cargando,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? pista;
  final VoidCallback onBuscar;
  final bool cargando;

  @override
  State<BuscadorClave> createState() => _BuscadorClaveState();
}

class _BuscadorClaveState extends State<BuscadorClave> {
  String? _error;

  void _buscar() {
    final error = widget.controller.text.trim().isEmpty ? 'Este campo es obligatorio.' : null;
    setState(() => _error = error);
    if (error == null) widget.onBuscar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: widget.etiqueta,
            hintText: widget.pista,
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _buscar(),
        ),
        const SizedBox(height: Espacio.e3),
        FilledButton.icon(
          onPressed: widget.cargando ? null : _buscar,
          icon: widget.cargando
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: kGris500))
              : const Icon(LucideIcons.search, size: 18),
          label: const Text('Buscar'),
        ),
      ],
    );
  }
}

/// Grupo de campos de un formulario con su título y una línea de ayuda.
class SeccionFormulario extends StatelessWidget {
  const SeccionFormulario({super.key, required this.titulo, this.descripcion, required this.children});

  final String titulo;
  final String? descripcion;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacio.e6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(titulo, style: textos.titleSmall)),
          if (descripcion != null) ...[
            const SizedBox(height: 2),
            Text(descripcion!, style: textos.bodySmall),
          ],
          const SizedBox(height: Espacio.e3),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: Espacio.e3),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Fila horizontal de chips de selección única para filtros (género, estado).
/// Con [textoTodos] agrega la opción "todos" (valor null).
class FiltroChips extends StatelessWidget {
  const FiltroChips({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.etiquetaDe,
    required this.alSeleccionar,
    this.textoTodos,
    this.adorno,
  });

  final List<String> opciones;
  final String? seleccionado;
  final String Function(String) etiquetaDe;
  final ValueChanged<String?> alSeleccionar;
  final String? textoTodos;

  /// Ícono o punto antes del texto de cada opción (p. ej. el color del estado).
  final Widget Function(String)? adorno;

  Widget _chip(String texto, bool activo, VoidCallback alTocar, [Widget? avatar]) {
    return Padding(
      padding: const EdgeInsets.only(right: Espacio.e2),
      child: ChoiceChip(
        label: Text(texto),
        avatar: avatar,
        selected: activo,
        onSelected: (_) => alTocar(),
        side: BorderSide(color: activo ? kMarca600 : kGris200),
        labelStyle: TextStyle(
          fontFamily: fuenteUi,
          fontSize: 14,
          fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
          color: activo ? kMarca600 : kGris800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (textoTodos != null) _chip(textoTodos!, seleccionado == null, () => alSeleccionar(null)),
          for (final opcion in opciones)
            _chip(etiquetaDe(opcion), seleccionado == opcion, () => alSeleccionar(opcion), adorno?.call(opcion)),
        ],
      ),
    );
  }
}

/// Punto del color de un estado (para los chips de filtro).
Widget puntoEstado(String estado) {
  final (_, punto, _) = coloresEstado(estado);
  return Container(width: 8, height: 8, decoration: BoxDecoration(color: punto, shape: BoxShape.circle));
}

/// Cantidad que respondió el servidor encima de una tabla: "12 libros".
class ConteoServidor extends StatelessWidget {
  const ConteoServidor({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(texto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFeatures: cifrasTabulares)),
        const Spacer(),
        const Text('Total calculado por el servidor', style: TextStyle(color: kGris500, fontSize: 12)),
      ],
    );
  }
}
