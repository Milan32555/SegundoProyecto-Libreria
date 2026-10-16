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
│   └── servicioEjemplar.ts  Consultas/mutaciones de Ejemplar
├── observer/
│   ├── Observable.ts        Sujeto del patrón Observer (uno por colección)
│   └── useListadoObservado.ts  Hook que suscribe las pantallas de Listar
├── componentes/             BarraMenu (menú + Ayuda), FichaLibro, FichaEjemplar
├── paginas/                 Vistas: una pantalla por caso de uso
│   ├── libro/               Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── ejemplar/            Agregar, Eliminar, Actualizar, Listar, Consultar
│   ├── MenuPrincipal.tsx
│   └── AcercaDe.tsx         Integrantes y versión
└── formato.ts               Formato de precios y fechas
```

Cada pantalla implementa un solo caso de uso y se abre desde el menú superior
(**Libro**, **Ejemplar**, **Ayuda → Acerca de...**).

## Observer

Las pantallas de Listar se suscriben al sujeto de su colección mientras están abiertas.
El sujeto las notifica cuando otra pantalla de este cliente hace un cambio y, además, consulta
cada 3 s el número de revisión del servidor para detectar cambios hechos desde **otro cliente**
(por ejemplo, la app Flutter). Al refrescar se usan los filtros que el usuario tiene escritos.
