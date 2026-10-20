import { APIRequestContext, Page, TestInfo, expect } from "@playwright/test";
import path from "node:path";
import { fileURLToPath } from "node:url";

const AQUI = path.dirname(fileURLToPath(import.meta.url));

export const URL_GRAPHQL = "http://localhost:8081/graphql";

/** Carpeta de capturas (fuera del repositorio). Se puede cambiar con CAPTURAS_DIR. */
const CAPTURAS = process.env.CAPTURAS_DIR ?? path.resolve(AQUI, "../../../Capturas-SegundoProyecto-Libreria/web");

/** Guarda una captura de la pantalla actual: <capturas>/<escritorio|celular>/<nombre>.png */
export async function capturar(page: Page, info: TestInfo, nombre: string, completa = false) {
  await page.waitForTimeout(250); // deja terminar transiciones cortas (avisos, diálogos)
  await page.screenshot({ path: path.join(CAPTURAS, info.project.name, `${nombre}.png`), fullPage: completa });
}

/** Consulta directa al servidor (para preparar datos y verificar lo que quedó guardado). */
export async function graphql<T = Record<string, unknown>>(
  request: APIRequestContext,
  query: string,
  variables: Record<string, unknown> = {}
): Promise<T> {
  const respuesta = await request.post(URL_GRAPHQL, { data: { query, variables }, headers: { "X-Cliente": "e2e" } });
  const cuerpo = await respuesta.json();
  if (cuerpo.errors?.length) throw new Error(cuerpo.errors[0].message);
  return cuerpo.data as T;
}

/** Sufijo único por prueba y proyecto, para que las pruebas no choquen entre sí. */
export function unico(info: TestInfo): string {
  return `${info.project.name === "celular" ? "C" : "E"}${Date.now().toString().slice(-7)}`;
}

export async function crearLibro(request: APIRequestContext, isbn: string, titulo = "Libro de prueba E2E") {
  await graphql(request, `mutation ($input: LibroInput!) { crearLibro(input: $input) { isbn } }`, {
    input: {
      isbn, titulo, autor: "Autora E2E", precio: 50000, numeroPaginas: 200,
      fechaPublicacion: "2020-05-10T08:30:00", genero: "FICCION"
    }
  });
}

export async function crearEjemplar(request: APIRequestContext, codigo: string, isbnLibro: string, prestamos = 4) {
  await graphql(request, `mutation ($input: EjemplarInput!) { crearEjemplar(input: $input) { codigo } }`, {
    input: {
      codigo, estado: "DISPONIBLE", ubicacion: "Estante E2E", fechaIngreso: "2025-01-15T10:20:00",
      precioReposicion: 40000, numeroPrestamos: prestamos, isbnLibro
    }
  });
}

/** Abre el menú principal: lateral en escritorio, cajón en celular. */
export async function abrirMenu(page: Page) {
  const boton = page.getByRole("button", { name: "Abrir menú" });
  if (await boton.isVisible()) {
    await boton.click();
    return page.getByRole("dialog").getByRole("navigation", { name: "Menú principal" });
  }
  return page.getByRole("navigation", { name: "Menú principal" });
}

/** Elige una opción de una lista desplegable (Radix Select). */
export async function elegir(page: Page, etiqueta: string, opcion: string) {
  await page.getByRole("combobox", { name: etiqueta }).click();
  await page.getByRole("option", { name: opcion, exact: true }).click();
}

/** Espera el aviso (toast) con ese título. */
export async function esperarAviso(page: Page, titulo: string) {
  await expect(page.getByText(titulo, { exact: true })).toBeVisible();
}
