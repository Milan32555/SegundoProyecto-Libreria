import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/confirmar_eliminacion.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Eliminar Ejemplar. Primero se busca y se muestra TODA su información; solo se
/// elimina después de confirmarlo en la hoja inferior.
class EliminarEjemplar extends StatefulWidget {
  const EliminarEjemplar({super.key});

  @override
  State<EliminarEjemplar> createState() => _EliminarEjemplarState();
}

class _EliminarEjemplarState extends State<EliminarEjemplar> {
  final _codigo = TextEditingController();
  Ejemplar? _ejemplar;
  String? _sinResultado;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final codigo = _codigo.text.trim();
    setState(() {
      _cargando = true;
      _error = null;
      _sinResultado = null;
      _ejemplar = null;
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(codigo);
      if (!mounted) return;
      setState(() {
        _ejemplar = resultado;
        if (resultado == null) _sinResultado = 'No hay ningún ejemplar con el código «$codigo».';
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar() async {
    final ejemplar = _ejemplar;
    if (ejemplar == null) return;
    final confirmado = await confirmarEliminacion(
      context,
      titulo: '¿Eliminar el ejemplar ${ejemplar.codigo}?',
      descripcion: 'La copia se quitará del inventario. Esta acción no se puede deshacer.',
    );
    if (!confirmado || !mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await eliminarEjemplar(ejemplar.codigo);
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ejemplar eliminado: ${ejemplar.codigo}.')));
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
      appBar: AppBar(title: const Text('Ejemplares')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
        children: [
          const EncabezadoPantalla(
            titulo: 'Eliminar ejemplar',
            descripcion: 'Busca la copia por su código y revisa toda su información antes de eliminarla.',
          ),
          BuscadorClave(
            controller: _codigo,
            etiqueta: 'Código del ejemplar',
            pista: 'EJ-020',
            onBuscar: _buscar,
            cargando: _cargando && _ejemplar == null,
          ),
          if (_sinResultado != null)
            EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
          if (_error != null)
            Aviso(_error!, titulo: _ejemplar != null ? 'El servidor no permitió eliminar el ejemplar' : 'No se pudo buscar el ejemplar'),
          if (_ejemplar != null) ...[
            FichaEjemplar(ejemplar: _ejemplar!, titulo: 'Ejemplar a eliminar'),
            const SizedBox(height: Espacio.e6),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kPeligro600),
              onPressed: _cargando ? null : _eliminar,
              icon: const Icon(LucideIcons.trash2, size: 18),
              label: const Text('Eliminar ejemplar'),
            ),
            const SizedBox(height: Espacio.e2),
            OutlinedButton(
              onPressed: () => setState(() {
                _ejemplar = null;
                _error = null;
              }),
              child: const Text('Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}
