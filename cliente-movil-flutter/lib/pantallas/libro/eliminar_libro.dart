import 'package:flutter/material.dart';
import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';

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

  Future<void> _buscar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _libro = null;
    });
    try {
      final resultado = await buscarLibroPorIsbn(_isbn.text.trim());
      setState(() => _libro = resultado);
      if (resultado == null) {
        setState(() => _error = 'No se encontró ningún libro con ese ISBN.');
      }
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'Error de conexión con el servidor.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (_libro == null) return;
    setState(() => _cargando = true);
    try {
      final eliminado = await eliminarLibro(_libro!.isbn);
      libroObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Libro "${eliminado.titulo}" eliminado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
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
            TextField(controller: _isbn, decoration: const InputDecoration(labelText: 'ISBN a eliminar')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            if (_libro != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ISBN: ${_libro!.isbn}'),
                    Text('Título: ${_libro!.titulo}'),
                    Text('Autor: ${_libro!.autor}'),
                    Text('Precio: \$${_libro!.precio.toStringAsFixed(0)}'),
                    Text('Páginas: ${_libro!.numeroPaginas}'),
                    Text('Publicación: ${_libro!.fechaPublicacion}'),
                    Text('Género: ${_libro!.genero}'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _cargando ? null : _confirmarEliminacion,
                child: const Text('Confirmar eliminación'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
