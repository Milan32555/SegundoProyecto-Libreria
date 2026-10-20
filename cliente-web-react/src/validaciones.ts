/**
 * Validaciones de FORMATO de los formularios: devuelven el mensaje para mostrar debajo del campo,
 * o null si el valor sirve. Son las mismas de la app móvil (lib/utilidades/validaciones.dart).
 *
 * Las reglas de negocio (ISBN único, fecha no futura, libro con ejemplares…) las decide el
 * servidor; esto solo evita enviar un formulario incompleto.
 */
export function validarObligatorio(valor: string): string | null {
  return valor.trim() === "" ? "Este campo es obligatorio." : null;
}

export function validarDecimalPositivo(valor: string): string | null {
  if (valor.trim() === "") return "Este campo es obligatorio.";
  const numero = Number(valor);
  if (Number.isNaN(numero)) return "Escribe un número válido.";
  return numero > 0 ? null : "Debe ser mayor que cero.";
}

export function validarEnteroPositivo(valor: string): string | null {
  if (valor.trim() === "") return "Este campo es obligatorio.";
  const numero = Number(valor);
  if (!Number.isInteger(numero)) return "Escribe un número entero.";
  return numero > 0 ? null : "Debe ser mayor que cero.";
}

export function validarEnteroNoNegativo(valor: string): string | null {
  if (valor.trim() === "") return "Este campo es obligatorio.";
  const numero = Number(valor);
  if (!Number.isInteger(numero)) return "Escribe un número entero.";
  return numero >= 0 ? null : "No puede ser negativo.";
}

export function validarFecha(valor: string): string | null {
  return valor.trim() === "" ? "Elige la fecha y la hora." : null;
}

export type Errores<K extends string> = Partial<Record<K, string>>;

/** Aplica cada validador a su campo y devuelve solo los campos con error. */
export function validar<K extends string>(reglas: Record<K, string | null>): Errores<K> {
  const errores: Errores<K> = {};
  for (const campo of Object.keys(reglas) as K[]) {
    const mensaje = reglas[campo];
    if (mensaje) errores[campo] = mensaje;
  }
  return errores;
}

export function hayErrores<K extends string>(errores: Errores<K>): boolean {
  return Object.keys(errores).length > 0;
}
