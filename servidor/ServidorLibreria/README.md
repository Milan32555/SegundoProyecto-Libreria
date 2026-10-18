# Servidor GraphQL — Librería (Java · Spring Boot)

Servidor central del [Segundo Proyecto](../../README.md). Expone el CRUD de **Libro** (maestro)
y **Ejemplar** (detalle) como servicios web GraphQL y guarda los objetos en listas en memoria.

## Ejecutar

```bash
./mvnw spring-boot:run          # Windows: mvnw.cmd spring-boot:run
```

- GraphQL: `POST http://localhost:8081/graphql`
- GraphiQL (consola para probar consultas): `http://localhost:8081/graphiql`
- Configuración en [`application.properties`](src/main/resources/application.properties)
  (puerto 8081, CORS abierto para que los clientes puedan conectarse desde otro origen).

Requiere JDK 17 o superior. No hace falta instalar Maven (se usa el Maven Wrapper).

## Estructura

```
src/main/java/com/libreria/servidor/
├── controller/    LibroController, EjemplarController, ResumenController → capa Controller (GraphQL)
├── servicio/      ServicioLibro, ServicioEjemplar, ServicioResumen → lógica de negocio y validaciones
├── repositorio/   RepositorioLibros, RepositorioEjemplares → Singleton, dueños de las List
├── model/         Libro, Ejemplar + DTOs de entrada (LibroInput, LibroUpdateInput, …)
│                  + records de salida ResumenInventario y ConteoEstado
├── builder/       LibroBuilder, EjemplarBuilder        → patrón Builder
├── observer/      ListadoObservable, ObservadorListado, RevisionListado → patrón Observer
├── enums/         Genero, EstadoEjemplar
├── excepciones/   LibreriaException + ManejadorErrores (errores legibles para los clientes)
├── registro/      RegistroOperaciones → una línea en consola por operación y cliente (X-Cliente)
└── config/        LocalDateTimeScalarConfig (escalar GraphQL LocalDateTime, ISO-8601)
src/main/resources/graphql/schema.graphqls              → contrato GraphQL
```

## Decisiones de diseño

- **Lógica de negocio solo aquí:** filtros, búsquedas, conteos y totales se calculan en el
  servidor. `totalLibrosFiltrados` / `totalEjemplaresFiltrados` dan el total de cada Listar y
  `resumenInventario` (`ServicioResumen`) da los totales y los ejemplares por estado de la
  ventana principal, para que los clientes no cuenten nada.
- **Singleton:** los repositorios tienen constructor privado y `getInstancia()`; son la única
  fuente de verdad de cada colección. `listar()` devuelve una copia para que nadie modifique
  la lista desde afuera.
- **Concurrencia:** varios clientes hacen peticiones a la vez. Los repositorios sincronizan
  el acceso a la lista y las operaciones de escritura de los servicios son `synchronized`
  para que "verificar y luego modificar" (p. ej. ISBN único) sea atómico.
- **Observer:** cada servicio es un sujeto (`ListadoObservable`) que notifica tras cada
  inserción, actualización o eliminación. El observador `RevisionListado` cuenta esos cambios
  y se expone como `revisionLibros` / `revisionEjemplares`, que los clientes consultan para
  refrescar su pantalla de Listar cuando otro cliente modifica los datos.
- **Integridad maestro–detalle:** un ejemplar solo se crea para un libro existente (se guarda
  el ISBN tal como está registrado) y un libro con ejemplares no se puede eliminar.
- **Préstamos:** `numeroPrestamos` se fija al crear el ejemplar (no negativo). Al actualizar
  no se recibe del cliente (`EjemplarUpdateInput` no lo tiene): `ServicioEjemplar` le suma 1
  cada vez que el estado cambia de otro a `PRESTADO`.
- **Registro de operaciones:** `RegistroOperaciones` (un `WebGraphQlInterceptor`) lee el
  encabezado `X-Cliente` (`web` / `movil`) y escribe en consola la hora, el cliente, el tipo de
  operación, los campos pedidos, los datos clave y si el servidor la rechazó. El formato corto
  está en `logback-spring.xml`. Las consultas de revisión del Observer se omiten salvo que se
  active `libreria.registro.incluir-revisiones=true`.
- **Errores:** las reglas de negocio lanzan `LibreriaException`; `ManejadorErrores` la
  convierte en un error GraphQL `BAD_REQUEST` con un mensaje en español para el usuario.
- **Fechas:** el escalar `LocalDateTime` acepta `yyyy-MM-ddTHH:mm[:ss]` (formato de
  `<input type="datetime-local">`) y fechas con zona horaria (`...Z`).

## Pruebas

```bash
./mvnw verify
```

| Clase | Qué prueba |
|---|---|
| `ServicioLibroTest`, `ServicioEjemplarTest` | CRUD, validaciones (incluido número de préstamos no negativo), regla de préstamos al pasar a PRESTADO, filtros sin tildes y sus totales, búsqueda por ISBN/título, integridad, notificaciones |
| `ServicioResumenTest` | Resumen del inventario: totales, ejemplares por estado y porcentajes |
| `PatronesDisenoTest` | Singleton, Builder, Observer y protección de la colección |
| `GraphQlApiTest` | La API GraphQL completa: consultas anidadas, filtros y totales, resumen del inventario, mutaciones, fechas y mensajes de error |
| `RegistroOperacionesTest` | El texto de cada línea del registro (cliente, operación, datos clave, rechazos) |
| `ServidorHttpTest` | El servidor en un puerto real: `POST /graphql`, preflight CORS (con `X-Cliente`) y el registro en consola |
