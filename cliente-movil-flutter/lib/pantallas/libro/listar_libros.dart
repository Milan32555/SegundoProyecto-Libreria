import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../comunes/componentes.dart';

/// Caso de uso: Listar Libros en una grilla, con filtro (del lado del servidor) por autor y/o género.
/// El total de libros encontrados también lo calcula el servidor.
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
  int _total = 0;
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
      if (mounted) {
        setState(() {
          _libros = resultado.libros;
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
      appBar: AppBar(title: const Text('Libros')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _autor,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Autor contiene',
                    prefixIcon: const Icon(Icons.person_search_rounded),
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
                  opciones: generos,
                  seleccionado: _genero,
                  etiquetaDe: etiquetaGenero,
                  textoTodos: 'Todos',
                  desplazable: true,
                  alSeleccionar: (genero) {
                    setState(() => _genero = genero);
                    _filtrar();
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _total == 1 ? '1 libro' : '$_total libros',
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
            child: _libros.isEmpty
                ? const EstadoVacio(icono: Icons.menu_book_rounded, mensaje: 'No hay libros para mostrar.')
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
                              DataColumn(label: Text('LIBRO')),
                              DataColumn(label: Text('GÉNERO')),
                              DataColumn(label: Text('PRECIO'), numeric: true),
                              DataColumn(label: Text('PÁGINAS'), numeric: true),
                              DataColumn(label: Text('PUBLICACIÓN')),
                              DataColumn(label: Text('ISBN')),
                            ],
                            rows: [
                              for (final l in _libros)
                                DataRow(
                                  cells: [
                                    DataCell(CeldaDoble(principal: l.titulo, secundario: l.autor)),
                                    DataCell(Pastilla(etiquetaGenero(l.genero))),
                                    DataCell(
                                      Text(
                                        formatearPrecio(l.precio),
                                        style: const TextStyle(color: kDorado, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    DataCell(Text('${l.numeroPaginas}')),
                                    DataCell(Text(formatearFechaCortaIso(l.fechaPublicacion))),
                                    DataCell(Text(l.isbn, style: const TextStyle(color: kTinta3))),
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
