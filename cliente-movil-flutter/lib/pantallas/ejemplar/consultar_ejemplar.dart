import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../modelos/ejemplar.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Consultar UN SOLO Ejemplar por su código.
class ConsultarEjemplar extends StatefulWidget {
  const ConsultarEjemplar({super.key});

  @override
  State<ConsultarEjemplar> createState() => _ConsultarEjemplarState();
}

class _ConsultarEjemplarState extends State<ConsultarEjemplar> {
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
      _ejemplar = null;
      _sinResultado = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplares')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.e4, Espacio.e4, Espacio.e4, Espacio.e8),
        children: [
          const EncabezadoPantalla(
            titulo: 'Consultar ejemplar',
            descripcion: 'Busca una copia por su código (sin importar mayúsculas).',
          ),
          BuscadorClave(
            controller: _codigo,
            etiqueta: 'Código del ejemplar',
            pista: 'EJ-001',
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_error != null) Aviso(_error!, titulo: 'No se pudo consultar'),
          if (_sinResultado != null)
            EstadoVacio(icono: LucideIcons.searchX, titulo: 'Sin resultados', descripcion: _sinResultado),
          if (_ejemplar != null) FichaEjemplar(ejemplar: _ejemplar!),
        ],
      ),
    );
  }
}
