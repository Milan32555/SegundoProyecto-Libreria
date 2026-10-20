import { ButtonHTMLAttributes, forwardRef } from "react";
import { Link, LinkProps } from "react-router-dom";
import { Loader2, LucideIcon } from "lucide-react";
import { clases } from "./clases";

export type VarianteBoton = "primario" | "secundario" | "peligro" | "fantasma";

interface BotonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variante?: VarianteBoton;
  icono?: LucideIcon;
  /** Muestra un indicador de carga y deshabilita el botón mientras espera al servidor. */
  cargando?: boolean;
}

/** Botón del sistema de diseño. `forwardRef` permite usarlo como disparador de Radix (asChild). */
export const Boton = forwardRef<HTMLButtonElement, BotonProps>(function Boton(
  { variante = "secundario", icono: Icono, cargando = false, className, children, disabled, type = "button", ...resto },
  ref
) {
  return (
    <button
      ref={ref}
      type={type}
      className={clases("boton", `boton-${variante}`, className)}
      disabled={disabled || cargando}
      aria-busy={cargando || undefined}
      {...resto}
    >
      {cargando ? (
        <Loader2 size={16} className="girando" aria-hidden="true" />
      ) : (
        Icono && <Icono size={16} aria-hidden="true" />
      )}
      {children}
    </button>
  );
});

interface BotonEnlaceProps extends LinkProps {
  variante?: VarianteBoton;
  icono?: LucideIcon;
}

/** Enlace con aspecto de botón (navega a otra pantalla, no ejecuta una acción). */
export function BotonEnlace({ variante = "secundario", icono: Icono, className, children, ...resto }: BotonEnlaceProps) {
  return (
    <Link className={clases("boton", `boton-${variante}`, className)} {...resto}>
      {Icono && <Icono size={16} aria-hidden="true" />}
      {children}
    </Link>
  );
}
