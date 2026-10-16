import 'package:flutter/material.dart';

class AcercaDe extends StatelessWidget {
  const AcercaDe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de...')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplicación: Sistema de gestión de Librería (Cliente Móvil)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Versión: 1.0.0'),
            SizedBox(height: 8),
            Text('Curso: Diseño de Soluciones — Universidad de Ibagué — Segundo Proyecto 2026B'),
            SizedBox(height: 16),
            Text('Integrantes del equipo:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Misael Gallo Tangarife'),
            Text('• Sara Zambrano'),
            Text('• Santiago Guimel'),
            Text('• Alejandra González'),
          ],
        ),
      ),
    );
  }
}
