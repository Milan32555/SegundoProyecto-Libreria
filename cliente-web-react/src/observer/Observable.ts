import { consultarRevisionEjemplares } from "../graphql/servicioEjemplar";
import { consultarRevisionLibros } from "../graphql/servicioLibro";

/**
 * Patrón Observer (del lado del cliente): un "sujeto" al que se suscriben las
 * pantallas de Listar para enterarse de que la colección cambió.
 *
 * El sujeto avisa a sus observadores en dos casos:
 *  1. Una pantalla de este cliente (Adicionar/Actualizar/Eliminar) llama a `notificar()`
 *     después de una mutación exitosa.
 *  2. Mientras haya al menos un observador, el sujeto consulta cada pocos segundos el
 *     número de revisión de la colección en el servidor; si cambió (por ejemplo, otro
 *     cliente como la app Flutter agregó un libro), notifica a sus observadores.
 *
 * Así la pantalla de Listar se refresca sola, sin que el usuario pulse "refrescar".
 */
export type Observador = () => void;

export class ListadoObservable {
  private observadores: Observador[] = [];
  private temporizador: ReturnType<typeof setInterval> | null = null;
  private ultimaRevision: number | null = null;

  constructor(
    private readonly consultarRevision?: () => Promise<number>,
    private readonly intervaloMs = 3000
  ) {}

  /** Agrega un observador y devuelve la función para desuscribirlo (cleanup de useEffect). */
  suscribir(observador: Observador): () => void {
    this.observadores.push(observador);
    if (this.observadores.length === 1) {
      this.iniciarVigilancia();
    }
    return () => {
      this.observadores = this.observadores.filter((o) => o !== observador);
      if (this.observadores.length === 0) {
        this.detenerVigilancia();
      }
    };
  }

  notificar(): void {
    [...this.observadores].forEach((observador) => observador());
  }

  private iniciarVigilancia(): void {
    if (!this.consultarRevision) return;
    this.ultimaRevision = null;
    void this.revisarServidor();
    this.temporizador = setInterval(() => void this.revisarServidor(), this.intervaloMs);
  }

  private detenerVigilancia(): void {
    if (this.temporizador !== null) {
      clearInterval(this.temporizador);
      this.temporizador = null;
    }
  }

  private async revisarServidor(): Promise<void> {
    try {
      const revision = await this.consultarRevision!();
      const cambio = this.ultimaRevision !== null && revision !== this.ultimaRevision;
      this.ultimaRevision = revision;
      if (cambio) {
        this.notificar();
      }
    } catch {
      // Servidor no disponible por un momento: se vuelve a intentar en el siguiente ciclo.
    }
  }
}

// Un sujeto observable por cada colección (maestro y detalle).
export const libroObservable = new ListadoObservable(consultarRevisionLibros);
export const ejemplarObservable = new ListadoObservable(consultarRevisionEjemplares);
