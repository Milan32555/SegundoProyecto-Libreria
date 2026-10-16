import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Eliminar Libro. Primero se busca y se muestra TODA la información
/// del objeto; solo después de confirmar se elimina.
class EliminarLibro extends StatefulWidget {
  const EliminarLibro({super.key});

  @override
  State<EliminarLibro> createState() => _EliminarLibroState();
}

class _EliminarLibroState extends State<EliminarLibro> {
  final _isbn = TextEditingController();
  Libro? _libro;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _isbn.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    setState(() {
      _cargando = true;
      _error = null;
      _libro = null;
    });
    try {
      final resultado = await buscarLibroPorIsbn(_isbn.text);
      if (!mounted) return;
      setState(() {
        _libro = resultado;
        if (resultado == null) _error = 'No se encontró ningún libro con ese ISBN.';
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (_libro == null) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final eliminado = await eliminarLibro(_libro!.isbn);
      libroObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Libro "${eliminado.titulo}" eliminado correctamente.')));
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
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          const EncabezadoPantalla(
            etiqueta: 'Libro',
            titulo: 'Eliminar libro',
            descripcion: 'Busca el libro por su ISBN para revisar toda su información antes de eliminarlo.',
          ),
          BuscadorClave(
            controller: _isbn,
            etiqueta: 'ISBN del libro a eliminar',
            icono: Icons.qr_code_2_rounded,
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_libro == null && _error != null) Aviso(_error!),
          if (_libro != null) ...[
            FichaLibro(libro: _libro!),
            const Aviso(
              '¿Seguro que desea eliminar este libro? Esta acción no se puede deshacer.',
              tipo: TipoAviso.advertencia,
            ),
            if (_error != null) Aviso(_error!),
            const SizedBox(height: Espacio.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kRojo, foregroundColor: Colors.white),
              onPressed: _cargando ? null : _confirmarEliminacion,
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Confirmar eliminación'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => setState(() => _libro = null), child: const Text('Cancelar')),
          ],
        ],
      ),
    );
  }
}
