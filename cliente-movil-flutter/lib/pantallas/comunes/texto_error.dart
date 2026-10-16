import 'package:flutter/material.dart';

/// Mensaje de error visible en la pantalla (validaciones del servidor, conexión, etc.).
class TextoError extends StatelessWidget {
  const TextoError(this.mensaje, {super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(mensaje, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}
