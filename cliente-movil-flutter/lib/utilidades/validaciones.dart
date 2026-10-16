/// Validadores de los formularios (devuelven el mensaje de error o null si el valor es válido).
/// El servidor vuelve a validar todo; esto solo le da al usuario una respuesta inmediata.
library;

String? validarObligatorio(String? valor) =>
    (valor == null || valor.trim().isEmpty) ? 'Obligatorio' : null;

String? validarDecimalPositivo(String? valor) {
  final numero = double.tryParse(valor?.trim() ?? '');
  if (numero == null) return 'Número inválido';
  return numero > 0 ? null : 'Debe ser mayor que cero';
}

String? validarEnteroPositivo(String? valor) {
  final numero = int.tryParse(valor?.trim() ?? '');
  if (numero == null) return 'Número entero inválido';
  return numero > 0 ? null : 'Debe ser mayor que cero';
}
