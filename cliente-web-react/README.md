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
│   ├── clienteGraphQL.ts    Singleton que envía las peticiones y traduce los errores
│   ├── servicioLibro.ts     Consultas/mutaciones de Libro
│   ├── servicioEjemplar.ts  Consultas/mutaciones de Ejemplar
│   └── servicioResumen.ts   Resumen del inventario (lo calcula el servidor)
├── observer/
│   ├── Observable.ts        Sujeto del patrón Observer (uno por colección)
│   └── useListadoObservado.ts  Hook que suscribe las pantallas de Listar
├── componentes/             BarraMenu (menú + Ayuda), FichaLibro, FichaEjemplar, Basicos
│                            (Encabezado, Aviso, Pastilla, SelectorChips…) e Icono (SVG)
├── paginas/                 Vistas: una pantalla por caso de uso
│   ├── libro/               Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── ejemplar/            Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── MenuPrincipal.tsx
│   └── AcercaDe.tsx         Integrantes y versión
└── formato.ts               Formato de precios y fechas
```

Cada pantalla implementa un solo caso de uso y se abre desde el menú superior
(**Libro**, **Ejemplar**, **Ayuda → Acerca de...**).

## Diseño

Misma identidad "papel y tinta" que el cliente móvil: fondo crema, texto color tinta, verde
biblioteca como color principal y dorado para precios. Títulos con la serif **Playfair Display** y
el resto con **Plus Jakarta Sans** (incluidas en `src/assets/fuentes`, no dependen de internet).

- Inicio con el mismo encabezado verde de la app: saludo y fecha, cifras que cuentan hasta su
  valor, una estantería cuyos libros "crecen" al cargar y la barra de ejemplares por estado.
- *Acerca de...* profesional: tarjeta del producto, equipo, diagrama animado de la arquitectura
  que mide la respuesta real del servidor (clic para medir de nuevo), patrones y tecnologías.
- Las animaciones se desactivan si el sistema pide reducir el movimiento
  (`prefers-reduced-motion`), y el diseño se adapta a pantallas de celular. Los colores están
  definidos como variables en `src/estilos.css`.

## Observer

Las pantallas de Listar se suscriben al sujeto de su colección mientras están abiertas.
El sujeto las notifica de inmediato cuando otra pantalla de este cliente hace un cambio
(obligatorio). Además, de forma opcional, consulta cada 15 s el número de revisión del servidor
para detectar cambios hechos desde **otro cliente** (por ejemplo, la app Flutter). Al refrescar
se usan los filtros que el usuario tiene escritos.

La ventana principal y las pantallas de Listar no cuentan nada: el total de cada Listar y el
resumen del inventario vienen calculados del servidor.
