import 'package:flutter/material.dart';

import 'pantallas/menu_principal.dart';
import 'pantallas/acerca_de.dart';

import 'pantallas/libro/agregar_libro.dart';
import 'pantallas/libro/actualizar_libro.dart';
import 'pantallas/libro/eliminar_libro.dart';
import 'pantallas/libro/listar_libros.dart';
import 'pantallas/libro/consultar_libro.dart';

import 'pantallas/ejemplar/agregar_ejemplar.dart';
import 'pantallas/ejemplar/actualizar_ejemplar.dart';
import 'pantallas/ejemplar/eliminar_ejemplar.dart';
import 'pantallas/ejemplar/listar_ejemplares.dart';
import 'pantallas/ejemplar/consultar_ejemplar.dart';

void main() {
  runApp(const AplicacionLibreria());
}

class AplicacionLibreria extends StatelessWidget {
  const AplicacionLibreria({super.key, this.rutaInicial = '/'});

  /// Pantalla con la que abre la app (las pruebas la usan para ir directo a un caso de uso).
  final String rutaInicial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Librería',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3A5BD9),
        useMaterial3: true,
      ),
      initialRoute: rutaInicial,
      routes: {
        '/': (context) => const MenuPrincipal(),
        '/acerca-de': (context) => const AcercaDe(),

        '/libros/agregar': (context) => const AgregarLibro(),
        '/libros/actualizar': (context) => const ActualizarLibro(),
        '/libros/eliminar': (context) => const EliminarLibro(),
        '/libros/listar': (context) => const ListarLibros(),
        '/libros/consultar': (context) => const ConsultarLibro(),

        '/ejemplares/agregar': (context) => const AgregarEjemplar(),
        '/ejemplares/actualizar': (context) => const ActualizarEjemplar(),
        '/ejemplares/eliminar': (context) => const EliminarEjemplar(),
        '/ejemplares/listar': (context) => const ListarEjemplares(),
        '/ejemplares/consultar': (context) => const ConsultarEjemplar(),
      },
    );
  }
}
