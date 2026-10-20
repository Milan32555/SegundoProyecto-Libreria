import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/confirmar_eliminacion.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Eliminar Libro. Primero se busca y se muestra TODA su información; la
/// eliminación solo ocurre después de confirmarla en la hoja inferior. Si el libro tiene
/// ejemplares, el servidor la rechaza y aquí se muestra el motivo.
class EliminarLibro extends StatefulWidget {
  const EliminarLibro({super.key});

  @override
  State<EliminarLibro> createState() => _EliminarLibroState();
}

class _EliminarLibroState extends State<EliminarLibro> {
  final _isbn = TextEditingController();
  Libro? _libro;
  String? _sinResultado;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _isbn.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isbn = _isbn.text.trim();
    setState(() {
      _cargando = true;
      _error = null;
      _sinResultado = null;
      _libro = null;
    });
    try {
      final resultado = await buscarLibroPorIsbn(isbn);
      if (!mounted) return;
      setState(() {
        _libro = resultado;
        if (resultado == null) _sinResultado = 'No hay ningún libro con el ISBN «$isbn».';
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar() async {
    final libro = _libro;
    if (libro == null) return;
    final confirmado = await confirmarEliminacion(
      context,
      titulo: '¿Eliminar «${libro.titulo}»?',
      descripcion: 'Se eliminará el libro con ISBN ${libro.isbn}. Esta acción no se puede deshacer.',
    );
    if (!confirmado || !mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await eliminarLibro(libro.isbn);
      libroObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Libro eliminado: «${libro.titulo}».')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
        children: [
          const EncabezadoPantalla(
            titulo: 'Eliminar libro',
            descripcion: 'Busca el libro por su ISBN y revisa toda su información antes de eliminarlo.',
          ),
          BuscadorClave(
            controller: _isbn,
            etiqueta: 'ISBN del libro',
            pista: '978-8420401751',
            onBuscar: _buscar,
            cargando: _cargando && _libro == null,
          ),
          if (_sinResultado != null)
            EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
          if (_error != null)
            Aviso(_error!, titulo: _libro != null ? 'El servidor no permitió eliminar el libro' : 'No se pudo buscar el libro'),
          if (_libro != null) ...[
            FichaLibro(libro: _libro!, titulo: 'Libro a eliminar'),
            const SizedBox(height: Espacio.e6),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kPeligro600),
              onPressed: _cargando ? null : _eliminar,
              icon: const Icon(LucideIcons.trash2, size: 18),
              label: const Text('Eliminar libro'),
            ),
            const SizedBox(height: Espacio.e2),
            OutlinedButton(
              onPressed: () => setState(() {
                _libro = null;
                _error = null;
              }),
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}
