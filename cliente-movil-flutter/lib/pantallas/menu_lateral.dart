import 'package:flutter/material.dart';

import '../tema/tema.dart';
import 'comunes/componentes.dart';

/// Menú lateral (Drawer), equivalente al menú de la ventana principal en un
/// cliente de escritorio: permite ir a cada caso de uso y tiene una sección
/// "Ayuda" con "Acerca de...".
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: Espacio.sm),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, Espacio.md, 20, 20),
              child: Row(
                children: [
                  IconoAcento(Icons.local_library_rounded, tamano: 48),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Librería',
                        style: TextStyle(color: kTexto, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      Text('Versión 1.0.0', style: TextStyle(color: kTexto3, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            const _Seccion('LIBRO'),
            ..._opciones(context, '/libros'),
            const Divider(),
            const _Seccion('EJEMPLAR'),
            ..._opciones(context, '/ejemplares'),
            const Divider(),
            const _Seccion('AYUDA'),
            _Opcion(icono: Icons.info_outline_rounded, titulo: 'Acerca de...', ruta: '/acerca-de'),
          ],
        ),
      ),
    );
  }

  List<Widget> _opciones(BuildContext context, String base) => [
    _Opcion(icono: Icons.add_rounded, titulo: 'Adicionar', ruta: '$base/agregar'),
    _Opcion(icono: Icons.delete_outline_rounded, titulo: 'Eliminar', ruta: '$base/eliminar'),
    _Opcion(icono: Icons.edit_rounded, titulo: 'Actualizar', ruta: '$base/actualizar'),
    _Opcion(icono: Icons.view_list_rounded, titulo: 'Listar', ruta: '$base/listar'),
    _Opcion(icono: Icons.search_rounded, titulo: 'Buscar por criterios', ruta: '$base/consultar'),
  ];
}

class _Seccion extends StatelessWidget {
  const _Seccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, Espacio.md, 20, Espacio.xs),
    child: Text(texto, style: estiloEtiqueta),
  );
}

class _Opcion extends StatelessWidget {
  const _Opcion({required this.icono, required this.titulo, required this.ruta});

  final IconData icono;
  final String titulo;
  final String ruta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        dense: true,
        shape: const RoundedRectangleBorder(borderRadius: Redondeo.campo),
        leading: Icon(icono, size: 22),
        title: Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        onTap: () {
          Navigator.pop(context); // cierra el Drawer
          Navigator.pushNamed(context, ruta);
        },
      ),
    );
  }
}
