import { ClienteGraphQL } from "./clienteGraphQL";
import { ResumenInventario } from "../types";

/**
 * Resumen del inventario para la ventana principal: totales y ejemplares por estado.
 * Todo lo calcula el servidor; la pantalla solo lo muestra.
 */
export async function consultarResumenInventario(): Promise<ResumenInventario> {
  const data = await ClienteGraphQL.getInstancia().ejecutar<{ resumenInventario: ResumenInventario }>(
    `query {
       resumenInventario {
         totalLibros
         totalEjemplares
         ejemplaresPorEstado { estado cantidad porcentaje }
       }
     }`
  );
  return data.resumenInventario;
}
