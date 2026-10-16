# Segundo Proyecto — Diseño de Soluciones (Universidad de Ibagué, 2026B)

Sistema de gestión de **Librería**, basado en el primer proyecto del curso (LibroFisico).
Arquitectura web distribuida: un servidor central expone la lógica de negocio mediante
**servicios web GraphQL**, y dos clientes desarrollados en tecnologías distintas entre sí
y distintas a la del servidor la consumen.

**Integrantes:** Misael Gallo Tangarife · Sara Zambrano · Santiago Guimel · Alejandra González

```
├── servidor/ServidorLibreria/   → Java 17 + Spring Boot + GraphQL (puerto 8081)
├── cliente-web-react/           → React + TypeScript (Vite)
└── cliente-movil-flutter/       → Flutter (Dart)
```

## Caso de estudio: Libro (maestro) → Ejemplar (detalle)

Un `Libro` (isbn, título, autor, precio, número de páginas, fecha de publicación, género)
puede tener **0..*** `Ejemplar` físicos en inventario (código, estado, ubicación, fecha de
ingreso, precio de reposición); cada ejemplar pertenece a **un único** libro (1..1).

Los objetos se almacenan en memoria principal mediante colecciones (`List`).

## Casos de uso (para cada objeto)

Adicionar · Eliminar (con búsqueda previa y confirmación) · Actualizar (con búsqueda previa)
· Listar con filtro · Buscar un objeto por criterio. Cada caso de uso tiene su propia
pantalla, accesible desde el menú principal, que incluye **Ayuda → Acerca de...**

## Patrones de diseño

| Patrón | Dónde |
|---|---|
| **MVC** | Servidor: `model` · `servicio` · `controller`. Clientes: modelos · servicios de acceso a datos · pantallas |
| **Singleton** | `RepositorioLibros` y `RepositorioEjemplares`: única instancia dueña de cada colección |
| **Builder** | `LibroBuilder` y `EjemplarBuilder` |
| **Observer** | `ListadoObservable` en el servidor y en ambos clientes: las pantallas de Listar se suscriben y se refrescan cuando otra pantalla adiciona, actualiza o elimina |
| **SOLID** | Una responsabilidad por clase, inyección de dependencias con Spring, DTOs de entrada separados de los modelos |

## Ejecución

### 1. Servidor
```bash
cd servidor/ServidorLibreria
mvn spring-boot:run
```
GraphQL en `http://localhost:8081/graphql` · GraphiQL en `http://localhost:8081/graphiql`

### 2. Cliente web
```bash
cd cliente-web-react
npm install
npm run dev
```
Abrir `http://localhost:5173`

### 3. Cliente móvil
```bash
cd cliente-movil-flutter
flutter pub get
flutter run
```
La URL del servidor está en `lib/servicios/cliente_graphql.dart`. Por defecto es
`http://10.0.2.2:8081/graphql` (emulador Android). En un dispositivo físico, usar la IP
del computador donde corre el servidor.
