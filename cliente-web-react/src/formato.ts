const formatoPrecio = new Intl.NumberFormat("es-CO", {
  style: "currency",
  currency: "COP",
  maximumFractionDigits: 2
});

export function formatearPrecio(valor: number): string {
  return formatoPrecio.format(valor);
}

const formatoFecha = new Intl.DateTimeFormat("es-CO", { day: "2-digit", month: "2-digit", year: "numeric" });
const formatoFechaHora = new Intl.DateTimeFormat("es-CO", {
  day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false
});

/** Fecha y hora ISO del servidor (2024-05-10T14:30:00) en formato legible: 10/05/2024, 14:30. */
export function formatearFecha(iso: string): string {
  const fecha = new Date(iso);
  return Number.isNaN(fecha.getTime()) ? iso : formatoFechaHora.format(fecha);
}

/** Solo el día de una fecha ISO del servidor (para tablas): 10/05/2024. */
export function formatearFechaCorta(iso: string): string {
  const fecha = new Date(iso);
  return Number.isNaN(fecha.getTime()) ? iso : formatoFecha.format(fecha);
}

/** Fecha ISO del servidor en el formato que espera <input type="datetime-local">. */
export function aValorDeInputFecha(iso: string): string {
  return iso.slice(0, 16);
}

const DIAS = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
const MESES = [
  "enero", "febrero", "marzo", "abril", "mayo", "junio",
  "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
];

/** Fecha larga en español para encabezados: "Sábado, 17 de octubre". */
export function formatearFechaLarga(fecha: Date): string {
  return `${DIAS[fecha.getDay()]}, ${fecha.getDate()} de ${MESES[fecha.getMonth()]}`;
}

/** Saludo según la hora del día. */
export function saludo(fecha: Date): string {
  const hora = fecha.getHours();
  if (hora >= 5 && hora < 12) return "Buenos días";
  if (hora >= 12 && hora < 19) return "Buenas tardes";
  return "Buenas noches";
}
