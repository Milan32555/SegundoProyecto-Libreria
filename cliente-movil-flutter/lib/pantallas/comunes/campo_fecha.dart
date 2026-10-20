import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../utilidades/formato.dart';

/// Campo para elegir fecha Y hora con los selectores de Material (no permite días futuros).
/// Primero se elige el día y luego la hora (formato 24 h). Se ve igual que los demás campos y
/// muestra el error de validación debajo, como ellos.
class CampoFecha extends StatelessWidget {
  const CampoFecha({super.key, required this.etiqueta, required this.valor, required this.alCambiar, this.error});

  final String etiqueta;
  final DateTime? valor;
  final ValueChanged<DateTime> alCambiar;
  final String? error;

  Future<void> _elegir(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final hoy = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: valor ?? hoy,
      firstDate: DateTime(1000),
      lastDate: hoy,
      helpText: etiqueta,
    );
    if (dia == null || !context.mounted) return;

    final horaActual = valor == null ? const TimeOfDay(hour: 0, minute: 0) : TimeOfDay.fromDateTime(valor!);
    final hora = await showTimePicker(
      context: context,
      initialTime: horaActual,
      helpText: 'Hora',
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    // Si se cancela la hora, se conserva la que tenía (o 00:00 si el campo estaba vacío).
    final elegida = hora ?? horaActual;
    alCambiar(DateTime(dia.year, dia.month, dia.day, elegida.hour, elegida.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiqueta,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _elegir(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: etiqueta,
            prefixIcon: const Icon(LucideIcons.calendar, size: 18),
            suffixIcon: const Icon(LucideIcons.chevronDown, size: 18),
            errorText: error,
          ),
          isEmpty: valor == null,
          child: Text(valor == null ? '' : formatearFechaHora(valor!), style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
