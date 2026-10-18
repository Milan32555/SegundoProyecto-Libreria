import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../comunes/componentes.dart';

/// Caso de uso: Listar Ejemplares en una grilla, con filtro (del lado del servidor)
/// por estado y/o ISBN del libro. El total encontrado también lo calcula el servidor.
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
  int _total = 0;
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
      if (mounted) {
        setState(() {
          _ejemplares = resultado.ejemplares;
          _total = resultado.total;
        });
      }
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Filtro pedido por el usuario (el refresco del Observer usa _cargar sin cerrar el teclado).
  void _filtrar() {
    FocusManager.instance.primaryFocus?.unfocus();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplares')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _isbnLibro,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'ISBN del libro (opcional)',
                    prefixIcon: const Icon(Icons.qr_code_2_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Filtrar',
                      onPressed: _cargando ? null : _filtrar,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                  onSubmitted: (_) => _filtrar(),
                ),
                const SizedBox(height: 12),
                SelectorChips(
                  opciones: estadosEjemplar,
                  seleccionado: _estado,
                  etiquetaDe: etiquetaEstado,
                  textoTodos: 'Todos',
                  desplazable: true,
                  alSeleccionar: (estado) {
                    setState(() => _estado = estado);
                    _filtrar();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _total == 1 ? '1 ejemplar' : '$_total ejemplares',
                  style: const TextStyle(color: kTinta, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
          ),
          SizedBox(height: 2, child: _cargando ? const LinearProgressIndicator() : null),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espacio.md),
              child: Aviso(_error!),
            ),
          Expanded(
            child: _ejemplares.isEmpty
                ? const EstadoVacio(icono: Icons.inventory_2_outlined, mensaje: 'No hay ejemplares para mostrar.')
                : ListView(
                    padding: const EdgeInsets.all(Espacio.md),
                    children: [
                      const PistaDesplazamiento(),
                      const SizedBox(height: Espacio.sm),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('EJEMPLAR')),
                              DataColumn(label: Text('ESTADO')),
                              DataColumn(label: Text('REPOSICIÓN'), numeric: true),
                              DataColumn(label: Text('PRÉSTAMOS'), numeric: true),
                              DataColumn(label: Text('INGRESO')),
                              DataColumn(label: Text('LIBRO (ISBN)')),
                            ],
                            rows: [
                              for (final e in _ejemplares)
                                DataRow(
                                  cells: [
                                    DataCell(CeldaDoble(principal: e.codigo, secundario: e.ubicacion)),
                                    DataCell(Pastilla(etiquetaEstado(e.estado), color: colorEstado(e.estado))),
                                    DataCell(
                                      Text(
                                        formatearPrecio(e.precioReposicion),
                                        style: const TextStyle(color: kDorado, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    DataCell(Text('${e.numeroPrestamos}')),
                                    DataCell(Text(formatearFechaCortaIso(e.fechaIngreso))),
                                    DataCell(Text(e.isbnLibro, style: const TextStyle(color: kTinta3))),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
