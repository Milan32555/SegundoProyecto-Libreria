/**
 * Patrón Observer (del lado del cliente): un "sujeto" al que distintas pantallas
 * se suscriben para enterarse cuando la colección cambió en el servidor.
 *
 * Las pantallas de Agregar/Actualizar/Eliminar llaman a `notificar()` después de
 * una mutación exitosa; la pantalla de Listar se suscribe en un useEffect y
 * vuelve a consultar el servidor automáticamente cuando es notificada, sin que
 * el usuario tenga que refrescar manualmente.
 */
export type Observador = () => void;

export class ListadoObservable {
  private observadores: Observador[] = [];

  suscribir(observador: Observador): () => void {
    this.observadores.push(observador);
    // Devuelve una función para desuscribirse (usada en el cleanup de useEffect).
    return () => {
      this.observadores = this.observadores.filter((o) => o !== observador);
    };
  }

  notificar(): void {
    this.observadores.forEach((observador) => observador());
  }
}

// Un sujeto observable por cada colección (maestro y detalle).
export const libroObservable = new ListadoObservable();
export const ejemplarObservable = new ListadoObservable();
