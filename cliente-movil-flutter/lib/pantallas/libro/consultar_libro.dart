import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../comunes/fichas.dart';
import '../comunes/texto_error.dart';

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
    final etiqueta = _criterio == _Criterio.isbn ? 'ISBN' : 'Título';
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SegmentedButton<_Criterio>(
              segments: const [
                ButtonSegment(value: _Criterio.isbn, label: Text('Por ISBN')),
                ButtonSegment(value: _Criterio.titulo, label: Text('Por título')),
              ],
              selected: {_criterio},
              onSelectionChanged: (seleccion) => setState(() => _criterio = seleccion.first),
            ),
            TextField(
              controller: _valor,
              decoration: InputDecoration(labelText: etiqueta),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null) TextoError(_error!),
            if (_buscado && _libro == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('No se encontró ningún libro con ese ${etiqueta.toLowerCase()}.'),
              ),
            if (_libro != null) FichaLibro(libro: _libro!),
          ],
        ),
      ),
    );
  }
}
