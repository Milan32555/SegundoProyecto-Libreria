import 'package:flutter/material.dart';
import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';

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

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaIngreso = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _fechaIngreso == null) {
      if (_fechaIngreso == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Selecciona la fecha de ingreso.')));
      }
      return;
    }
    setState(() => _enviando = true);
    try {
      final ejemplar = await crearEjemplar(
        codigo: _codigo.text.trim(),
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: _fechaIngreso!.toIso8601String().substring(0, 19),
        precioReposicion: double.parse(_precioReposicion.text),
        isbnLibro: _isbnLibro.text.trim(),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ejemplar "${ejemplar.codigo}" creado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error de conexión con el servidor.')));
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
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _isbnLibro,
                decoration: const InputDecoration(labelText: 'ISBN del libro'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: estadosEjemplar.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _estado = v!),
              ),
              TextFormField(
                controller: _ubicacion,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_fechaIngreso == null
                    ? 'Fecha de ingreso: (sin elegir)'
                    : 'Fecha de ingreso: ${_fechaIngreso!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _elegirFecha,
              ),
              TextFormField(
                controller: _precioReposicion,
                decoration: const InputDecoration(labelText: 'Precio de reposición'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Número inválido' : null,
              ),
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
