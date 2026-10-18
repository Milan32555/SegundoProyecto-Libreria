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

/// Caso de uso: Actualizar Ejemplar. Primero se busca y se muestra TODA la
/// información actual; luego el usuario la modifica y confirma.
class ActualizarEjemplar extends StatefulWidget {
  const ActualizarEjemplar({super.key});

  @override
  State<ActualizarEjemplar> createState() => _ActualizarEjemplarState();
}

class _ActualizarEjemplarState extends State<ActualizarEjemplar> {
  final _formKey = GlobalKey<FormState>();
  final _codigoBusqueda = TextEditingController();
  final _ubicacion = TextEditingController();
  final _precioReposicion = TextEditingController();
  final _numeroPrestamos = TextEditingController();
  DateTime? _fechaIngreso;
  String _estado = estadosEjemplar.first;

  Ejemplar? _ejemplar;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _codigoBusqueda.dispose();
    _ubicacion.dispose();
    _precioReposicion.dispose();
    _numeroPrestamos.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    setState(() {
      _cargando = true;
      _error = null;
      _ejemplar = null;
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigoBusqueda.text);
      if (!mounted) return;
      setState(() {
        if (resultado == null) {
          _error = 'No se encontró ningún ejemplar con ese código.';
          return;
        }
        _ejemplar = resultado;
        _estado = resultado.estado;
        _ubicacion.text = resultado.ubicacion;
        _precioReposicion.text = resultado.precioReposicion.toString();
        _numeroPrestamos.text = resultado.numeroPrestamos.toString();
        _fechaIngreso = DateTime.parse(resultado.fechaIngreso);
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    FocusManager.instance.primaryFocus?.unfocus(); // cierra el teclado para que no tape los resultados
    if (_ejemplar == null || !_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await actualizarEjemplar(
        codigo: _ejemplar!.codigo,
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: aFechaServidor(_fechaIngreso!),
        precioReposicion: double.parse(_precioReposicion.text.trim()),
        numeroPrestamos: int.parse(_numeroPrestamos.text.trim()),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ejemplar actualizado correctamente.')));
      Navigator.pop(context);
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: _ejemplar == null ? _buildBusqueda() : _buildFormulario());
  }

  Widget _buildBusqueda() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
      children: [
        const EncabezadoPantalla(
          etiqueta: 'Ejemplar',
          titulo: 'Actualizar ejemplar',
          descripcion: 'Busca el ejemplar por su código: verás sus datos actuales y podrás modificarlos.',
        ),
        BuscadorClave(
          controller: _codigoBusqueda,
          etiqueta: 'Código del ejemplar a actualizar',
          icono: Icons.tag_rounded,
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
            etiqueta: 'Ejemplar · ${_ejemplar!.codigo}',
            titulo: 'Editar datos',
            descripcion: 'Pertenece al libro ${_ejemplar!.isbnLibro}. El código no se puede modificar.',
          ),
          const EtiquetaSeccion('Estado'),
          const SizedBox(height: Espacio.sm),
          SelectorChips(
            opciones: estadosEjemplar,
            seleccionado: _estado,
            etiquetaDe: etiquetaEstado,
            alSeleccionar: (e) => setState(() => _estado = e!),
          ),
          const SizedBox(height: Espacio.lg),
          TextFormField(
            controller: _ubicacion,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Ubicación', prefixIcon: Icon(Icons.place_outlined)),
            validator: validarObligatorio,
          ),
          const SizedBox(height: 12),
          CampoFecha(
            etiqueta: 'Fecha de ingreso',
            valor: _fechaIngreso,
            alCambiar: (fecha) => setState(() => _fechaIngreso = fecha),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _precioReposicion,
            decoration: const InputDecoration(
              labelText: 'Precio de reposición',
              prefixIcon: Icon(Icons.payments_outlined),
              prefixText: '\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validarDecimalPositivo,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numeroPrestamos,
            decoration: const InputDecoration(labelText: 'Número de préstamos', prefixIcon: Icon(Icons.repeat_rounded)),
            keyboardType: TextInputType.number,
            validator: validarEnteroNoNegativo,
          ),
          if (_error != null) Aviso(_error!),
          const SizedBox(height: Espacio.lg),
          FilledButton.icon(
            onPressed: _cargando ? null : _guardarCambios,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => setState(() => _ejemplar = null), child: const Text('Cancelar')),
        ],
      ),
    );
  }
}
