import { ReactNode } from "react";
import * as AlertDialog from "@radix-ui/react-alert-dialog";
import { Trash2 } from "lucide-react";
import { Boton } from "./Boton";

interface ConfirmarEliminacionProps {
  /** Texto del botón que abre el diálogo, p. ej. "Eliminar libro". */
  textoBoton: string;
  titulo: string;
  descripcion: ReactNode;
  cargando?: boolean;
  alConfirmar: () => void;
}

/**
 * Botón de eliminar + diálogo de confirmación accesible (Radix AlertDialog): el foco queda
 * dentro del diálogo, Esc cancela y la acción destructiva no es la opción por defecto.
 */
export function ConfirmarEliminacion({ textoBoton, titulo, descripcion, cargando = false, alConfirmar }: ConfirmarEliminacionProps) {
  return (
    <AlertDialog.Root>
      <AlertDialog.Trigger asChild>
        <Boton variante="peligro" icono={Trash2} cargando={cargando}>{textoBoton}</Boton>
      </AlertDialog.Trigger>
      <AlertDialog.Portal>
        <AlertDialog.Overlay className="dialogo-fondo" />
        <AlertDialog.Content className="dialogo">
          <AlertDialog.Title className="dialogo-titulo">{titulo}</AlertDialog.Title>
          <AlertDialog.Description className="dialogo-descripcion">{descripcion}</AlertDialog.Description>
          <div className="acciones">
            <AlertDialog.Cancel asChild>
              <Boton>Cancelar</Boton>
            </AlertDialog.Cancel>
            <AlertDialog.Action asChild>
              <Boton variante="peligro" onClick={alConfirmar}>Eliminar</Boton>
            </AlertDialog.Action>
          </div>
        </AlertDialog.Content>
      </AlertDialog.Portal>
    </AlertDialog.Root>
  );
}
