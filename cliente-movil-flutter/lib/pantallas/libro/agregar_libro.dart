import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/texto_error.dart';

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
  String? _error;

  @override
  void dispose() {
    _isbn.dispose();
    _titulo.dispose();
    _autor.dispose();
    _precio.dispose();
    _numeroPaginas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final formularioValido = _formKey.currentState!.validate();
    if (_fechaPublicacion == null) {
      setState(() => _error = 'Seleccione la fecha de publicación.');
      return;
    }
    if (!formularioValido) return;

    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final libro = await crearLibro(
        isbn: _isbn.text.trim(),
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        precio: double.parse(_precio.text.trim()),
        numeroPaginas: int.parse(_numeroPaginas.text.trim()),
        fechaPublicacion: aFechaServidor(_fechaPublicacion!),
        genero: _genero,
      );
      libroObservable.notificar(); // Observer: avisa a la pantalla Listar
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Libro "${libro.titulo}" creado correctamente.')));
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
                validator: validarObligatorio,
              ),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: validarObligatorio,
              ),
              TextFormField(
                controller: _autor,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: validarObligatorio,
              ),
              TextFormField(
                controller: _precio,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: validarDecimalPositivo,
              ),
              TextFormField(
                controller: _numeroPaginas,
                decoration: const InputDecoration(labelText: 'Número de páginas'),
                keyboardType: TextInputType.number,
                validator: validarEnteroPositivo,
              ),
              const SizedBox(height: 8),
              CampoFecha(
                etiqueta: 'Fecha de publicación',
                valor: _fechaPublicacion,
                alCambiar: (fecha) => setState(() => _fechaPublicacion = fecha),
              ),
              DropdownButtonFormField<String>(
                initialValue: _genero,
                decoration: const InputDecoration(labelText: 'Género'),
                items: generos.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _genero = v!),
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
