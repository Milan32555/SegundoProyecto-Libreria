import 'package:flutter/material.dart';

import '../../utilidades/formato.dart';

/// Campo para elegir una fecha con el calendario de Material (no permite fechas futuras).
class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
  });

  final String etiqueta;
  final DateTime? valor;
  final ValueChanged<DateTime> alCambiar;

  Future<void> _elegir(BuildContext context) async {
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(etiqueta),
      subtitle: Text(valor == null ? '(sin elegir)' : formatearFecha(valor!)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _elegir(context),
    );
  }
}
