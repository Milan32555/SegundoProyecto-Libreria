import 'package:flutter/material.dart';
import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';

class ActualizarEjemplar extends StatefulWidget {
  const ActualizarEjemplar({super.key});

  @override
  State<ActualizarEjemplar> createState() => _ActualizarEjemplarState();
}

class _ActualizarEjemplarState extends State<ActualizarEjemplar> {
  final _formKey = GlobalKey<FormState>();
  final _codigoBusqueda = TextEditingController();
  final _ubicacion = TextEditingController();
  final _precioReposicion = TextEditingController();
  DateTime? _fechaIngreso;
  String _estado = estadosEjemplar.first;

  Ejemplar? _ejemplar;
  bool _cargando = false;
  String? _error;

  Future<void> _buscar() async {
    setState(() { _cargando = true; _error = null; _ejemplar = null; });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigoBusqueda.text.trim());
      if (resultado == null) {
        setState(() => _error = 'No se encontró ningún ejemplar con ese código.');
      } else {
        setState(() {
          _ejemplar = resultado;
          _estado = resultado.estado;
          _ubicacion.text = resultado.ubicacion;
          _precioReposicion.text = resultado.precioReposicion.toString();
          _fechaIngreso = DateTime.parse(resultado.fechaIngreso);
        });
      }
    } on ErrorGraphQL catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaIngreso = fecha);
  }

  Future<void> _guardarCambios() async {
    if (_ejemplar == null || !_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await actualizarEjemplar(
        codigo: _ejemplar!.codigo,
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: _fechaIngreso!.toIso8601String().substring(0, 19),
        precioReposicion: double.parse(_precioReposicion.text),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ejemplar actualizado correctamente.')));
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
      appBar: AppBar(title: const Text('Actualizar Ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _ejemplar == null
            ? ListView(
                children: [
                  TextField(
                      controller: _codigoBusqueda,
                      decoration: const InputDecoration(labelText: 'Código a actualizar')),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              )
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('Código (no editable): ${_ejemplar!.codigo}',
                        style: const TextStyle(color: Colors.grey)),
                    Text('Libro: ${_ejemplar!.isbnLibro}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: estadosEjemplar
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _estado = v!),
                    ),
                    TextFormField(
                      controller: _ubicacion,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title:
                          Text('Fecha de ingreso: ${_fechaIngreso!.toLocal()}'.split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _elegirFecha,
                    ),
                    TextFormField(
                      controller: _precioReposicion,
                      decoration: const InputDecoration(labelText: 'Precio de reposición'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          (v == null || double.tryParse(v) == null) ? 'Número inválido' : null,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 20),
                    Row(children: [
                      FilledButton(
                        onPressed: _cargando ? null : _guardarCambios,
                        child: const Text('Guardar cambios'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => setState(() => _ejemplar = null),
                        child: const Text('Cancelar'),
                      ),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }
}
