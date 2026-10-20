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
import '../comunes/fichas.dart';

/// Caso de uso: Actualizar Libro. Primero se busca y se muestra TODA su información actual;
/// luego se editan los datos y, al guardar, se muestra lo que respondió el servidor.
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
  Libro? _guardado;
  String? _sinResultado;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_isbnBusqueda, _titulo, _autor, _precio, _numeroPaginas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isbn = _isbnBusqueda.text.trim();
    setState(() {
      _cargando = true;
      _error = null;
      _sinResultado = null;
      _libro = null;
      _guardado = null;
    });
    try {
      final resultado = await buscarLibroPorIsbn(isbn);
      if (!mounted) return;
      setState(() {
        if (resultado == null) {
          _sinResultado = 'No hay ningún libro con el ISBN «$isbn».';
          return;
        }
        _libro = resultado;
        _titulo.text = resultado.titulo;
        _autor.text = resultado.autor;
        _precio.text = _sinDecimalesInutiles(resultado.precio);
        _numeroPaginas.text = '${resultado.numeroPaginas}';
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
    FocusManager.instance.primaryFocus?.unfocus();
    if (_libro == null || !_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final actualizado = await actualizarLibro(
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados en el servidor.')));
      setState(() {
        _guardado = actualizado;
        _libro = null;
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _reiniciar() => setState(() {
    _libro = null;
    _guardado = null;
    _error = null;
    _isbnBusqueda.clear();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
          children: [
            const EncabezadoPantalla(
              titulo: 'Actualizar libro',
              descripcion: 'Busca el libro por su ISBN: verás sus datos actuales y podrás modificarlos.',
            ),
            if (_libro == null && _guardado == null)
              BuscadorClave(
                controller: _isbnBusqueda,
                etiqueta: 'ISBN del libro',
                pista: '978-0307474728',
                onBuscar: _buscar,
                cargando: _cargando,
              ),
            if (_sinResultado != null)
              EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
            if (_guardado != null) ...[
              FichaLibro(libro: _guardado!, titulo: 'Datos guardados'),
              const SizedBox(height: Espacio.e4),
              OutlinedButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                label: const Text('Actualizar otro libro'),
              ),
            ],
            if (_libro != null) ..._formulario(),
            if (_error != null)
              Aviso(_error!, titulo: _libro != null ? 'No se pudieron guardar los cambios' : 'No se pudo buscar el libro'),
          ],
        ),
      ),
    );
  }

  List<Widget> _formulario() => [
    FichaLibro(libro: _libro!, titulo: 'Datos actuales'),
    const SizedBox(height: Espacio.e6),
    SeccionFormulario(
      titulo: 'Nuevos datos',
      descripcion: 'El ISBN ${_libro!.isbn} identifica al libro y no se puede modificar.',
      children: [
        TextFormField(
          controller: _titulo,
          decoration: const InputDecoration(labelText: 'Título'),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          validator: validarObligatorio,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        TextFormField(
          controller: _autor,
          decoration: const InputDecoration(labelText: 'Autor'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: validarObligatorio,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        TextFormField(
          controller: _precio,
          decoration: const InputDecoration(labelText: 'Precio', prefixText: '\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: validarDecimalPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        TextFormField(
          controller: _numeroPaginas,
          decoration: const InputDecoration(labelText: 'Número de páginas'),
          keyboardType: TextInputType.number,
          validator: validarEnteroPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        CampoFecha(
          etiqueta: 'Fecha de publicación',
          valor: _fechaPublicacion,
          alCambiar: (fecha) => setState(() => _fechaPublicacion = fecha),
        ),
        DropdownButtonFormField<String>(
          initialValue: _genero,
          decoration: const InputDecoration(labelText: 'Género'),
          style: const TextStyle(fontFamily: fuenteUi, fontSize: 16, color: kGris900),
          icon: const Icon(LucideIcons.chevronDown, size: 18),
          items: [for (final g in generos) DropdownMenuItem(value: g, child: Text(etiquetaGenero(g)))],
          onChanged: (g) => setState(() => _genero = g!),
        ),
      ],
    ),
    FilledButton.icon(
      onPressed: _cargando ? null : _guardarCambios,
      icon: const Icon(LucideIcons.save, size: 18),
      label: const Text('Guardar cambios'),
    ),
    const SizedBox(height: Espacio.e2),
    OutlinedButton(onPressed: _reiniciar, child: const Text('Cancelar')),
  ];
}

/// 39000.0 → "39000"; 39000.5 → "39000.5" (para mostrar el precio en el campo).
String _sinDecimalesInutiles(double valor) => valor == valor.roundToDouble() ? valor.toStringAsFixed(0) : '$valor';
