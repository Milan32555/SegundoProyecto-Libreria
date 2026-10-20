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
import '../comunes/fichas.dart';

/// Caso de uso: Actualizar Ejemplar. Primero se busca y se muestra TODA su información actual;
/// luego se editan los datos. El número de préstamos se ve pero no se edita: lo calcula el
/// servidor (suma 1 al pasar a Prestado), y al guardar se muestra el valor nuevo.
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
  DateTime? _fechaIngreso;
  String _estado = estadosEjemplar.first;

  Ejemplar? _ejemplar;
  Ejemplar? _guardado;
  String? _sinResultado;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_codigoBusqueda, _ubicacion, _precioReposicion]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final codigo = _codigoBusqueda.text.trim();
    setState(() {
      _cargando = true;
      _error = null;
      _sinResultado = null;
      _ejemplar = null;
      _guardado = null;
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(codigo);
      if (!mounted) return;
      setState(() {
        if (resultado == null) {
          _sinResultado = 'No hay ningún ejemplar con el código «$codigo».';
          return;
        }
        _ejemplar = resultado;
        _estado = resultado.estado;
        _ubicacion.text = resultado.ubicacion;
        final precio = resultado.precioReposicion;
        _precioReposicion.text = precio == precio.roundToDouble() ? precio.toStringAsFixed(0) : '$precio';
        _fechaIngreso = DateTime.parse(resultado.fechaIngreso);
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_ejemplar == null || !_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final actualizado = await actualizarEjemplar(
        codigo: _ejemplar!.codigo,
        estado: _estado,
        ubicacion: _ubicacion.text.trim(),
        fechaIngreso: aFechaServidor(_fechaIngreso!),
        precioReposicion: double.parse(_precioReposicion.text.trim()),
      );
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cambios guardados: ${actualizado.codigo} quedó ${etiquetaEstado(actualizado.estado).toLowerCase()} '
            'con ${actualizado.numeroPrestamos} préstamos.',
          ),
        ),
      );
      setState(() {
        _guardado = actualizado;
        _ejemplar = null;
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _reiniciar() => setState(() {
    _ejemplar = null;
    _guardado = null;
    _error = null;
    _codigoBusqueda.clear();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplares')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
          children: [
            const EncabezadoPantalla(
              titulo: 'Actualizar ejemplar',
              descripcion: 'Busca la copia por su código: verás sus datos actuales y podrás modificarlos.',
            ),
            if (_ejemplar == null && _guardado == null)
              BuscadorClave(
                controller: _codigoBusqueda,
                etiqueta: 'Código del ejemplar',
                pista: 'EJ-001',
                onBuscar: _buscar,
                cargando: _cargando,
              ),
            if (_sinResultado != null)
              EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
            if (_guardado != null) ...[
              FichaEjemplar(ejemplar: _guardado!, titulo: 'Datos guardados'),
              const SizedBox(height: Espacio.e4),
              OutlinedButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                label: const Text('Actualizar otro ejemplar'),
              ),
            ],
            if (_ejemplar != null) ..._formulario(),
            if (_error != null)
              Aviso(_error!, titulo: _ejemplar != null ? 'No se pudieron guardar los cambios' : 'No se pudo buscar el ejemplar'),
          ],
        ),
      ),
    );
  }

  List<Widget> _formulario() => [
    FichaEjemplar(ejemplar: _ejemplar!, titulo: 'Datos actuales'),
    const SizedBox(height: Espacio.e6),
    SeccionFormulario(
      titulo: 'Nuevos datos',
      descripcion: 'El código ${_ejemplar!.codigo} y el libro ${_ejemplar!.isbnLibro} no se pueden modificar.',
      children: [
        DropdownButtonFormField<String>(
          initialValue: _estado,
          decoration: const InputDecoration(labelText: 'Estado'),
          icon: const Icon(LucideIcons.chevronDown, size: 18),
          items: [for (final e in estadosEjemplar) DropdownMenuItem(value: e, child: InsigniaEstado(e))],
          onChanged: (e) => setState(() => _estado = e!),
        ),
        TextFormField(
          controller: _ubicacion,
          decoration: const InputDecoration(labelText: 'Ubicación'),
          textCapitalization: TextCapitalization.sentences,
          validator: validarObligatorio,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        CampoFecha(
          etiqueta: 'Fecha de ingreso',
          valor: _fechaIngreso,
          alCambiar: (fecha) => setState(() => _fechaIngreso = fecha),
        ),
        TextFormField(
          controller: _precioReposicion,
          decoration: const InputDecoration(labelText: 'Precio de reposición', prefixText: '\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validarDecimalPositivo,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        TextFormField(
          key: ValueKey('prestamos-${_ejemplar!.codigo}'),
          initialValue: '${_ejemplar!.numeroPrestamos}',
          readOnly: true,
          enableInteractiveSelection: false,
          style: const TextStyle(color: kGris600),
          decoration: const InputDecoration(
            labelText: 'Número de préstamos',
            suffixIcon: Tooltip(message: 'Lo calcula el servidor', child: Icon(LucideIcons.lock, size: 16)),
            filled: true,
            fillColor: kGris50,
            helperText: 'Lo calcula el servidor: suma 1 cada vez que el ejemplar pasa a Prestado.',
          ),
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
