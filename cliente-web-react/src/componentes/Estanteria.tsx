import { CSSProperties } from "react";

const COLORES = ["#f2e6cc", "#c9973f", "#8e3b36", "#2f4a6b", "#3f8a6b", "#d9c7a3", "#5b3a29"];

interface Lomo {
  ancho: number;
  alto: number;
  color: string;
  bandas: boolean;
  hueco: number;
}

/** Generador pseudoaleatorio con semilla (mulberry32): siempre la misma estantería. */
function generador(semilla: number) {
  let estado = semilla;
  return () => {
    estado = (estado + 0x6d2b79f5) | 0;
    let t = Math.imul(estado ^ (estado >>> 15), 1 | estado);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Suficientes libros para llenar el ancho de la página; lo que sobra queda oculto.
const LOMOS: Lomo[] = (() => {
  const azar = generador(7);
  return Array.from({ length: 70 }, () => ({
    ancho: 12 + azar() * 14,
    alto: 50 + azar() * 50,
    color: COLORES[Math.floor(azar() * COLORES.length)],
    bandas: azar() < 0.45,
    hueco: azar() < 0.12 ? 10 : 2.5
  }));
})();

/**
 * Estantería dibujada con lomos de libros (la misma idea de la app móvil). Se usa sobre los
 * fondos verdes del inicio y de "Acerca de...". Los libros "crecen" uno tras otro al aparecer.
 */
export default function Estanteria() {
  return (
    <div className="estanteria" aria-hidden="true">
      <div className="estanteria-libros">
        {LOMOS.map((lomo, i) => (
          <span
            key={i}
            className={lomo.bandas ? "lomo lomo-bandas" : "lomo"}
            style={{
              width: lomo.ancho,
              height: `${lomo.alto}%`,
              marginRight: lomo.hueco,
              backgroundColor: lomo.color,
              "--i": i
            } as CSSProperties}
          />
        ))}
      </div>
    </div>
  );
}
