/** Une nombres de clase CSS ignorando los vacíos: clases("boton", activo && "activo"). */
export function clases(...nombres: (string | false | null | undefined)[]): string {
  return nombres.filter(Boolean).join(" ");
}
