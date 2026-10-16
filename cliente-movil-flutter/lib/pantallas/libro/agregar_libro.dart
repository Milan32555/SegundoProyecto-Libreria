import 'package:flutter/material.dart';

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
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Libro "${libro.titulo}" creado correctamente.')));
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
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
          children: [
            const EncabezadoPantalla(
              etiqueta: 'Libro',
              titulo: 'Nuevo libro',
              descripcion: 'Completa los datos para registrarlo en el servidor.',
            ),
            TextFormField(
              controller: _isbn,
              decoration: const InputDecoration(labelText: 'ISBN', prefixIcon: Icon(Icons.qr_code_2_rounded)),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titulo,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Título', prefixIcon: Icon(Icons.title_rounded)),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _autor,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Autor', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precio,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixIcon: Icon(Icons.payments_outlined),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: validarDecimalPositivo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _numeroPaginas,
                    decoration: const InputDecoration(labelText: 'Páginas', prefixIcon: Icon(Icons.menu_book_rounded)),
                    keyboardType: TextInputType.number,
                    validator: validarEnteroPositivo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CampoFecha(
              etiqueta: 'Fecha de publicación',
              valor: _fechaPublicacion,
              alCambiar: (fecha) => setState(() => _fechaPublicacion = fecha),
            ),
            const SizedBox(height: Espacio.lg),
            const EtiquetaSeccion('Género'),
            const SizedBox(height: Espacio.sm),
            SelectorChips(
              opciones: generos,
              seleccionado: _genero,
              etiquetaDe: etiquetaGenero,
              alSeleccionar: (g) => setState(() => _genero = g!),
            ),
            if (_error != null) Aviso(_error!),
            const SizedBox(height: Espacio.lg),
            FilledButton.icon(
              onPressed: _enviando ? null : _guardar,
              icon: const Icon(Icons.check_rounded),
              label: Text(_enviando ? 'Guardando...' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
