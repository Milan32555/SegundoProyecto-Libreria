import { ReactNode, useState } from "react";
import * as Dialog from "@radix-ui/react-dialog";
import { Menu, X } from "lucide-react";
import Navegacion, { Marca, PieMenu } from "./Navegacion";
import { Boton } from "./ui/Boton";

/**
 * Estructura de todas las pantallas: menú lateral fijo a la izquierda y el contenido a la
 * derecha. En pantallas angostas el menú se abre como un cajón (Radix Dialog) desde la barra superior.
 */
export default function Estructura({ children }: { children: ReactNode }) {
  const [menuAbierto, setMenuAbierto] = useState(false);
  const cerrar = () => setMenuAbierto(false);

  return (
    <div className="app">
      <a className="saltar-contenido" href="#contenido">Saltar al contenido</a>

      <aside className="menu-lateral">
        <Marca />
        <Navegacion />
        <PieMenu />
      </aside>

      <div className="contenido">
        <header className="barra-movil">
          <Dialog.Root open={menuAbierto} onOpenChange={setMenuAbierto}>
            <Dialog.Trigger asChild>
              <Boton variante="fantasma" className="boton-icono" aria-label="Abrir menú">
                <Menu size={20} aria-hidden="true" />
              </Boton>
            </Dialog.Trigger>
            <Dialog.Portal>
              <Dialog.Overlay className="cajon-fondo" />
              <Dialog.Content className="cajon" aria-describedby={undefined}>
                <div className="cajon-cabecera">
                  <Dialog.Title asChild>
                    <div><Marca alNavegar={cerrar} /></div>
                  </Dialog.Title>
                  <Dialog.Close asChild>
                    <Boton variante="fantasma" className="boton-icono" aria-label="Cerrar menú">
                      <X size={20} aria-hidden="true" />
                    </Boton>
                  </Dialog.Close>
                </div>
                <Navegacion prefijo="cajon" alNavegar={cerrar} />
                <PieMenu />
              </Dialog.Content>
            </Dialog.Portal>
          </Dialog.Root>
          <Marca />
        </header>

        <main id="contenido" className="pagina" tabIndex={-1}>
          {children}
        </main>
      </div>
    </div>
  );
}
