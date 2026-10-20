import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../comunes/componentes.dart';
import '../comunes/tabla_datos.dart';

final _columnas = <ColumnaTabla<Ejemplar>>[
  ColumnaTabla(titulo: 'Código', ancho: 124, celda: (e) => CeldaDoble(principal: e.codigo, secundario: e.ubicacion)),
  ColumnaTabla(titulo: 'Estado', ancho: 136, celda: (e) => InsigniaEstado(e.estado)),
  ColumnaTabla(titulo: 'Libro (ISBN)', ancho: 164, celda: (e) => Text(e.isbnLibro, style: const TextStyle(color: kGris600))),
  ColumnaTabla(titulo: 'Ingreso', ancho: 112, celda: (e) => Text(formatearFechaCortaIso(e.fechaIngreso), style: const TextStyle(color: kGris600))),
  ColumnaTabla(titulo: 'Préstamos', ancho: 96, numerica: true, celda: (e) => Text('${e.numeroPrestamos}')),
  ColumnaTabla(titulo: 'Reposición', ancho: 112, numerica: true, celda: (e) => Text(formatearPrecio(e.precioReposicion))),
];

/// Caso de uso: Listar Ejemplares en una grilla con filtro por estado y/o ISBN del libro. El
/// filtro y el total los resuelve el servidor. Observer igual que en Listar Libros.
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
  bool _cargando = true;
  bool _cargado = false;
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
    _isbnLibro.clear();
    setState(() => _estado = null);
    _cargar();
  }

  bool get _hayFiltros => _isbnLibro.text.trim().isNotEmpty || _estado != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listar ejemplares')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/ejemplares/agregar'),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Adicionar ejemplar'),
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
                  controller: _isbnLibro,
                  hintText: 'Filtrar por ISBN del libro',
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
                  opciones: estadosEjemplar,
                  seleccionado: _estado,
                  etiquetaDe: etiquetaEstado,
                  textoTodos: 'Todos',
                  adorno: puntoEstado,
                  alSeleccionar: (estado) {
                    setState(() => _estado = estado);
                    _filtrar();
                  },
                ),
                const SizedBox(height: Espacio.e3),
                ConteoServidor(texto: _total == 1 ? '1 ejemplar' : '$_total ejemplares'),
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
              child: _ejemplares.isEmpty
                  ? (_cargado && _error == null ? _vacio() : const SizedBox.shrink())
                  : TablaDatos<Ejemplar>(etiqueta: 'Ejemplares del inventario', columnas: _columnas, filas: _ejemplares),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio() => _hayFiltros
      ? EstadoVacio(
          icono: LucideIcons.filterX,
          titulo: 'Ningún ejemplar coincide con el filtro',
          descripcion: 'Prueba con otro estado o revisa el ISBN.',
          accion: OutlinedButton(onPressed: _limpiar, child: const Text('Limpiar filtros')),
        )
      : const EstadoVacio(
          icono: LucideIcons.library,
          titulo: 'Todavía no hay ejemplares',
          descripcion: 'Las copias que registres aparecerán aquí.',
        );
}
