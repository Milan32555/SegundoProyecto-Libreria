import { ReactNode } from "react";
import { CircleAlert, CircleCheck, Info, TriangleAlert } from "lucide-react";
import { clases } from "./clases";

type Tono = "critico" | "aviso" | "exito" | "info";

const ICONOS = { critico: CircleAlert, aviso: TriangleAlert, exito: CircleCheck, info: Info } as const;

/** Mensaje dentro de la página: errores del servidor, advertencias o resultados. */
export function Banner({ tono = "critico", titulo, children, accion, className }: {
  tono?: Tono;
  titulo?: string;
  children?: ReactNode;
  accion?: ReactNode;
  className?: string;
}) {
  const Icono = ICONOS[tono];
  return (
    <div className={clases("banner", `banner-${tono}`, className)} role={tono === "critico" ? "alert" : "status"}>
      <Icono size={18} aria-hidden="true" />
      <div className="banner-texto">
        {titulo && <p className="banner-titulo">{titulo}</p>}
        {children && <p>{children}</p>}
      </div>
      {accion}
    </div>
  );
}
