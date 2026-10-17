import { useEffect, useRef, useState } from "react";

const DURACION_MS = 1100;

function sinAnimaciones(): boolean {
  return typeof window.matchMedia !== "function" || window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}

/**
 * Número que "cuenta" desde su valor anterior hasta [objetivo] (como en la app móvil).
 * Si el usuario pidió reducir el movimiento (o no hay matchMedia, como en las pruebas),
 * muestra el valor final directamente.
 */
export function useContador(objetivo: number | null): number | null {
  const [valor, setValor] = useState<number | null>(objetivo);
  const anterior = useRef(0);

  useEffect(() => {
    if (objetivo === null) return;
    if (sinAnimaciones()) {
      setValor(objetivo);
      anterior.current = objetivo;
      return;
    }
    const desde = anterior.current;
    const inicio = performance.now();
    let cuadro = 0;
    const avanzar = (ahora: number) => {
      const t = Math.min((ahora - inicio) / DURACION_MS, 1);
      const suavizado = 1 - Math.pow(1 - t, 3);
      setValor(Math.round(desde + (objetivo - desde) * suavizado));
      if (t < 1) cuadro = requestAnimationFrame(avanzar);
      else anterior.current = objetivo;
    };
    cuadro = requestAnimationFrame(avanzar);
    return () => cancelAnimationFrame(cuadro);
  }, [objetivo]);

  return valor;
}
