import 'package:flutter/material.dart';
import '../../modelos/ejemplar.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';

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

  Future<void> _buscar() async {
    setState(() { _cargando = true; _error = null; _ejemplar = null; _buscado = false; });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigo.text.trim());
      setState(() { _ejemplar = resultado; _buscado = true; });
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      setState(() => _cargando = false);
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
            TextField(controller: _codigo, decoration: const InputDecoration(labelText: 'Código')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_buscado && _ejemplar == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No se encontró ningún ejemplar con ese código.'),
              ),
            if (_ejemplar != null)
              Card(
                margin: const EdgeInsets.only(top: 16),
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
          ],
        ),
      ),
    );
  }
}
