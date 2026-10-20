import 'package:intl/intl.dart';

final DateFormat _formatoFecha = DateFormat('dd/MM/yyyy');
final DateFormat _formatoFechaHora = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _formatoServidor = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
final NumberFormat _formatoPrecio = NumberFormat('#,##0.##', 'es');

/// Fecha elegida en la app, en formato legible (dd/MM/yyyy).
String formatearFecha(DateTime fecha) => _formatoFecha.format(fecha);

/// Fecha y hora elegidas en la app, en formato legible (dd/MM/yyyy HH:mm).
String formatearFechaHora(DateTime fecha) => _formatoFechaHora.format(fecha);

/// Fecha ISO que envía el servidor (1967-05-30T00:00:00) en formato legible.
String formatearFechaIso(String iso) {
  final fecha = DateTime.tryParse(iso);
  return fecha == null ? iso : _formatoFechaHora.format(fecha);
}

/// Solo el día de una fecha ISO del servidor (para tablas).
String formatearFechaCortaIso(String iso) {
  final fecha = DateTime.tryParse(iso);
  return fecha == null ? iso : _formatoFecha.format(fecha);
}

/// Fecha en el formato ISO-8601 que espera el escalar LocalDateTime del servidor.
String aFechaServidor(DateTime fecha) => _formatoServidor.format(fecha);

String formatearPrecio(double valor) => '\$ ${_formatoPrecio.format(valor)}';

const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Fecha larga en español para encabezados: "Viernes, 17 de octubre".
/// (Sin DateFormat con locale para no tener que inicializar los datos de idioma de intl.)
String formatearFechaLarga(DateTime fecha) => '${_dias[fecha.weekday - 1]}, ${fecha.day} de ${_meses[fecha.month - 1]}';
