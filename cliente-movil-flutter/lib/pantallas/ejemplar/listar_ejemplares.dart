import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../utilidades/formato.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Listar Ejemplares en una grilla, con filtro (del lado del servidor)
/// por estado y/o ISBN del libro. Observer: igual patrón que ListarLibros.
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
    ejemplarObservable.suscribir(_cargar); // Observer
  }

  @override
  void dispose() {
    ejemplarObservable.desuscribir(_cargar);
    _isbnLibro.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultado = await listarEjemplaresFiltrados(estado: _estado, isbnLibro: _isbnLibro.text);
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
                  onSubmitted: (_) => _cargar(),
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
              child: Text('${_ejemplares.length} ejemplar(es)', style: const TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: _ejemplares.isEmpty
                  ? const Center(child: Text('No hay ejemplares para mostrar.'))
                  : SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 8,
                          columns: const [
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Ubicación')),
                            DataColumn(label: Text('Ingreso')),
                            DataColumn(label: Text('Reposición'), numeric: true),
                            DataColumn(label: Text('Libro (ISBN)')),
                          ],
                          rows: [
                            for (final e in _ejemplares)
                              DataRow(cells: [
                                DataCell(Text(e.codigo)),
                                DataCell(Text(e.estado)),
                                DataCell(Text(e.ubicacion)),
                                DataCell(Text(formatearFechaIso(e.fechaIngreso))),
                                DataCell(Text(formatearPrecio(e.precioReposicion))),
                                DataCell(Text(e.isbnLibro)),
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
