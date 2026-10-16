import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../observador/listado_observable.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Eliminar Ejemplar. Primero se busca y se muestra TODA su información;
/// solo después de confirmar se elimina.
class EliminarEjemplar extends StatefulWidget {
  const EliminarEjemplar({super.key});

  @override
  State<EliminarEjemplar> createState() => _EliminarEjemplarState();
}

class _EliminarEjemplarState extends State<EliminarEjemplar> {
  final _codigo = TextEditingController();
  Ejemplar? _ejemplar;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
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
      final resultado = await buscarEjemplarPorCodigo(_codigo.text);
      if (!mounted) return;
      setState(() {
        _ejemplar = resultado;
        if (resultado == null) _error = 'No se encontró ningún ejemplar con ese código.';
      });
    } on ErrorGraphQL catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    if (_ejemplar == null) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final eliminado = await eliminarEjemplar(_ejemplar!.codigo);
      ejemplarObservable.notificar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ejemplar "${eliminado.codigo}" eliminado correctamente.')));
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
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          const EncabezadoPantalla(
            etiqueta: 'Ejemplar',
            titulo: 'Eliminar ejemplar',
            descripcion: 'Busca el ejemplar por su código para revisar toda su información antes de eliminarlo.',
          ),
          BuscadorClave(
            controller: _codigo,
            etiqueta: 'Código del ejemplar a eliminar',
            icono: Icons.tag_rounded,
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_ejemplar == null && _error != null) Aviso(_error!),
          if (_ejemplar != null) ...[
            FichaEjemplar(ejemplar: _ejemplar!),
            const Aviso(
              '¿Seguro que desea eliminar este ejemplar? Esta acción no se puede deshacer.',
              tipo: TipoAviso.advertencia,
            ),
            if (_error != null) Aviso(_error!),
            const SizedBox(height: Espacio.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kRojo, foregroundColor: Colors.white),
              onPressed: _cargando ? null : _confirmarEliminacion,
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Confirmar eliminación'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => setState(() => _ejemplar = null), child: const Text('Cancelar')),
          ],
        ],
      ),
    );
  }
}
