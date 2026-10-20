import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/componentes.dart';

/// Caso de uso: Adicionar Ejemplar (una copia física de un libro que ya existe).
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
  final _numeroPrestamos = TextEditingController(text: '0');
  DateTime? _fechaIngreso;
  String _estado = estadosEjemplar.first;

  bool _intentado = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_codigo, _isbnLibro, _ubicacion, _precioReposicion, _numeroPrestamos]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _intentado = true);
    final valido = _formKey.currentState!.validate();
    if (!valido || validarFecha(_fechaIngreso) != null) return;

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
        numeroPrestamos: int.parse(_numeroPrestamos.text.trim()),
        isbnLibro: _isbnLibro.text.trim(),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ejemplar adicionado: ${ejemplar.codigo}.')));
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
      appBar: AppBar(title: const Text('Ejemplares')),
      body: Form(
        key: _formKey,
        autovalidateMode: _intentado ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
          children: [
            const EncabezadoPantalla(
              titulo: 'Adicionar ejemplar',
              descripcion: 'Registra una copia física de un libro que ya está en el inventario.',
            ),
            SeccionFormulario(
              titulo: 'Identificación',
              descripcion: 'El código es único por copia. El libro debe existir: escribe su ISBN.',
              children: [
                TextFormField(
                  controller: _codigo,
                  decoration: const InputDecoration(labelText: 'Código del ejemplar', hintText: 'EJ-021'),
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
                TextFormField(
                  controller: _isbnLibro,
                  decoration: const InputDecoration(labelText: 'ISBN del libro', hintText: '978-0307474728'),
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
              ],
            ),
            SeccionFormulario(
              titulo: 'Estado y ubicación',
              descripcion: 'Dónde está la copia y en qué condición se encuentra.',
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  style: const TextStyle(fontFamily: fuenteUi, fontSize: 16, color: kGris900),
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  items: [for (final e in estadosEjemplar) DropdownMenuItem(value: e, child: InsigniaEstado(e))],
                  onChanged: (e) => setState(() => _estado = e!),
                ),
                TextFormField(
                  controller: _ubicacion,
                  decoration: const InputDecoration(labelText: 'Ubicación', hintText: 'Estante A1'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  validator: validarObligatorio,
                ),
              ],
            ),
            SeccionFormulario(
              titulo: 'Ingreso y valor',
              descripcion: 'Préstamos que ya tenía la copia al registrarla (normalmente 0).',
              children: [
                CampoFecha(
                  etiqueta: 'Fecha de ingreso',
                  valor: _fechaIngreso,
                  error: _intentado ? validarFecha(_fechaIngreso) : null,
                  alCambiar: (fecha) => setState(() => _fechaIngreso = fecha),
                ),
                TextFormField(
                  controller: _precioReposicion,
                  decoration: const InputDecoration(labelText: 'Precio de reposición', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: validarDecimalPositivo,
                ),
                TextFormField(
                  controller: _numeroPrestamos,
                  decoration: const InputDecoration(labelText: 'Número de préstamos'),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.done,
                  validator: validarEnteroNoNegativo,
                ),
              ],
            ),
            if (_error != null) Aviso(_error!, titulo: 'No se pudo adicionar el ejemplar'),
            const SizedBox(height: Espacio.e6),
            FilledButton.icon(
              onPressed: _enviando ? null : _guardar,
              icon: _enviando
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: kGris500))
                  : const Icon(LucideIcons.check, size: 18),
              label: const Text('Adicionar ejemplar'),
            ),
          ],
        ),
      ),
    );
  }
}
