import 'package:flutter/material.dart';

import '../../modelos/ejemplar.dart';
import '../../servicios/cliente_graphql.dart';
import '../../servicios/servicio_ejemplar.dart';
import '../../tema/tema.dart';
import '../comunes/componentes.dart';
import '../comunes/fichas.dart';

/// Caso de uso: Buscar/Consultar UN SOLO Ejemplar a partir de su código.
class ConsultarEjemplar extends StatefulWidget {
  const ConsultarEjemplar({super.key});

  @override
  State<ConsultarEjemplar> createState() => _ConsultarEjemplarState();
}

class _ConsultarEjemplarState extends State<ConsultarEjemplar> {
  final _codigo = TextEditingController();
  Ejemplar? _ejemplar;
  bool _buscado = false;
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
      _buscado = false;
    });
    try {
      final resultado = await buscarEjemplarPorCodigo(_codigo.text);
      if (!mounted) return;
      setState(() {
        _ejemplar = resultado;
        _buscado = true;
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
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          const EncabezadoPantalla(
            etiqueta: 'Ejemplar',
            titulo: 'Buscar un ejemplar',
            descripcion: 'Consulta un solo ejemplar por su código.',
          ),
          BuscadorClave(
            controller: _codigo,
            etiqueta: 'Código del ejemplar',
            icono: Icons.tag_rounded,
            onBuscar: _buscar,
            cargando: _cargando,
          ),
          if (_error != null) Aviso(_error!),
          if (_buscado && _ejemplar == null)
            const EstadoVacio(
              icono: Icons.search_off_rounded,
              mensaje: 'No se encontró ningún ejemplar con ese código.',
            ),
          if (_ejemplar != null) FichaEjemplar(ejemplar: _ejemplar!),
        ],
      ),
    );
  }
}
