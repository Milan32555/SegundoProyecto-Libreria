import 'package:flutter/material.dart';
import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';

/// Caso de uso: Listar Ejemplares, con filtro por estado y/o isbn del libro.
/// Observer: igual patrón que ListarLibros.
class ListarEjemplares extends StatefulWidget {
  const ListarEjemplares({super.key});

  @override
  State<ListarEjemplares> createState() => _ListarEjemplaresState();
}

class _ListarEjemplaresState extends State<ListarEjemplares> {
  final _isbnLibro = TextEditingController();
  String? _estado;
  List<Ejemplar> _ejemplares = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    ejemplarObservable.suscribir(_cargar);
  }

  @override
  void dispose() {
    ejemplarObservable.desuscribir(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final resultado =
          await listarEjemplaresFiltrados(estado: _estado, isbnLibro: _isbnLibro.text);
      if (mounted) setState(() => _ejemplares = resultado);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listar Ejemplares')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _isbnLibro,
                  decoration: const InputDecoration(labelText: 'ISBN del libro (opcional)'),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _estado,
                hint: const Text('Estado'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('(todos)')),
                  ...estadosEjemplar.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (v) => setState(() => _estado = v),
              ),
              IconButton(onPressed: _cargar, icon: const Icon(Icons.filter_alt)),
            ]),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_cargando) const LinearProgressIndicator(),
            Expanded(
              child: _ejemplares.isEmpty
                  ? const Center(child: Text('No hay ejemplares para mostrar.'))
                  : ListView.separated(
                      itemCount: _ejemplares.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final e = _ejemplares[i];
                        return ListTile(
                          title: Text(e.codigo),
                          subtitle: Text('${e.estado} · ${e.ubicacion} · Libro ${e.isbnLibro}'),
                          trailing: Text('\$${e.precioReposicion.toStringAsFixed(0)}'),
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
