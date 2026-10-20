/// Validaciones de FORMATO de los formularios: devuelven el mensaje para mostrar debajo del
/// campo, o null si el valor sirve. Son las mismas del cliente web (src/validaciones.ts).
///
/// Las reglas de negocio (ISBN único, fecha no futura, libro con ejemplares…) las decide el
/// servidor; esto solo evita enviar un formulario incompleto.
library;

const _obligatorio = 'Este campo es obligatorio.';

String? validarObligatorio(String? valor) => (valor == null || valor.trim().isEmpty) ? _obligatorio : null;

String? validarDecimalPositivo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return _obligatorio;
  final numero = double.tryParse(texto);
  if (numero == null) return 'Escribe un número válido.';
  return numero > 0 ? null : 'Debe ser mayor que cero.';
}

String? validarEnteroPositivo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return _obligatorio;
  final numero = int.tryParse(texto);
  if (numero == null) return 'Escribe un número entero.';
  return numero > 0 ? null : 'Debe ser mayor que cero.';
}

String? validarEnteroNoNegativo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return _obligatorio;
  final numero = int.tryParse(texto);
  if (numero == null) return 'Escribe un número entero.';
  return numero >= 0 ? null : 'No puede ser negativo.';
}

String? validarFecha(DateTime? valor) => valor == null ? 'Elige la fecha y la hora.' : null;
