import 'package:flutter/material.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/texto_error.dart';

/// Caso de uso: Actualizar Libro. Primero se busca y se muestra TODA la
/// información actual; luego el usuario la modifica y confirma.
class ActualizarLibro extends StatefulWidget {
  const ActualizarLibro({super.key});

  @override
  State<ActualizarLibro> createState() => _ActualizarLibroState();
}

class _ActualizarLibroState extends State<ActualizarLibro> {
  final _formKey = GlobalKey<FormState>();
  final _isbnBusqueda = TextEditingController();
  final _titulo = TextEditingController();
  final _autor = TextEditingController();
  final _precio = TextEditingController();
  final _numeroPaginas = TextEditingController();
  DateTime? _fechaPublicacion;
  String _genero = generos.first;

  Libro? _libro;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _isbnBusqueda.dispose();
    _titulo.dispose();
    _autor.dispose();
    _precio.dispose();
    _numeroPaginas.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _libro = null;
    });
    try {
      final resultado = await buscarLibroPorIsbn(_isbnBusqueda.text);
      if (!mounted) return;
      setState(() {
        if (resultado == null) {
          _error = 'No se encontró ningún libro con ese ISBN.';
          return;
        }
        _libro = resultado;
        _titulo.text = resultado.titulo;
        _autor.text = resultado.autor;
        _precio.text = resultado.precio.toString();
        _numeroPaginas.text = resultado.numeroPaginas.toString();
        _fechaPublicacion = DateTime.parse(resultado.fechaPublicacion);
        _genero = resultado.genero;
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (_libro == null || !_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await actualizarLibro(
        isbn: _libro!.isbn,
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        precio: double.parse(_precio.text.trim()),
        numeroPaginas: int.parse(_numeroPaginas.text.trim()),
        fechaPublicacion: aFechaServidor(_fechaPublicacion!),
        genero: _genero,
      );
      libroObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Libro actualizado correctamente.')));
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
      appBar: AppBar(title: const Text('Actualizar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _libro == null ? _buildBusqueda() : _buildFormulario(),
      ),
    );
  }

  Widget _buildBusqueda() {
    return ListView(
      children: [
        TextField(
          controller: _isbnBusqueda,
          decoration: const InputDecoration(labelText: 'ISBN del libro a actualizar'),
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
          Text('ISBN (no editable): ${_libro!.isbn}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
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
          Row(children: [
            FilledButton(
              onPressed: _cargando ? null : _guardarCambios,
              child: const Text('Guardar cambios'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => setState(() => _libro = null),
              child: const Text('Cancelar'),
            ),
          ]),
        ],
      ),
    );
  }
}
