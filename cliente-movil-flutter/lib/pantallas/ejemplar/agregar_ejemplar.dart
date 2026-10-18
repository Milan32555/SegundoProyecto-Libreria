import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../../utilidades/formato.dart';
import '../../utilidades/validaciones.dart';
import '../comunes/campo_fecha.dart';
import '../comunes/componentes.dart';

/// Caso de uso: Adicionar Ejemplar a un Libro existente.
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

  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    _isbnLibro.dispose();
    _ubicacion.dispose();
    _precioReposicion.dispose();
    _numeroPrestamos.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    final formularioValido = _formKey.currentState!.validate();
    if (_fechaIngreso == null) {
      setState(() => _error = 'Seleccione la fecha de ingreso.');
      return;
    }
    if (!formularioValido) return;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ejemplar "${ejemplar.codigo}" creado correctamente.')));
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
              etiqueta: 'Ejemplar',
              titulo: 'Nuevo ejemplar',
              descripcion: 'Registra una copia física de un libro que ya exista en el sistema.',
            ),
            TextFormField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Código del ejemplar', prefixIcon: Icon(Icons.tag_rounded)),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isbnLibro,
              decoration: const InputDecoration(
                labelText: 'ISBN del libro al que pertenece',
                prefixIcon: Icon(Icons.qr_code_2_rounded),
              ),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ubicacion,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.place_outlined)),
              validator: validarObligatorio,
            ),
            const SizedBox(height: 12),
            // La fecha con hora va sola en su fila para que se lea completa en el celular.
            CampoFecha(
              etiqueta: 'Fecha de ingreso',
              valor: _fechaIngreso,
              alCambiar: (fecha) => setState(() => _fechaIngreso = fecha),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioReposicion,
                    decoration: const InputDecoration(
                      labelText: 'Precio de reposición',
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
                    controller: _numeroPrestamos,
                    decoration: const InputDecoration(
                      labelText: 'Número de préstamos',
                      prefixIcon: Icon(Icons.repeat_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    validator: validarEnteroNoNegativo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espacio.lg),
            const EtiquetaSeccion('Estado'),
            const SizedBox(height: Espacio.sm),
            SelectorChips(
              opciones: estadosEjemplar,
              seleccionado: _estado,
              etiquetaDe: etiquetaEstado,
              alSeleccionar: (e) => setState(() => _estado = e!),
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
