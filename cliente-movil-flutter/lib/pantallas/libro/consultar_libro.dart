import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

enum _Criterio { isbn, titulo }

/// Caso de uso: Buscar/Consultar UN SOLO Libro a partir de un criterio (ISBN o título).
class ConsultarLibro extends StatefulWidget {
  const ConsultarLibro({super.key});

  @override
  State<ConsultarLibro> createState() => _ConsultarLibroState();
}

class _ConsultarLibroState extends State<ConsultarLibro> {
  final _valor = TextEditingController();
  _Criterio _criterio = _Criterio.isbn;
  Libro? _libro;
  bool _buscado = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    setState(() {
      _cargando = true;
      _error = null;
      _libro = null;
      _buscado = false;
    });
    try {
      final resultado = _criterio == _Criterio.isbn
          ? await buscarLibroPorIsbn(_valor.text)
          : await buscarLibroPorTitulo(_valor.text);
      if (!mounted) return;
      setState(() {
        _libro = resultado;
        _buscado = true;
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
    final etiqueta = porIsbn ? 'ISBN' : 'Título';
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          const EncabezadoPantalla(
            etiqueta: 'Libro',
            titulo: 'Buscar un libro',
            descripcion: 'Consulta un solo libro por su ISBN o por su título exacto.',
          ),
          SegmentedButton<_Criterio>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Criterio.isbn, label: Text('Por ISBN'), icon: Icon(Icons.qr_code_2_rounded)),
              ButtonSegment(value: _Criterio.titulo, label: Text('Por título'), icon: Icon(Icons.title_rounded)),
            ],
            selected: {_criterio},
            onSelectionChanged: (seleccion) => setState(() => _criterio = seleccion.first),
          ),
          const SizedBox(height: Espacio.md),
          BuscadorClave(
            controller: _valor,
            etiqueta: etiqueta,
            icono: porIsbn ? Icons.qr_code_2_rounded : Icons.title_rounded,
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_error != null) Aviso(_error!),
          if (_buscado && _libro == null)
            EstadoVacio(
              icono: Icons.search_off_rounded,
              mensaje: 'No se encontró ningún libro con ese ${etiqueta.toLowerCase()}.',
            ),
          if (_libro != null) FichaLibro(libro: _libro!),
        ],
      ),
    );
  }
}
