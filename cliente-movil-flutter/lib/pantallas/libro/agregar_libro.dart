import 'package:flutter/material.dart';
import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';

/// Caso de uso: Adicionar Libro (único propósito de esta pantalla).
class AgregarLibro extends StatefulWidget {
  const AgregarLibro({super.key});

  @override
  State<AgregarLibro> createState() => _AgregarLibroState();
}

class _AgregarLibroState extends State<AgregarLibro> {
  final _formKey = GlobalKey<FormState>();
  final _isbn = TextEditingController();
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  final _precio = TextEditingController();
  final _numeroPaginas = TextEditingController();
  DateTime? _fechaPublicacion;
  String _genero = generos.first;

  bool _enviando = false;

  @override
  void dispose() {
    _isbn.dispose();
    _titulo.dispose();
    _autor.dispose();
    _precio.dispose();
    _numeroPaginas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaPublicacion = fecha);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _fechaPublicacion == null) {
      if (_fechaPublicacion == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Selecciona la fecha de publicación.')));
      }
      return;
    }
    setState(() => _enviando = true);
    try {
      final libro = await crearLibro(
        isbn: _isbn.text.trim(),
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        precio: double.parse(_precio.text),
        numeroPaginas: int.parse(_numeroPaginas.text),
        fechaPublicacion: _fechaPublicacion!.toIso8601String().substring(0, 19),
        genero: _genero,
      );
      libroObservable.notificar(); // Observer: avisa a la pantalla Listar
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Libro "${libro.titulo}" creado correctamente.')));
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
      appBar: AppBar(title: const Text('Adicionar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _isbn,
                decoration: const InputDecoration(labelText: 'ISBN'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _autor,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _precio,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Número inválido' : null,
              ),
              TextFormField(
                controller: _numeroPaginas,
                decoration: const InputDecoration(labelText: 'Número de páginas'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Número inválido' : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_fechaPublicacion == null
                    ? 'Fecha de publicación: (sin elegir)'
                    : 'Fecha de publicación: ${_fechaPublicacion!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _elegirFecha,
              ),
              DropdownButtonFormField<String>(
                value: _genero,
                decoration: const InputDecoration(labelText: 'Género'),
                items: generos.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _genero = v!),
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
