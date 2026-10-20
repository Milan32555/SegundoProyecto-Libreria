import { expect, test } from "@playwright/test";
import {
  abrirMenu, capturar, crearEjemplar, crearLibro, elegir, esperarAviso, graphql, unico
} from "./utilidades";

// Recorre TODOS los casos de uso de Libro y de Ejemplar contra el servidor real.
// Cada prueba crea sus propios datos (con un sufijo único) o solo lee los datos de prueba.

test.describe("Menú principal y Ayuda", () => {
  test("el inicio muestra exactamente lo que calcula el servidor", async ({ page, request }, info) => {
    await page.goto("/");
    const { resumenInventario: r } = await graphql<{ resumenInventario: { totalLibros: number; totalEjemplares: number } }>(
      request, "{ resumenInventario { totalLibros totalEjemplares } }"
    );
    const cifras = page.getByRole("region", { name: "Inventario" });
    await expect(cifras.getByText(String(r.totalLibros), { exact: true })).toBeVisible();
    await expect(cifras.getByText(String(r.totalEjemplares), { exact: true })).toBeVisible();
    await expect(page.getByText(`${r.totalEjemplares} copias · calculado por el servidor`)).toBeVisible();
    await capturar(page, info, "01-inicio");
  });

  test("el menú tiene cada caso de uso y Ayuda > Acerca de... con integrantes y versión", async ({ page }, info) => {
    await page.goto("/");
    const menu = await abrirMenu(page);
    for (const opcion of ["Listar", "Consultar", "Adicionar", "Actualizar", "Eliminar"]) {
      await expect(menu.getByRole("link", { name: opcion, exact: true })).toHaveCount(2);
    }
    await capturar(page, info, "02-menu");
    await menu.getByRole("link", { name: "Acerca de..." }).click();

    await expect(page.getByRole("heading", { level: 1, name: "Acerca de" })).toBeVisible();
    await expect(page.getByText("1.0.0", { exact: true })).toBeVisible();
    for (const integrante of ["Misael Gallo Tangarife", "Sara Zambrano", "Santiago Guimel", "Alejandra González"]) {
      await expect(page.getByText(integrante)).toBeVisible();
    }
    await expect(page.getByText(/Servidor conectado · \d+ ms/)).toBeVisible();
    await capturar(page, info, "03-acerca-de", true);
  });
});

test.describe("Libro", () => {
  test("adicionar: válido", async ({ page, request }, info) => {
    const isbn = `978-E2E-${unico(info)}`;
    await page.goto("/libros/agregar");
    await page.getByLabel("ISBN").fill(isbn);
    await page.getByLabel("Título").fill("Cóndores no entierran todos los días");
    await page.getByLabel("Autor").fill("Gustavo Álvarez Gardeazábal");
    await page.getByLabel("Fecha de publicación").fill("1971-06-15T09:45");
    await elegir(page, "Género", "Ficción");
    await page.getByLabel("Precio").fill("47000");
    await page.getByLabel("Número de páginas").fill("246");
    await capturar(page, info, "10-libro-adicionar-formulario", true);
    await page.getByRole("button", { name: "Adicionar libro" }).click();

    await esperarAviso(page, "Libro adicionado");
    await capturar(page, info, "11-libro-adicionar-exito");
    const { libroPorIsbn } = await graphql<{ libroPorIsbn: { titulo: string; numeroPaginas: number; fechaPublicacion: string } }>(
      request, `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { titulo numeroPaginas fechaPublicacion } }`, { isbn }
    );
    expect(libroPorIsbn).toEqual({ titulo: "Cóndores no entierran todos los días", numeroPaginas: 246, fechaPublicacion: "1971-06-15T09:45:00" });
  });

  test("adicionar: inválido (formato en el cliente y regla del servidor)", async ({ page }, info) => {
    await page.goto("/libros/agregar");
    await page.getByRole("button", { name: "Adicionar libro" }).click();
    await expect(page.getByText("Este campo es obligatorio.")).toHaveCount(5);
    await expect(page.getByText("Elige la fecha y la hora.")).toBeVisible();
    await capturar(page, info, "12-libro-adicionar-validacion", true);

    // ISBN repetido: lo rechaza el servidor.
    await page.getByLabel("ISBN").fill("978-0307474728");
    await page.getByLabel("Título").fill("Copia");
    await page.getByLabel("Autor").fill("Alguien");
    await page.getByLabel("Fecha de publicación").fill("2001-01-01T10:00");
    await page.getByLabel("Precio").fill("1000");
    await page.getByLabel("Número de páginas").fill("10");
    await page.getByRole("button", { name: "Adicionar libro" }).click();
    await expect(page.getByRole("alert")).toContainText("Ya existe un libro con el ISBN 978-0307474728");
    await capturar(page, info, "13-libro-adicionar-rechazo");
  });

  test("consultar: encontrado por ISBN y por título, y no encontrado", async ({ page }, info) => {
    await page.goto("/libros/consultar");
    await page.getByLabel("ISBN", { exact: true }).fill("978-0307474728");
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByRole("heading", { name: "Cien años de soledad" })).toBeVisible();
    await expect(page.getByText("30/05/1967, 00:00")).toBeVisible();
    await capturar(page, info, "20-libro-consultar-isbn");

    await page.getByText("Por título").click();
    await page.getByRole("textbox", { name: "Título" }).fill("la voragine");
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByRole("heading", { name: "La vorágine" })).toBeVisible();
    await capturar(page, info, "21-libro-consultar-titulo");

    await page.getByRole("textbox", { name: "Título" }).fill("Libro que no existe");
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("No hay ningún libro titulado «Libro que no existe».")).toBeVisible();
    await capturar(page, info, "22-libro-consultar-no-encontrado");
  });

  test("actualizar: busca, muestra todo y guarda", async ({ page, request }, info) => {
    const isbn = `978-E2E-${unico(info)}`;
    await crearLibro(request, isbn);
    await page.goto("/libros/actualizar");
    await page.getByLabel("ISBN del libro").fill(isbn);
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("Datos actuales", { exact: true })).toBeVisible();
    await expect(page.getByText("10/05/2020, 08:30")).toBeVisible();
    await expect(page.getByLabel("Precio")).toHaveValue("50000");
    await page.getByLabel("Precio").fill("52500");
    await elegir(page, "Género", "Historia");
    await capturar(page, info, "30-libro-actualizar-formulario", true);
    await page.getByRole("button", { name: "Guardar cambios" }).click();

    await esperarAviso(page, "Cambios guardados");
    await expect(page.getByText("Datos guardados", { exact: true })).toBeVisible();
    await capturar(page, info, "31-libro-actualizar-guardado");
    const { libroPorIsbn } = await graphql<{ libroPorIsbn: { precio: number; genero: string } }>(
      request, `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { precio genero } }`, { isbn }
    );
    expect(libroPorIsbn).toEqual({ precio: 52500, genero: "HISTORIA" });
  });

  test("eliminar: cancelar no borra y confirmar sí", async ({ page, request }, info) => {
    const isbn = `978-E2E-${unico(info)}`;
    await crearLibro(request, isbn, "Libro para eliminar");
    await page.goto("/libros/eliminar");
    await page.getByLabel("ISBN del libro").fill(isbn);
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("Libro a eliminar", { exact: true })).toBeVisible();
    await capturar(page, info, "40-libro-eliminar-ficha", true);

    await page.getByRole("button", { name: "Eliminar libro" }).click();
    const dialogo = page.getByRole("alertdialog");
    await expect(dialogo).toContainText("¿Eliminar «Libro para eliminar»?");
    await capturar(page, info, "41-libro-eliminar-dialogo");
    await dialogo.getByRole("button", { name: "Cancelar" }).click();
    await expect(dialogo).toBeHidden();
    const antes = await graphql<{ libroPorIsbn: unknown }>(request, `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { isbn } }`, { isbn });
    expect(antes.libroPorIsbn).not.toBeNull();

    await page.getByRole("button", { name: "Eliminar libro" }).click();
    await page.getByRole("alertdialog").getByRole("button", { name: "Eliminar", exact: true }).click();
    await esperarAviso(page, "Libro eliminado");
    await capturar(page, info, "42-libro-eliminar-exito");
    const despues = await graphql<{ libroPorIsbn: unknown }>(request, `query ($isbn: ID!) { libroPorIsbn(isbn: $isbn) { isbn } }`, { isbn });
    expect(despues.libroPorIsbn).toBeNull();
  });

  test("eliminar un libro con ejemplares: el servidor lo rechaza", async ({ page, request }, info) => {
    await page.goto("/libros/eliminar");
    await page.getByLabel("ISBN del libro").fill("978-0307474728");
    await page.getByRole("button", { name: "Buscar" }).click();
    await page.getByRole("button", { name: "Eliminar libro" }).click();
    await page.getByRole("alertdialog").getByRole("button", { name: "Eliminar", exact: true }).click();

    await expect(page.getByRole("alert")).toContainText("porque tiene");
    await expect(page.getByRole("alert")).toContainText("ejemplar(es) registrado(s)");
    await capturar(page, info, "43-libro-eliminar-rechazo");
    const { libroPorIsbn } = await graphql<{ libroPorIsbn: unknown }>(request, `{ libroPorIsbn(isbn: "978-0307474728") { isbn } }`);
    expect(libroPorIsbn).not.toBeNull();
  });

  test("listar con cada filtro: el conteo es el del servidor", async ({ page, request }, info) => {
    await page.goto("/libros/listar");
    await expect(page.getByRole("table", { name: "Libros del inventario" })).toBeVisible();
    await capturar(page, info, "50-libro-listar");

    const total = async (autor: string | null, genero: string | null) =>
      (await graphql<{ totalLibrosFiltrados: number }>(
        request,
        `query ($a: String, $g: Genero) { totalLibrosFiltrados(autor: $a, genero: $g) }`,
        { a: autor, g: genero }
      )).totalLibrosFiltrados;
    const conteo = (n: number) => (n === 1 ? "1 libro" : `${n} libros`);

    await page.getByLabel("Autor").fill("garcia");
    await page.getByRole("button", { name: "Filtrar" }).click();
    await expect(page.getByText(conteo(await total("garcia", null)), { exact: true })).toBeVisible();
    await expect(page.getByRole("cell", { name: /Cien años de soledad/ })).toBeVisible();
    await capturar(page, info, "51-libro-listar-autor");
    await page.getByRole("button", { name: "Limpiar filtros" }).first().click();

    const generos: [string, string][] = [
      ["Ficción", "FICCION"], ["No ficción", "NO_FICCION"], ["Ciencia", "CIENCIA"], ["Historia", "HISTORIA"],
      ["Infantil", "INFANTIL"], ["Poesía", "POESIA"], ["Otro", "OTRO"]
    ];
    for (const [texto, valor] of generos) {
      await elegir(page, "Género", texto);
      await expect(page.getByText(conteo(await total(null, valor)), { exact: true })).toBeVisible();
    }
    await elegir(page, "Género", "Poesía");
    await expect(page.getByRole("cell", { name: /Veinte poemas de amor/ })).toBeVisible();
    await capturar(page, info, "52-libro-listar-genero");
    await elegir(page, "Género", "Todos los géneros");
    await expect(page.getByText(conteo(await total(null, null)), { exact: true })).toBeVisible();
  });

  test("Observer: lo que se adiciona en otra pestaña aparece solo en Listar (≤ 15 s)", async ({ page, context, request }, info) => {
    const isbn = `978-E2E-${unico(info)}`;
    await page.goto("/libros/listar");
    await expect(page.getByRole("table", { name: "Libros del inventario" })).toBeVisible();

    const otra = await context.newPage();
    await otra.goto("/libros/agregar");
    await otra.getByLabel("ISBN").fill(isbn);
    await otra.getByLabel("Título").fill("Observado desde otra pestaña");
    await otra.getByLabel("Autor").fill("Autora E2E");
    await otra.getByLabel("Fecha de publicación").fill("2024-01-01T12:00");
    await otra.getByLabel("Precio").fill("30000");
    await otra.getByLabel("Número de páginas").fill("100");
    await otra.getByRole("button", { name: "Adicionar libro" }).click();
    await expect(otra.getByText("Libro adicionado", { exact: true })).toBeVisible();
    await otra.close();

    // Sin recargar: el Observer entre clientes revisa el servidor cada 15 s.
    const nuevo = page.getByRole("cell", { name: /Observado desde otra pestaña/ });
    await expect(nuevo).toBeVisible({ timeout: 20_000 });
    await nuevo.scrollIntoViewIfNeeded();
    await capturar(page, info, "53-libro-listar-observer");
    await graphql(request, `mutation ($isbn: ID!) { eliminarLibro(isbn: $isbn) { isbn } }`, { isbn });
  });
});

test.describe("Ejemplar", () => {
  test("adicionar: válido e inválido", async ({ page, request }, info) => {
    const codigo = `EJ-E2E-${unico(info)}`;
    await page.goto("/ejemplares/agregar");
    await page.getByLabel("Código del ejemplar").fill(codigo);
    await page.getByLabel("ISBN del libro").fill("978-8420633121");
    await elegir(page, "Estado", "Disponible");
    await page.getByLabel("Ubicación", { exact: true }).fill("Estante D2");
    await page.getByLabel("Fecha de ingreso").fill("2026-03-02T16:10");
    await page.getByLabel("Precio de reposición").fill("52000");
    await page.getByLabel("Número de préstamos").fill("-1");
    await page.getByRole("button", { name: "Adicionar ejemplar" }).click();
    await expect(page.getByText("No puede ser negativo.")).toBeVisible();
    await capturar(page, info, "60-ejemplar-adicionar-validacion", true);

    await page.getByLabel("Número de préstamos").fill("0");
    await page.getByRole("button", { name: "Adicionar ejemplar" }).click();
    await esperarAviso(page, "Ejemplar adicionado");
    await capturar(page, info, "61-ejemplar-adicionar-exito");
    const { ejemplarPorCodigo } = await graphql<{ ejemplarPorCodigo: { isbnLibro: string; numeroPrestamos: number } }>(
      request, `query ($c: ID!) { ejemplarPorCodigo(codigo: $c) { isbnLibro numeroPrestamos } }`, { c: codigo }
    );
    expect(ejemplarPorCodigo).toEqual({ isbnLibro: "978-8420633121", numeroPrestamos: 0 });

    // Libro inexistente: lo rechaza el servidor.
    await page.getByLabel("Código del ejemplar").fill(`${codigo}-B`);
    await page.getByLabel("ISBN del libro").fill("000-NO-EXISTE");
    await page.getByLabel("Ubicación", { exact: true }).fill("Estante D2");
    await page.getByLabel("Fecha de ingreso").fill("2026-03-02T16:10");
    await page.getByLabel("Precio de reposición").fill("52000");
    await page.getByRole("button", { name: "Adicionar ejemplar" }).click();
    await expect(page.getByRole("alert")).toContainText("000-NO-EXISTE");
    await capturar(page, info, "62-ejemplar-adicionar-rechazo");
  });

  test("consultar: encontrado y no encontrado", async ({ page }, info) => {
    await page.goto("/ejemplares/consultar");
    await page.getByLabel("Código del ejemplar").fill("ej-007");
    await page.getByRole("button", { name: "Buscar" }).click();
    const ficha = page.getByRole("article", { name: "Ejemplar EJ-007" });
    await expect(ficha).toContainText("Dañado");
    await expect(ficha).toContainText("14/11/2023, 15:10");
    await capturar(page, info, "70-ejemplar-consultar", true);

    await page.getByLabel("Código del ejemplar").fill("EJ-999");
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("No hay ningún ejemplar con el código «EJ-999».")).toBeVisible();
    await capturar(page, info, "71-ejemplar-consultar-no-encontrado");
  });

  test("actualizar: al pasar a Prestado el servidor suma un préstamo", async ({ page, request }, info) => {
    const codigo = `EJ-E2E-${unico(info)}`;
    await crearEjemplar(request, codigo, "978-0307474728", 4);
    await page.goto("/ejemplares/actualizar");
    await page.getByLabel("Código del ejemplar").fill(codigo);
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("Datos actuales", { exact: true })).toBeVisible();
    await expect(page.getByLabel("Número de préstamos")).toHaveValue("4");
    await expect(page.getByLabel("Número de préstamos")).toHaveAttribute("readonly", "");
    await elegir(page, "Estado", "Prestado");
    await capturar(page, info, "80-ejemplar-actualizar-formulario", true);
    await page.getByRole("button", { name: "Guardar cambios" }).click();

    await esperarAviso(page, "Cambios guardados");
    const guardado = page.getByRole("article", { name: `Ejemplar ${codigo}` });
    await expect(guardado).toContainText("Datos guardados");
    await expect(guardado).toContainText("Prestado");
    await expect(guardado.getByText("5", { exact: true })).toBeVisible();
    await capturar(page, info, "81-ejemplar-actualizar-guardado", true);
    const { ejemplarPorCodigo } = await graphql<{ ejemplarPorCodigo: { numeroPrestamos: number } }>(
      request, `query ($c: ID!) { ejemplarPorCodigo(codigo: $c) { numeroPrestamos } }`, { c: codigo }
    );
    expect(ejemplarPorCodigo.numeroPrestamos).toBe(5);
  });

  test("eliminar: cancelar no borra y confirmar sí", async ({ page, request }, info) => {
    const codigo = `EJ-E2E-${unico(info)}`;
    await crearEjemplar(request, codigo, "978-9580469117", 0);
    await page.goto("/ejemplares/eliminar");
    await page.getByLabel("Código del ejemplar").fill(codigo);
    await page.getByRole("button", { name: "Buscar" }).click();
    await expect(page.getByText("Ejemplar a eliminar", { exact: true })).toBeVisible();
    await capturar(page, info, "90-ejemplar-eliminar-ficha", true);

    await page.getByRole("button", { name: "Eliminar ejemplar" }).click();
    await capturar(page, info, "91-ejemplar-eliminar-dialogo");
    await page.getByRole("alertdialog").getByRole("button", { name: "Cancelar" }).click();
    expect((await graphql<{ ejemplarPorCodigo: unknown }>(
      request, `query ($c: ID!) { ejemplarPorCodigo(codigo: $c) { codigo } }`, { c: codigo }
    )).ejemplarPorCodigo).not.toBeNull();

    await page.getByRole("button", { name: "Eliminar ejemplar" }).click();
    await page.getByRole("alertdialog").getByRole("button", { name: "Eliminar", exact: true }).click();
    await esperarAviso(page, "Ejemplar eliminado");
    await capturar(page, info, "92-ejemplar-eliminar-exito");
    expect((await graphql<{ ejemplarPorCodigo: unknown }>(
      request, `query ($c: ID!) { ejemplarPorCodigo(codigo: $c) { codigo } }`, { c: codigo }
    )).ejemplarPorCodigo).toBeNull();
  });

  test("listar con cada filtro: el conteo es el del servidor", async ({ page, request }, info) => {
    await page.goto("/ejemplares/listar");
    await expect(page.getByRole("table", { name: "Ejemplares del inventario" })).toBeVisible();
    await capturar(page, info, "95-ejemplar-listar");

    const total = async (estado: string | null, isbn: string | null) =>
      (await graphql<{ totalEjemplaresFiltrados: number }>(
        request,
        `query ($e: EstadoEjemplar, $i: String) { totalEjemplaresFiltrados(estado: $e, isbnLibro: $i) }`,
        { e: estado, i: isbn }
      )).totalEjemplaresFiltrados;
    const conteo = (n: number) => (n === 1 ? "1 ejemplar" : `${n} ejemplares`);

    for (const [texto, valor] of [["Disponible", "DISPONIBLE"], ["Prestado", "PRESTADO"], ["Dañado", "DANIADO"], ["Dado de baja", "DADO_DE_BAJA"]]) {
      await page.getByText(texto, { exact: true }).first().click();
      await expect(page.getByText(conteo(await total(valor, null)), { exact: true })).toBeVisible();
    }
    await capturar(page, info, "96-ejemplar-listar-estado");

    await page.getByLabel("ISBN del libro").fill("978-0307474728");
    await page.getByRole("button", { name: "Filtrar" }).click();
    await expect(page.getByText(conteo(await total("DADO_DE_BAJA", "978-0307474728")), { exact: true })).toBeVisible();
    await page.getByText("Todos", { exact: true }).click();
    await expect(page.getByText(conteo(await total(null, "978-0307474728")), { exact: true })).toBeVisible();
    await capturar(page, info, "97-ejemplar-listar-isbn");
  });
});
