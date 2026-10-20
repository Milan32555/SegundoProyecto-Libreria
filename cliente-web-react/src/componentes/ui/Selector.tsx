import { useId } from "react";
import * as Select from "@radix-ui/react-select";
import { Check, ChevronDown } from "lucide-react";
import { clases } from "./clases";

/** Radix no admite una opción con valor vacío: "todos" se representa con este valor interno. */
const VALOR_TODOS = "__todos__";

export interface OpcionSelector<T extends string> {
  valor: T | "";
  texto: string;
}

interface SelectorProps<T extends string> {
  etiqueta: string;
  valor: T | "";
  opciones: readonly OpcionSelector<T>[];
  alCambiar: (valor: T | "") => void;
  ancho?: boolean;
  className?: string;
}

/** Lista desplegable accesible (Radix Select) con la misma apariencia que los campos. */
export function Selector<T extends string>({ etiqueta, valor, opciones, alCambiar, ancho = false, className }: SelectorProps<T>) {
  const id = useId();
  return (
    <div className={clases("campo", ancho && "campo-ancho", className)}>
      <label htmlFor={id}>{etiqueta}</label>
      <Select.Root
        value={valor === "" ? VALOR_TODOS : valor}
        onValueChange={(nuevo) => alCambiar(nuevo === VALOR_TODOS ? "" : (nuevo as T))}
      >
        <Select.Trigger id={id} className="select-disparador">
          <Select.Value />
          <Select.Icon asChild>
            <ChevronDown size={16} aria-hidden="true" />
          </Select.Icon>
        </Select.Trigger>
        <Select.Portal>
          <Select.Content className="select-contenido" position="popper" sideOffset={4}>
            <Select.Viewport className="select-lista">
              {opciones.map((opcion) => (
                <Select.Item key={opcion.valor || VALOR_TODOS} value={opcion.valor || VALOR_TODOS} className="select-opcion">
                  <Select.ItemText>{opcion.texto}</Select.ItemText>
                  <Select.ItemIndicator>
                    <Check size={14} aria-hidden="true" />
                  </Select.ItemIndicator>
                </Select.Item>
              ))}
            </Select.Viewport>
          </Select.Content>
        </Select.Portal>
      </Select.Root>
    </div>
  );
}
