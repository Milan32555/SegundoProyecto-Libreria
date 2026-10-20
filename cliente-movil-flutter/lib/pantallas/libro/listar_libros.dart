import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../comunes/componentes.dart';
import '../comunes/tabla_datos.dart';

final _columnas = <ColumnaTabla<Libro>>[
  ColumnaTabla(titulo: 'Título', ancho: 176, celda: (l) => CeldaDoble(principal: l.titulo, secundario: l.autor, esLibro: true)),
  ColumnaTabla(titulo: 'Género', ancho: 120, celda: (l) => InsigniaGenero(l.genero)),
  ColumnaTabla(titulo: 'ISBN', ancho: 140, celda: (l) => Text(l.isbn, style: const TextStyle(color: kGris600))),
  ColumnaTabla(titulo: 'Publicación', ancho: 112, celda: (l) => Text(formatearFechaCortaIso(l.fechaPublicacion), style: const TextStyle(color: kGris600))),
  ColumnaTabla(titulo: 'Páginas', ancho: 84, numerica: true, celda: (l) => Text('${l.numeroPaginas}')),
  ColumnaTabla(titulo: 'Precio', ancho: 104, numerica: true, celda: (l) => Text(formatearPrecio(l.precio))),
];

/// Caso de uso: Listar Libros en una grilla con filtro por autor y/o género. El filtro y el
/// total los resuelve el servidor (librosFiltrados + totalLibrosFiltrados).
///
/// Patrón Observer: la pantalla se SUSCRIBE a `libroObservable` en initState y se desuscribe en
/// dispose. Cada notificación (un cambio en esta app o en otro cliente) vuelve a pedir la lista.
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
  bool _cargando = true;
  bool _cargado = false;
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
      if (mounted) {
        setState(() {
          _cargando = false;
          _cargado = true;
        });
      }
    }
  }

  void _filtrar() {
    FocusManager.instance.primaryFocus?.unfocus();
    _cargar();
  }

  void _limpiar() {
    _autor.clear();
    setState(() => _genero = null);
    _cargar();
  }

  bool get _hayFiltros => _autor.text.trim().isNotEmpty || _genero != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listar libros')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/libros/agregar'),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Adicionar libro'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e3, Espacio.e4, Espacio.e2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchBar(
                  controller: _autor,
                  hintText: 'Filtrar por autor',
                  leading: const Icon(LucideIcons.search, size: 18, color: kGris500),
                  trailing: [
                    if (_hayFiltros)
                      IconButton(tooltip: 'Limpiar filtros', onPressed: _limpiar, icon: const Icon(LucideIcons.x, size: 18)),
                    IconButton(tooltip: 'Filtrar', onPressed: _filtrar, icon: const Icon(LucideIcons.arrowRight, size: 18)),
                  ],
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _filtrar(),
                ),
                const SizedBox(height: Espacio.e3),
                FiltroChips(
                  opciones: generos,
                  seleccionado: _genero,
                  etiquetaDe: etiquetaGenero,
                  textoTodos: 'Todos',
                  alSeleccionar: (genero) {
                    setState(() => _genero = genero);
                    _filtrar();
                  },
                ),
                const SizedBox(height: Espacio.e3),
                ConteoServidor(texto: _total == 1 ? '1 libro' : '$_total libros'),
              ],
            ),
          ),
          SizedBox(height: 2, child: _cargando ? const LinearProgressIndicator() : null),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espacio.e4),
              child: Aviso(
                _error!,
                titulo: 'No se pudo cargar la lista',
                accion: OutlinedButton.icon(
                  onPressed: _cargar,
                  icon: const Icon(LucideIcons.rotateCw, size: 16),
                  label: const Text('Reintentar'),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e2, Espacio.e4, 88),
              child: _libros.isEmpty
                  ? (_cargado && _error == null ? _vacio() : const SizedBox.shrink())
                  : TablaDatos<Libro>(etiqueta: 'Libros del inventario', columnas: _columnas, filas: _libros),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio() => _hayFiltros
      ? EstadoVacio(
          icono: LucideIcons.filterX,
          titulo: 'Ningún libro coincide con el filtro',
          descripcion: 'Prueba con otro autor o con otro género.',
          accion: OutlinedButton(onPressed: _limpiar, child: const Text('Limpiar filtros')),
        )
      : const EstadoVacio(
          icono: LucideIcons.bookOpen,
          titulo: 'Todavía no hay libros',
          descripcion: 'Los libros que adiciones aparecerán aquí.',
        );
}
