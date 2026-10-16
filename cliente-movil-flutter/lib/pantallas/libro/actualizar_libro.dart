import 'package:flutter/material.dart';
import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';

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

  Future<void> _buscar() async {
    setState(() { _cargando = true; _error = null; _libro = null; });
    try {
      final resultado = await buscarLibroPorIsbn(_isbnBusqueda.text.trim());
      if (resultado == null) {
        setState(() => _error = 'No se encontró ningún libro con ese ISBN.');
      } else {
        setState(() {
          _libro = resultado;
          _titulo.text = resultado.titulo;
          _autor.text = resultado.autor;
          _precio.text = resultado.precio.toString();
          _numeroPaginas.text = resultado.numeroPaginas.toString();
          _fechaPublicacion = DateTime.parse(resultado.fechaPublicacion);
          _genero = resultado.genero;
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
      initialDate: _fechaPublicacion ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaPublicacion = fecha);
  }

  Future<void> _guardarCambios() async {
    if (_libro == null || !_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await actualizarLibro(
        isbn: _libro!.isbn,
        titulo: _titulo.text.trim(),
        autor: _autor.text.trim(),
        precio: double.parse(_precio.text),
        numeroPaginas: int.parse(_numeroPaginas.text),
        fechaPublicacion: _fechaPublicacion!.toIso8601String().substring(0, 19),
        genero: _genero,
      );
      libroObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Libro actualizado correctamente.')));
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
      appBar: AppBar(title: const Text('Actualizar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _libro == null
            ? ListView(
                children: [
                  TextField(
                      controller: _isbnBusqueda,
                      decoration: const InputDecoration(labelText: 'ISBN a actualizar')),
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
                    Text('ISBN (no editable): ${_libro!.isbn}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
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
                      validator: (v) =>
                          (v == null || double.tryParse(v) == null) ? 'Número inválido' : null,
                    ),
                    TextFormField(
                      controller: _numeroPaginas,
                      decoration: const InputDecoration(labelText: 'Número de páginas'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || int.tryParse(v) == null) ? 'Número inválido' : null,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Fecha de publicación: ${_fechaPublicacion!.toLocal()}'
                          .split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _elegirFecha,
                    ),
                    DropdownButtonFormField<String>(
                      value: _genero,
                      decoration: const InputDecoration(labelText: 'Género'),
                      items: generos.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _genero = v!),
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
                        onPressed: () => setState(() => _libro = null),
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
