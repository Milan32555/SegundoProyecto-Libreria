import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../tema/tema.dart';

/// Hoja inferior (bottom sheet) para confirmar una eliminación. Devuelve true solo si el usuario
/// toca "Eliminar"; deslizarla hacia abajo o tocar "Cancelar" no elimina nada.
Future<bool> confirmarEliminacion(BuildContext context, {required String titulo, required String descripcion}) async {
  final confirmado = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      final textos = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Espacio.e4, 0, Espacio.e4, Espacio.e4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(LucideIcons.triangleAlert, color: kPeligro600, size: 24),
              const SizedBox(height: Espacio.e3),
              Text(titulo, textAlign: TextAlign.center, style: textos.titleMedium),
              const SizedBox(height: Espacio.e2),
              Text(descripcion, textAlign: TextAlign.center, style: textos.bodyMedium!.copyWith(color: kGris600)),
              const SizedBox(height: Espacio.e6),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kPeligro600),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
              const SizedBox(height: Espacio.e2),
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            ],
          ),
        ),
      );
    },
  );
  return confirmado ?? false;
}
