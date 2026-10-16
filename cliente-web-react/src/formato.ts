const formatoPrecio = new Intl.NumberFormat("es-CO", {
  style: "currency",
  currency: "COP",
  maximumFractionDigits: 2
});

export function formatearPrecio(valor: number): string {
  return formatoPrecio.format(valor);
}

/** Fecha ISO del servidor (2024-05-10T14:30:00) en formato legible para el usuario. */
export function formatearFecha(iso: string): string {
  const fecha = new Date(iso);
  if (Number.isNaN(fecha.getTime())) {
    return iso;
  }
  return fecha.toLocaleString("es-CO", { dateStyle: "medium", timeStyle: "short" });
}

/** Fecha ISO del servidor en el formato que espera <input type="datetime-local">. */
export function aValorDeInputFecha(iso: string): string {
  return iso.slice(0, 16);
}
