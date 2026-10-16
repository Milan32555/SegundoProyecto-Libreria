import 'package:flutter/material.dart';

import '../tema/tema.dart';
import 'comunes/componentes.dart';

const _integrantes = ['Misael Gallo Tangarife', 'Sara Zambrano', 'Santiago Guimel', 'Alejandra González'];

/// Ayuda → Acerca de...: integrantes del equipo y versión de la aplicación.
class AcercaDe extends StatelessWidget {
  const AcercaDe({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de...')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Espacio.md, Espacio.sm, Espacio.md, Espacio.xl),
        children: [
          TarjetaHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconoAcento(Icons.local_library_rounded, tamano: 60),
                const SizedBox(height: Espacio.md),
                Text('Librería', style: texto.displaySmall),
                const SizedBox(height: Espacio.xs),
                Text('Sistema de gestión de libros y ejemplares.', style: texto.bodyMedium),
                const SizedBox(height: Espacio.md),
                const Wrap(
                  spacing: Espacio.sm,
                  runSpacing: Espacio.sm,
                  children: [
                    Pastilla('Versión 1.0.0'),
                    Pastilla('Cliente móvil · Flutter', color: kAzul),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Espacio.lg),
          const EtiquetaSeccion('Integrantes del equipo'),
          const SizedBox(height: Espacio.sm),
          Card(
            child: Column(
              children: [
                for (final (i, nombre) in _integrantes.indexed) ...[
                  if (i > 0) const Divider(indent: 72),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kAcento.withValues(alpha: 0.15),
                      foregroundColor: kAcento,
                      child: Text(_iniciales(nombre), style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Espacio.lg),
          const EtiquetaSeccion('Curso'),
          const SizedBox(height: Espacio.sm),
          const Card(
            child: ListTile(
              leading: Icon(Icons.school_rounded),
              title: Text('Diseño de Soluciones', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Universidad de Ibagué · Segundo Proyecto 2026B'),
            ),
          ),
          const SizedBox(height: Espacio.lg),
          const EtiquetaSeccion('Arquitectura'),
          const SizedBox(height: Espacio.sm),
          const Card(
            child: ListTile(
              leading: Icon(Icons.hub_rounded),
              title: Text('Servidor GraphQL · Java Spring Boot', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Clientes: React (web) y Flutter (móvil)'),
            ),
          ),
        ],
      ),
    );
  }

  static String _iniciales(String nombre) =>
      nombre.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
}
