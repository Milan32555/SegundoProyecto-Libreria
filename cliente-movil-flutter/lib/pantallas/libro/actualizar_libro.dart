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
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
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
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Libro actualizado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: _libro == null ? _buildBusqueda() : _buildFormulario());
  }

  Widget _buildBusqueda() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
      children: [
        const EncabezadoPantalla(
          etiqueta: 'Libro',
          titulo: 'Actualizar libro',
          descripcion: 'Busca el libro por su ISBN: verás sus datos actuales y podrás modificarlos.',
        ),
        BuscadorClave(
          controller: _isbnBusqueda,
          etiqueta: 'ISBN del libro a actualizar',
          icono: Icons.qr_code_2_rounded,
          onBuscar: _buscar,
          cargando: _cargando,
        ),
        if (_error != null) Aviso(_error!),
      ],
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          EncabezadoPantalla(
            etiqueta: 'Libro · ISBN ${_libro!.isbn}',
            titulo: 'Editar datos',
            descripcion: 'Estos son los datos actuales. El ISBN no se puede modificar.',
          ),
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
            onPressed: _cargando ? null : _guardarCambios,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => setState(() => _libro = null), child: const Text('Cancelar')),
        ],
      ),
    );
  }
}
