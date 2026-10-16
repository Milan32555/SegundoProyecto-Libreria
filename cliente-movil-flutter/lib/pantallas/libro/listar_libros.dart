import 'package:flutter/material.dart';
import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';

/// Caso de uso: Listar Libros, con filtro por autor y/o género.
///
/// Patrón Observer: esta pantalla se SUSCRIBE a `libroObservable` en initState.
/// Cada vez que otra pantalla (Agregar/Actualizar/Eliminar) notifica un cambio,
/// `_cargar()` se vuelve a ejecutar automáticamente y refresca la lista.
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
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final resultado = await listarLibrosFiltrados(autor: _autor.text, genero: _genero);
      if (mounted) setState(() => _libros = resultado);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'Error de conexión con el servidor.');
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
              IconButton(onPressed: _cargar, icon: const Icon(Icons.filter_alt)),
            ]),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_cargando) const LinearProgressIndicator(),
            Expanded(
              child: _libros.isEmpty
                  ? const Center(child: Text('No hay libros para mostrar.'))
                  : ListView.separated(
                      itemCount: _libros.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final l = _libros[i];
                        return ListTile(
                          title: Text(l.titulo),
                          subtitle: Text('${l.autor} · ${l.genero} · ISBN ${l.isbn}'),
                          trailing: Text('\$${l.precio.toStringAsFixed(0)}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
