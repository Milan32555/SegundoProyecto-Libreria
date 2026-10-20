import { ReactElement, ReactNode } from "react";
import * as Tooltip from "@radix-ui/react-tooltip";

/** Tooltip accesible (Radix): aparece al pasar el cursor o al enfocar con el teclado. */
export function Ayuda({ texto, children }: { texto: ReactNode; children: ReactElement }) {
  return (
    <Tooltip.Root>
      <Tooltip.Trigger asChild>{children}</Tooltip.Trigger>
      <Tooltip.Portal>
        <Tooltip.Content className="tooltip" sideOffset={6}>
          {texto}
        </Tooltip.Content>
      </Tooltip.Portal>
    </Tooltip.Root>
  );
}

export const ProveedorAyudas = Tooltip.Provider;
