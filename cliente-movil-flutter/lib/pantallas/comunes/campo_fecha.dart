import 'package:flutter/material.dart';

import '../../utilidades/formato.dart';

/// Campo para elegir una fecha con el calendario de Material (no permite fechas futuras).
/// Se ve igual que los demás campos del formulario.
class CampoFecha extends StatelessWidget {
  const CampoFecha({super.key, required this.etiqueta, required this.valor, required this.alCambiar});

  final String etiqueta;
  final DateTime? valor;
  final ValueChanged<DateTime> alCambiar;

  Future<void> _elegir(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: valor ?? hoy,
      firstDate: DateTime(1000),
      lastDate: hoy,
    );
    if (fecha != null) alCambiar(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _elegir(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: const Icon(Icons.event_rounded),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        isEmpty: valor == null,
        child: Text(valor == null ? '' : formatearFecha(valor!), style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
