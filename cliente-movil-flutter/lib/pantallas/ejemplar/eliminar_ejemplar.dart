import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../comunes/fichas.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Eliminar Ejemplar. Primero se busca y se muestra TODA su información;
/// solo después de confirmar se elimina.
class EliminarEjemplar extends StatefulWidget {
  const EliminarEjemplar({super.key});

  @override
  State<EliminarEjemplar> createState() => _EliminarEjemplarState();
}

class _EliminarEjemplarState extends State<EliminarEjemplar> {
  final _codigo = TextEditingController();
  Ejemplar? _ejemplar;
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
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigo.text);
      if (!mounted) return;
      setState(() {
        _ejemplar = resultado;
        if (resultado == null) _error = 'No se encontró ningún ejemplar con ese código.';
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (_ejemplar == null) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final eliminado = await eliminarEjemplar(_ejemplar!.codigo);
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejemplar "${eliminado.codigo}" eliminado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar Ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _codigo,
              decoration: const InputDecoration(labelText: 'Código del ejemplar a eliminar'),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null) TextoError(_error!),
            if (_ejemplar != null) ...[
              const SizedBox(height: 8),
              const Text('¿Seguro que desea eliminar este ejemplar?'),
              FichaEjemplar(ejemplar: _ejemplar!),
              const SizedBox(height: 12),
              Row(children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _cargando ? null : _confirmarEliminacion,
                  child: const Text('Confirmar eliminación'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _ejemplar = null),
                  child: const Text('Cancelar'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
