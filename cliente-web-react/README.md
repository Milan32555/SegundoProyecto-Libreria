# Cliente web — Librería (TypeScript · React)

Cliente 1 del [Segundo Proyecto](../README.md). Aplicación web que consume el servidor
GraphQL para gestionar Libros y Ejemplares.

## Ejecutar

```bash
npm install
npm run dev        # http://localhost:5173
```

El servidor debe estar corriendo en `http://localhost:8081/graphql`. Para usar otra dirección,
crear un archivo `.env` (no se versiona) con:

```
VITE_URL_GRAPHQL=http://<ip-del-servidor>:8081/graphql
```

| Script | Para qué |
|---|---|
| `npm run dev` | Servidor de desarrollo |
| `npm test` | Pruebas (Vitest + Testing Library) |
| `npm run lint` | ESLint (TypeScript + reglas de hooks de React) |
| `npm run build` | Verificación de tipos y build de producción en `dist/` |

## Estructura (MVC)

```
src/
├── types.ts                 Modelo: interfaces Libro / Ejemplar y enums
├── graphql/                 Acceso a datos
│   ├── clienteGraphQL.ts    Singleton que envía las peticiones (con X-Cliente: web) y traduce los errores
│   ├── servicioLibro.ts     Consultas/mutaciones de Libro
│   ├── servicioEjemplar.ts  Consultas/mutaciones de Ejemplar
│   └── servicioResumen.ts   Resumen del inventario (lo calcula el servidor)
├── observer/
│   ├── Observable.ts        Sujeto del patrón Observer (uno por colección)
│   └── useListadoObservado.ts  Hook que suscribe las pantallas de Listar
├── componentes/             Estructura y Navegacion (menú lateral + Ayuda), FichaLibro, FichaEjemplar
│   └── ui/                  Sistema de diseño: Boton, Campo, Selector, Segmentado, TablaDatos,
│                            Banner, Insignias, Avisos (toasts), ConfirmarEliminacion, Ayuda (tooltip)…
├── estilos/                 tokens.css (colores, tipografía, espaciado, radios) y app.css
├── paginas/                 Vistas: una pantalla por caso de uso
│   ├── libro/               Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── ejemplar/            Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── MenuPrincipal.tsx
│   └── AcercaDe.tsx         Integrantes y versión
├── validaciones.ts          Validaciones de formato de los formularios (las reglas las decide el servidor)
└── formato.ts               Formato de precios y fechas
```

Pruebas: `src/**/*.test.ts(x)` (Vitest) y `e2e/` (Playwright contra el servidor real).

Cada pantalla implementa un solo caso de uso y se abre desde el menú lateral
(**Libros**, **Ejemplares**, **Ayuda → Acerca de...**); en celular el menú se abre como un cajón.

## Diseño

Panel de administración al estilo de Shopify Polaris, Linear y Stripe, con el mismo sistema de
diseño de la app móvil (`src/estilos/tokens.css`):

- Menú lateral fijo agrupado por objeto; encabezado de página con la acción principal a la
  derecha; formularios por secciones; tablas densas con encabezado fijo, números alineados a la
  derecha y estados de carga (skeleton), vacío (con una acción útil) y error (con *Reintentar*).
- Neutros cálidos y un solo color de marca (verde `#1F5C4A`); los estados de un ejemplar son
  insignias con punto + texto. Contraste AA verificado.
- IBM Plex Sans para la interfaz y Literata para los títulos de libros y el logotipo
  (paquetes `@fontsource`, incluidas en el build: no dependen de internet).
- Componentes accesibles de Radix UI: diálogo para confirmar eliminar, selects, avisos (toasts)
  y tooltips; íconos Lucide. Foco visible, etiquetas en todos los campos y validación en línea.
- Usable en 1366×768 y en celular (menú en cajón y primera columna de la tabla fija).

## Observer

Las pantallas de Listar se suscriben al sujeto de su colección mientras están abiertas.
El sujeto las notifica de inmediato cuando otra pantalla de este cliente hace un cambio
(obligatorio). Además, de forma opcional, consulta cada 15 s el número de revisión del servidor
para detectar cambios hechos desde **otro cliente** (por ejemplo, la app Flutter). Al refrescar
se usan los filtros que el usuario tiene escritos.

La ventana principal y las pantallas de Listar no cuentan nada: el total de cada Listar y el
resumen del inventario vienen calculados del servidor.
