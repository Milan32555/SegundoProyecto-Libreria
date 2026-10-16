import 'package:flutter/material.dart';
import 'menu_lateral.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Librería')),
      drawer: const MenuLateral(),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Sistema de gestión de Librería.\n\n'
          'Usa el menú (ícono ☰ arriba a la izquierda) para ir a cada funcionalidad: '
          'Libro (el objeto maestro) y Ejemplar (el objeto detalle, los ejemplares '
          'físicos de cada libro en inventario). Cada opción abre una pantalla '
          'dedicada a un único caso de uso.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
