import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../comunes/fichas.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Buscar/Consultar UN SOLO Ejemplar a partir de su código.
class ConsultarEjemplar extends StatefulWidget {
  const ConsultarEjemplar({super.key});

  @override
  State<ConsultarEjemplar> createState() => _ConsultarEjemplarState();
}

class _ConsultarEjemplarState extends State<ConsultarEjemplar> {
  final _codigo = TextEditingController();
  Ejemplar? _ejemplar;
  bool _buscado = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    setState(() {
      _cargando = true;
      _error = null;
      _ejemplar = null;
      _buscado = false;
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigo.text);
      if (!mounted) return;
      setState(() {
        _ejemplar = resultado;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar Ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _codigo,
              decoration: const InputDecoration(labelText: 'Código del ejemplar'),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null) TextoError(_error!),
            if (_buscado && _ejemplar == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No se encontró ningún ejemplar con ese código.'),
              ),
            if (_ejemplar != null) FichaEjemplar(ejemplar: _ejemplar!),
          ],
        ),
      ),
    );
  }
}
