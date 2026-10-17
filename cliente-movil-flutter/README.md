# Cliente móvil — Librería (Dart · Flutter)

Cliente 2 del [Segundo Proyecto](../README.md). App Flutter (Android, web y Windows) que
consume el servidor GraphQL para gestionar Libros y Ejemplares.

## Ejecutar

```bash
flutter pub get
flutter run                 # elige el dispositivo: emulador Android, Chrome, Windows…
flutter run -d chrome       # sin emulador: la misma app en el navegador
```

Dirección del servidor según el dispositivo:

| Dónde corre la app | URL que usa | ¿Hay que configurar algo? |
|---|---|---|
| Emulador Android | `http://10.0.2.2:8081/graphql` | No (10.0.2.2 es el computador visto desde el emulador) |
| Chrome / Windows | `http://localhost:8081/graphql` | No |
| Teléfono físico (misma Wi-Fi) | IP del computador | `flutter run --dart-define=URL_GRAPHQL=http://<IP>:8081/graphql` |

**Celular por cable USB (recomendado si el Wi-Fi bloquea la conexión entre equipos):** con la
depuración USB activada, `adb reverse` hace que el celular llegue al servidor por el cable:

```bash
adb reverse tcp:8081 tcp:8081
flutter run --dart-define=URL_GRAPHQL=http://localhost:8081/graphql
```

El `AndroidManifest.xml` incluye el permiso `INTERNET` y `usesCleartextTraffic`, necesario
porque el servidor del proyecto usa `http://` (Android 9+ bloquea HTTP sin TLS por defecto).

## Estructura (MVC)

```
lib/
├── main.dart                    Rutas: una pantalla por caso de uso
├── modelos/                     Modelo: Libro, Ejemplar (desde JSON)
├── servicios/                   Acceso a datos
│   ├── cliente_graphql.dart     Singleton que envía las peticiones y traduce los errores
│   ├── servicio_libro.dart
│   └── servicio_ejemplar.dart
├── observador/
│   └── listado_observable.dart  Sujeto del patrón Observer (uno por colección)
├── pantallas/                   Vistas
│   ├── menu_principal.dart      Resumen del inventario en vivo + accesos a cada caso de uso
│   ├── menu_lateral.dart        Menú con todas las opciones y "Ayuda → Acerca de..."
│   ├── acerca_de.dart           Integrantes y versión
│   ├── libro/                   agregar, eliminar, actualizar, listar, consultar
│   ├── ejemplar/                agregar, eliminar, actualizar, listar, consultar
│   └── comunes/                 Fichas, campo de fecha y componentes visuales reutilizables
├── tema/tema.dart               Sistema de diseño: paleta, medidas y ThemeData
└── utilidades/                  Formatos de fecha/precio y validaciones de formularios
```

## Diseño

Identidad propia de librería, "papel y tinta" (`lib/tema/tema.dart`):

- Fondo crema como las páginas de un libro, texto color tinta y **verde biblioteca** como color
  principal; **dorado** para precios. Títulos con la serif **Playfair Display** y el resto del texto
  con **Plus Jakarta Sans** (incluidas en `assets/fuentes`, licencia SIL OFL), por lo que no
  depende de internet.
- Inicio con un encabezado verde que se contrae al desplazar: saludo y fecha, cifras del
  inventario que cuentan hasta su valor y una estantería dibujada cuyos libros "crecen" al abrir
  la app; debajo, la distribución de los ejemplares por estado en una barra proporcional.
- Las fichas (consultar y antes de eliminar) son tarjetas limpias con borde fino y sombra suave.
- *Acerca de...* con estilo de app profesional: tarjeta del producto con su versión, el equipo,
  un **diagrama animado de la arquitectura** (los clientes envían peticiones GraphQL al servidor)
  que mide en el momento si el servidor responde y en cuántos milisegundos, los patrones de diseño
  aplicados y las tecnologías.
- Estados con color (Disponible, Prestado, Dañado, Dado de baja) y chips para elegir
  género/estado. Las pantallas de inicio y Listar se actualizan solas (Observer) sin necesidad de
  recargar.
- Ícono propio (Android adaptativo, web y Windows) y barra de navegación del sistema transparente.

## Problemas comunes

- **`flutter emulators` no muestra ningún emulador, pero Android Studio sí tiene.** Flutter está
  usando otro SDK (lo indica `flutter doctor -v`, línea *Android SDK at …*). Opciones: encender
  el emulador desde *Device Manager* de Android Studio y luego `flutter run` lo detecta, o apuntar
  Flutter al SDK de Android Studio con `flutter config --android-sdk "%LOCALAPPDATA%\Android\Sdk"`.
- **La primera compilación para Android tarda varios minutos** (Gradle descarga dependencias).
  Hacerla antes de la presentación.
- **"No se pudo conectar con el servidor"**: verificar que el servidor esté corriendo y que la URL
  corresponda al dispositivo (tabla de arriba).

## Pruebas

```bash
flutter analyze
flutter test
```

- `test/logica_test.dart`: modelos, cliente GraphQL (Singleton, errores, sin conexión),
  Observer y utilidades.
- `test/pantallas_test.dart`: flujos de las pantallas (menú y Acerca de, grilla con filtro,
  refresco por Observer, eliminar con ficha completa, validaciones, consultar por título,
  actualizar) usando un servidor GraphQL simulado (`test/servidor_simulado.dart`).
- `test/integracion_servidor_test.dart`: CRUD contra el servidor real. Se omite salvo que se
  indique la URL:
  ```bash
  flutter test test/integracion_servidor_test.dart --dart-define=URL_GRAPHQL=http://localhost:8081/graphql
  ```
