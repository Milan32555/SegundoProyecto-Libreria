import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../utilidades/formato.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Listar Libros en una grilla, con filtro (del lado del servidor) por autor y/o género.
///
/// Patrón Observer: esta pantalla se SUSCRIBE a `libroObservable` en initState.
/// Cada vez que el sujeto notifica un cambio (una operación en esta app o un cambio
/// hecho desde otro cliente), `_cargar()` se ejecuta de nuevo y refresca la grilla.
class ListarLibros extends StatefulWidget {
  const ListarLibros({super.key});

  @override
  State<ListarLibros> createState() => _ListarLibrosState();
}

class _ListarLibrosState extends State<ListarLibros> {
  final _autor = TextEditingController();
  String? _genero;
  List<Libro> _libros = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    libroObservable.suscribir(_cargar); // Observer
  }

  @override
  void dispose() {
    libroObservable.desuscribir(_cargar); // evita fugas de memoria
    _autor.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultado = await listarLibrosFiltrados(autor: _autor.text, genero: _genero);
      if (mounted) setState(() => _libros = resultado);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listar Libros')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _autor,
                  decoration: const InputDecoration(labelText: 'Autor contiene'),
                  onSubmitted: (_) => _cargar(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _genero,
                hint: const Text('Género'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('(todos)')),
                  ...generos.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                ],
                onChanged: (v) => setState(() => _genero = v),
              ),
              IconButton(
                tooltip: 'Filtrar',
                onPressed: _cargando ? null : _cargar,
                icon: const Icon(Icons.filter_alt),
              ),
            ]),
            if (_error != null) TextoError(_error!),
            if (_cargando) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('${_libros.length} libro(s)', style: const TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: _libros.isEmpty
                  ? const Center(child: Text('No hay libros para mostrar.'))
                  : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 8,
                          columns: const [
                            DataColumn(label: Text('ISBN')),
                            DataColumn(label: Text('Título')),
                            DataColumn(label: Text('Autor')),
                            DataColumn(label: Text('Precio'), numeric: true),
                            DataColumn(label: Text('Páginas'), numeric: true),
                            DataColumn(label: Text('Publicación')),
                            DataColumn(label: Text('Género')),
                          ],
                          rows: [
                            for (final l in _libros)
                              DataRow(cells: [
                                DataCell(Text(l.isbn)),
                                DataCell(Text(l.titulo)),
                                DataCell(Text(l.autor)),
                                DataCell(Text(formatearPrecio(l.precio))),
                                DataCell(Text('${l.numeroPaginas}')),
                                DataCell(Text(formatearFechaIso(l.fechaPublicacion))),
                                DataCell(Text(l.genero)),
                              ]),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
