import 'package:intl/intl.dart';

final DateFormat _formatoFecha = DateFormat('dd/MM/yyyy');
final DateFormat _formatoFechaHora = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _formatoServidor = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
final NumberFormat _formatoPrecio = NumberFormat('#,##0.##', 'es');

/// Fecha elegida en la app, en formato legible (dd/MM/yyyy).
String formatearFecha(DateTime fecha) => _formatoFecha.format(fecha);

/// Fecha ISO que envía el servidor (1967-05-30T00:00:00) en formato legible.
String formatearFechaIso(String iso) {
  final fecha = DateTime.tryParse(iso);
  return fecha == null ? iso : _formatoFechaHora.format(fecha);
}

/// Fecha en el formato ISO-8601 que espera el escalar LocalDateTime del servidor.
String aFechaServidor(DateTime fecha) => _formatoServidor.format(fecha);

String formatearPrecio(double valor) => '\$ ${_formatoPrecio.format(valor)}';
