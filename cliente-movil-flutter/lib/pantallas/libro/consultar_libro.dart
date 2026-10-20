import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/libro.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

enum _Criterio { isbn, titulo }

/// Caso de uso: Consultar UN SOLO Libro por un criterio (ISBN o título).
/// Si se abre desde el buscador del inicio, recibe el criterio y el texto y busca enseguida.
class ConsultarLibro extends StatefulWidget {
  const ConsultarLibro({super.key});

  @override
  State<ConsultarLibro> createState() => _ConsultarLibroState();
}

class _ConsultarLibroState extends State<ConsultarLibro> {
  final _valor = TextEditingController();
  _Criterio _criterio = _Criterio.isbn;
  Libro? _libro;
  String? _sinResultado;
  bool _cargando = false;
  String? _error;
  bool _argumentosLeidos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentosLeidos) return;
    _argumentosLeidos = true;
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    if (argumentos is ({String criterio, String valor})) {
      _criterio = argumentos.criterio == 'isbn' ? _Criterio.isbn : _Criterio.titulo;
      _valor.text = argumentos.valor;
      WidgetsBinding.instance.addPostFrameCallback((_) => _buscar());
    }
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape el resultado
    final valor = _valor.text.trim();
    setState(() {
      _cargando = true;
      _error = null;
      _libro = null;
      _sinResultado = null;
    });
    try {
      final porIsbn = _criterio == _Criterio.isbn;
      final resultado = porIsbn ? await buscarLibroPorIsbn(valor) : await buscarLibroPorTitulo(valor);
      if (!mounted) return;
      setState(() {
        _libro = resultado;
        if (resultado == null) {
          _sinResultado = porIsbn ? 'No hay ningún libro con el ISBN «$valor».' : 'No hay ningún libro titulado «$valor».';
        }
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final porIsbn = _criterio == _Criterio.isbn;
    return Scaffold(
      appBar: AppBar(title: const Text('Libros')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
        children: [
          const EncabezadoPantalla(
            titulo: 'Consultar libro',
            descripcion: 'Busca un solo libro por su ISBN o por su título (sin importar mayúsculas ni tildes).',
          ),
          SegmentedButton<_Criterio>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Criterio.isbn, label: Text('Por ISBN'), icon: Icon(LucideIcons.hash, size: 16)),
              ButtonSegment(value: _Criterio.titulo, label: Text('Por título'), icon: Icon(LucideIcons.bookOpen, size: 16)),
            ],
            selected: {_criterio},
            onSelectionChanged: (seleccion) => setState(() => _criterio = seleccion.first),
          ),
          const SizedBox(height: Espacio.e4),
          BuscadorClave(
            controller: _valor,
            etiqueta: porIsbn ? 'ISBN' : 'Título',
            pista: porIsbn ? '978-0307474728' : 'Cien años de soledad',
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_error != null) Aviso(_error!, titulo: 'No se pudo consultar'),
          if (_sinResultado != null)
            EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
          if (_libro != null) FichaLibro(libro: _libro!),
        ],
      ),
    );
  }
}
