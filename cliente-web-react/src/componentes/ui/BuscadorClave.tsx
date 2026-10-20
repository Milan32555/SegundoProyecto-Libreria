import { FormEvent, ReactNode, useState } from "react";
import { Search } from "lucide-react";
import { Boton } from "./Boton";
import { Campo } from "./Campo";
import { validarObligatorio } from "../../validaciones";

/**
 * Buscar un objeto por su clave (ISBN o código) antes de actuar sobre él: lo usan Consultar,
 * Actualizar y Eliminar. Valida que el campo no esté vacío y llama a `alBuscar` con el valor.
 */
export function BuscadorClave({ etiqueta, placeholder, cargando, alBuscar, antes, valorInicial = "" }: {
  etiqueta: string;
  placeholder?: string;
  cargando: boolean;
  alBuscar: (valor: string) => void;
  /** Controles adicionales antes del campo (p. ej. el criterio de búsqueda). */
  antes?: ReactNode;
  valorInicial?: string;
}) {
  const [valor, setValor] = useState(valorInicial);
  const [error, setError] = useState<string | null>(null);

  function buscar(e: FormEvent) {
    e.preventDefault();
    const problema = validarObligatorio(valor);
    setError(problema);
    if (!problema) alBuscar(valor.trim());
  }

  return (
    <form className="panel barra-filtros" role="search" onSubmit={buscar} noValidate>
      {antes}
      <Campo
        className="campo-busqueda"
        etiqueta={etiqueta}
        value={valor}
        onChange={(e) => { setValor(e.target.value); setError(null); }}
        placeholder={placeholder}
        error={error}
        autoComplete="off"
      />
      <Boton type="submit" variante="primario" icono={Search} cargando={cargando}>Buscar</Boton>
    </form>
  );
}
