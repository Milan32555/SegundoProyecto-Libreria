import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/libro.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_libro.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/componentes.dart';

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

  bool _intentado = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_isbn, _titulo, _autor, _precio, _numeroPaginas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _intentado = true);
    final valido = _formKey.currentState!.validate();
    if (!valido || validarFecha(_fechaPublicacion) != null) return;

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
      libroObservable.notificar(); // Observer: avisa a Listar que debe refrescarse
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Libro adicionado: «${libro.titulo}».')));
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
      appBar: AppBar(title: const Text('Libros')),
      body: Form(
        key: _formKey,
        autovalidateMode: _intentado ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
          children: [
            const EncabezadoPantalla(titulo: 'Adicionar libro', descripcion: 'Registra un título nuevo en el inventario.'),
            SeccionFormulario(
              titulo: 'Identificación',
              descripcion: 'El ISBN identifica la edición y no se puede cambiar después.',
              children: [
                TextFormField(
                  controller: _isbn,
                  decoration: const InputDecoration(labelText: 'ISBN', hintText: '978-0307474728'),
                  autocorrect: false, // es un código: sin autocorrección ni sugerencias
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
                TextFormField(
                  controller: _titulo,
                  decoration: const InputDecoration(labelText: 'Título'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
                TextFormField(
                  controller: _autor,
                  decoration: const InputDecoration(labelText: 'Autor'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
              ],
            ),
            SeccionFormulario(
              titulo: 'Publicación',
              descripcion: 'Fecha y hora de publicación y género literario.',
              children: [
                CampoFecha(
                  etiqueta: 'Fecha de publicación',
                  valor: _fechaPublicacion,
                  error: _intentado ? validarFecha(_fechaPublicacion) : null,
                  alCambiar: (fecha) => setState(() => _fechaPublicacion = fecha),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _genero,
                  decoration: const InputDecoration(labelText: 'Género'),
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  items: [for (final g in generos) DropdownMenuItem(value: g, child: Text(etiquetaGenero(g)))],
                  onChanged: (g) => setState(() => _genero = g!),
                ),
              ],
            ),
            SeccionFormulario(
              titulo: 'Venta',
              descripcion: 'Precio en pesos colombianos y extensión del libro.',
              children: [
                TextFormField(
                  controller: _precio,
                  decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: validarDecimalPositivo,
                ),
                TextFormField(
                  controller: _numeroPaginas,
                  decoration: const InputDecoration(labelText: 'Número de páginas'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: validarEnteroPositivo,
                ),
              ],
            ),
            if (_error != null) Aviso(_error!, titulo: 'No se pudo adicionar el libro'),
            const SizedBox(height: Espacio.e6),
            FilledButton.icon(
              onPressed: _enviando ? null : _guardar,
              icon: _enviando
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: kGris500))
                  : const Icon(LucideIcons.check, size: 18),
              label: const Text('Adicionar libro'),
            ),
          ],
        ),
      ),
    );
  }
}
