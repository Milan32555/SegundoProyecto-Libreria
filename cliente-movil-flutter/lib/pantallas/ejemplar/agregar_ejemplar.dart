import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Adicionar Ejemplar a un Libro existente.
class AgregarEjemplar extends StatefulWidget {
  const AgregarEjemplar({super.key});

  @override
  State<AgregarEjemplar> createState() => _AgregarEjemplarState();
}

class _AgregarEjemplarState extends State<AgregarEjemplar> {
  final _formKey = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _isbnLibro = TextEditingController();
  final _ubicacion = TextEditingController();
  final _precioReposicion = TextEditingController();
  DateTime? _fechaIngreso;
  String _estado = estadosEjemplar.first;

  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    _isbnLibro.dispose();
    _ubicacion.dispose();
    _precioReposicion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    final formularioValido = _formKey.currentState!.validate();
    if (_fechaIngreso == null) {
      setState(() => _error = 'Seleccione la fecha de ingreso.');
      return;
    }
    if (!formularioValido) return;

    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final ejemplar = await crearEjemplar(
        codigo: _codigo.text.trim(),
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: aFechaServidor(_fechaIngreso!),
        precioReposicion: double.parse(_precioReposicion.text.trim()),
        isbnLibro: _isbnLibro.text.trim(),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejemplar "${ejemplar.codigo}" creado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codigo,
                decoration: const InputDecoration(labelText: 'Código del ejemplar'),
                validator: validarObligatorio,
              ),
              TextFormField(
                controller: _isbnLibro,
                decoration: const InputDecoration(labelText: 'ISBN del libro al que pertenece'),
                validator: validarObligatorio,
              ),
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
              FilledButton(
                onPressed: _enviando ? null : _guardar,
                child: Text(_enviando ? 'Guardando...' : 'Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
