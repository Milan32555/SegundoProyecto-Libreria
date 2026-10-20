import { ReactNode, createContext, useCallback, useContext, useState } from "react";
import * as Toast from "@radix-ui/react-toast";
import { CircleCheck, X } from "lucide-react";

export interface Aviso {
  titulo: string;
  descripcion?: string;
}

type MostrarAviso = (aviso: Aviso) => void;

const ContextoAvisos = createContext<MostrarAviso>(() => {});

let siguienteId = 0;

/**
 * Avisos breves (toasts de Radix) para confirmar que una operación terminó bien.
 * Los errores no van aquí: se muestran en la página, junto al formulario, para que no se pierdan.
 */
export function ProveedorAvisos({ children }: { children: ReactNode }) {
  const [avisos, setAvisos] = useState<(Aviso & { id: number })[]>([]);

  const mostrar = useCallback<MostrarAviso>((aviso) => {
    siguienteId += 1;
    setAvisos((lista) => [...lista, { ...aviso, id: siguienteId }]);
  }, []);

  const quitar = (id: number) => setAvisos((lista) => lista.filter((a) => a.id !== id));

  return (
    <Toast.Provider duration={5000} label="Notificación">
      <ContextoAvisos.Provider value={mostrar}>{children}</ContextoAvisos.Provider>
      {avisos.map((aviso) => (
        <Toast.Root key={aviso.id} className="aviso" onOpenChange={(abierto) => !abierto && quitar(aviso.id)}>
          <CircleCheck size={18} aria-hidden="true" />
          <div className="aviso-texto">
            <Toast.Title className="aviso-titulo">{aviso.titulo}</Toast.Title>
            {aviso.descripcion && <Toast.Description className="aviso-descripcion">{aviso.descripcion}</Toast.Description>}
          </div>
          <Toast.Close className="aviso-cerrar" aria-label="Cerrar aviso">
            <X size={16} aria-hidden="true" />
          </Toast.Close>
        </Toast.Root>
      ))}
      <Toast.Viewport className="avisos-viewport" />
    </Toast.Provider>
  );
}

/** Devuelve la función para mostrar un aviso: `const avisar = useAvisos(); avisar({ titulo })`. */
export function useAvisos(): MostrarAviso {
  return useContext(ContextoAvisos);
}
