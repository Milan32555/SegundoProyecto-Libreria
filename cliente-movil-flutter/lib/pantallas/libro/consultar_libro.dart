import 'package:flutter/material.dart';
import '../../modelos/libro.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';

/// Caso de uso: Buscar/Consultar UN SOLO Libro a partir de un criterio (el ISBN).
class ConsultarLibro extends StatefulWidget {
  const ConsultarLibro({super.key});

  @override
  State<ConsultarLibro> createState() => _ConsultarLibroState();
}

class _ConsultarLibroState extends State<ConsultarLibro> {
  final _isbn = TextEditingController();
  Libro? _libro;
  bool _buscado = false;
  bool _cargando = false;
  String? _error;

  Future<void> _buscar() async {
    setState(() { _cargando = true; _error = null; _libro = null; _buscado = false; });
    try {
      final resultado = await buscarLibroPorIsbn(_isbn.text.trim());
      setState(() { _libro = resultado; _buscado = true; });
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _isbn, decoration: const InputDecoration(labelText: 'ISBN')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_buscado && _libro == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No se encontró ningún libro con ese ISBN.'),
              ),
            if (_libro != null)
              Card(
                margin: const EdgeInsets.only(top: 16),
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
          ],
        ),
      ),
    );
  }
}
