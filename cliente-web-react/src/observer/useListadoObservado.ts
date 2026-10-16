import { useEffect, useRef } from "react";
import { ListadoObservable } from "./Observable";

/**
 * Conecta una pantalla de Listar con su sujeto observable:
 *  - ejecuta `cargar` al abrir la pantalla,
 *  - se suscribe como observador y vuelve a ejecutar `cargar` en cada notificación,
 *  - se desuscribe al salir de la pantalla (evita fugas de memoria).
 *
 * Siempre se invoca la versión más reciente de `cargar`, así que el refresco respeta
 * los filtros que el usuario tiene escritos en ese momento.
 * Con `cargarAlInicio: false` solo se suscribe (útil si la pantalla observa dos sujetos).
 */
export function useListadoObservado(
  observable: ListadoObservable,
  cargar: () => void,
  { cargarAlInicio = true }: { cargarAlInicio?: boolean } = {}
): void {
  const ultimaCarga = useRef(cargar);

  useEffect(() => {
    ultimaCarga.current = cargar;
  });

  useEffect(() => {
    if (cargarAlInicio) {
      ultimaCarga.current();
    }
    return observable.suscribir(() => ultimaCarga.current());
  }, [observable, cargarAlInicio]);
}
