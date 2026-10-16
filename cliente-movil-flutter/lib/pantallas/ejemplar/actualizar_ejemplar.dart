import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Actualizar Ejemplar. Primero se busca y se muestra TODA la
/// información actual; luego el usuario la modifica y confirma.
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

  @override
  void dispose() {
    _codigoBusqueda.dispose();
    _ubicacion.dispose();
    _precioReposicion.dispose();
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
      final resultado = await buscarEjemplarPorCodigo(_codigoBusqueda.text);
      if (!mounted) return;
      setState(() {
        if (resultado == null) {
          _error = 'No se encontró ningún ejemplar con ese código.';
          return;
        }
        _ejemplar = resultado;
        _estado = resultado.estado;
        _ubicacion.text = resultado.ubicacion;
        _precioReposicion.text = resultado.precioReposicion.toString();
        _fechaIngreso = DateTime.parse(resultado.fechaIngreso);
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    if (_ejemplar == null || !_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await actualizarEjemplar(
        codigo: _ejemplar!.codigo,
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: aFechaServidor(_fechaIngreso!),
        precioReposicion: double.parse(_precioReposicion.text.trim()),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ejemplar actualizado correctamente.')));
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
      appBar: AppBar(title: const Text('Actualizar Ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _ejemplar == null ? _buildBusqueda() : _buildFormulario(),
      ),
    );
  }

  Widget _buildBusqueda() {
    return ListView(
      children: [
        TextField(
          controller: _codigoBusqueda,
          decoration: const InputDecoration(labelText: 'Código del ejemplar a actualizar'),
          onSubmitted: (_) => _buscar(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _cargando ? null : _buscar, child: const Text('Buscar')),
        if (_error != null) TextoError(_error!),
      ],
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text('Código (no editable): ${_ejemplar!.codigo}', style: const TextStyle(color: Colors.grey)),
          Text('Libro (ISBN): ${_ejemplar!.isbnLibro}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _estado,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: estadosEjemplar.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _estado = v!),
          ),
          TextFormField(
            controller: _ubicacion,
            decoration: const InputDecoration(labelText: 'Ubicación'),
            validator: validarObligatorio,
          ),
          CampoFecha(
            etiqueta: 'Fecha de ingreso',
            valor: _fechaIngreso,
            alCambiar: (fecha) => setState(() => _fechaIngreso = fecha),
          ),
          TextFormField(
            controller: _precioReposicion,
            decoration: const InputDecoration(labelText: 'Precio de reposición'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validarDecimalPositivo,
          ),
          if (_error != null) TextoError(_error!),
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
    );
  }
}
