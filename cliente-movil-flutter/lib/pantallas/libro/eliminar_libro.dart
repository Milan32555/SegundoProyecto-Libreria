import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../comunes/fichas.dart';
import '../comunes/texto_error.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Libro "${eliminado.titulo}" eliminado correctamente.')));
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
      appBar: AppBar(title: const Text('Eliminar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _isbn,
              decoration: const InputDecoration(labelText: 'ISBN del libro a eliminar'),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null) TextoError(_error!),
            if (_libro != null) ...[
              const SizedBox(height: 8),
              const Text('¿Seguro que desea eliminar este libro?'),
              FichaLibro(libro: _libro!),
              const SizedBox(height: 12),
              Row(children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _cargando ? null : _confirmarEliminacion,
                  child: const Text('Confirmar eliminación'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _libro = null),
                  child: const Text('Cancelar'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
