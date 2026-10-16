import 'package:flutter/material.dart';
import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';

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

  Future<void> _buscar() async {
    setState(() { _cargando = true; _error = null; _ejemplar = null; });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigo.text.trim());
      setState(() => _ejemplar = resultado);
      if (resultado == null) setState(() => _error = 'No se encontró ningún ejemplar con ese código.');
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (_ejemplar == null) return;
    setState(() => _cargando = true);
    try {
      final eliminado = await eliminarEjemplar(_ejemplar!.codigo);
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejemplar "${eliminado.codigo}" eliminado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
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
                decoration: const InputDecoration(labelText: 'Código a eliminar')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_ejemplar != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Código: ${_ejemplar!.codigo}'),
                    Text('Estado: ${_ejemplar!.estado}'),
                    Text('Ubicación: ${_ejemplar!.ubicacion}'),
                    Text('Ingreso: ${_ejemplar!.fechaIngreso}'),
                    Text('Reposición: \$${_ejemplar!.precioReposicion.toStringAsFixed(0)}'),
                    Text('Libro (ISBN): ${_ejemplar!.isbnLibro}'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _cargando ? null : _confirmarEliminacion,
                child: const Text('Confirmar eliminación'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
