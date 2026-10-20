import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tema/tema.dart';

/// Un caso de uso por opción (mismo orden y nombres que el cliente web).
const _casosDeUso = [
  (ruta: 'listar', texto: 'Listar', icono: LucideIcons.list),
  (ruta: 'consultar', texto: 'Consultar', icono: LucideIcons.search),
  (ruta: 'agregar', texto: 'Adicionar', icono: LucideIcons.plus),
  (ruta: 'actualizar', texto: 'Actualizar', icono: LucideIcons.pencil),
  (ruta: 'eliminar', texto: 'Eliminar', icono: LucideIcons.trash2),
];

/// Las rutas en el mismo orden que los destinos del menú.
final List<String> _rutas = [
  for (final c in _casosDeUso) '/libros/${c.ruta}',
  for (final c in _casosDeUso) '/ejemplares/${c.ruta}',
  '/acerca-de',
];

/// Menú principal (NavigationDrawer de Material 3), el equivalente al menú de la ventana
/// principal de una aplicación de escritorio: cada opción abre la pantalla de un único caso
/// de uso, y la sección "Ayuda" tiene "Acerca de...".
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    Widget seccion(String texto) => Padding(
      padding: const EdgeInsets.fromLTRB(28, Espacio.e4, 16, Espacio.e2),
      child: Text(texto, style: textos.labelSmall!.copyWith(color: kGris500, fontWeight: FontWeight.w600)),
    );
    NavigationDrawerDestination destino(String texto, IconData icono) =>
        NavigationDrawerDestination(icon: Icon(icono), label: Text(texto));

    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (indice) {
        Navigator.pop(context); // cierra el menú
        Navigator.pushNamed(context, _rutas[indice]);
      },
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, Espacio.e6, 16, Espacio.e2),
          child: Marca(),
        ),
        seccion('Libros'),
        for (final c in _casosDeUso) destino(c.texto, c.icono),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: Espacio.e2), child: Divider()),
        seccion('Ejemplares'),
        for (final c in _casosDeUso) destino(c.texto, c.icono),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: Espacio.e2), child: Divider()),
        seccion('Ayuda'),
        destino('Acerca de...', LucideIcons.info),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, Espacio.e6, 16, Espacio.e4),
          child: Text('Versión 1.0.0', style: textos.bodySmall!.copyWith(color: kGris500)),
        ),
      ],
    );
  }
}

/// Logotipo: ícono + nombre en Literata (igual que en el cliente web).
class Marca extends StatelessWidget {
  const Marca({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: kMarca600, borderRadius: Radios.control),
          child: const Icon(LucideIcons.library, size: 16, color: kGris0),
        ),
        const SizedBox(width: Espacio.e2),
        const Text(
          'Librería',
          style: TextStyle(fontFamily: fuenteLibro, fontSize: 18, fontWeight: FontWeight.w600, color: kGris900),
        ),
      ],
    );
  }
}
