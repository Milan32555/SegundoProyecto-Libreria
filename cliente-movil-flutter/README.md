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
├── modelos/                     Modelo: Libro, Ejemplar, ResumenInventario (desde JSON)
├── servicios/                   Acceso a datos
│   ├── cliente_graphql.dart     Singleton que envía las peticiones (con X-Cliente: movil) y traduce los errores
│   ├── servicio_libro.dart
│   ├── servicio_ejemplar.dart
│   └── servicio_resumen.dart    Resumen del inventario (lo calcula el servidor)
├── observador/
│   └── listado_observable.dart  Sujeto del patrón Observer (uno por colección)
├── pantallas/                   Vistas
│   ├── menu_principal.dart      Inicio: buscador, resumen del inventario y accesos a cada caso de uso
│   ├── menu_lateral.dart        NavigationDrawer con todas las opciones y "Ayuda → Acerca de..."
│   ├── acerca_de.dart           Integrantes y versión
│   ├── libro/                   agregar, eliminar, actualizar, listar, consultar
│   ├── ejemplar/                agregar, eliminar, actualizar, listar, consultar
│   └── comunes/                 Fichas, tabla con columna fija, campo de fecha y hora, hoja de confirmación y componentes
├── tema/                       tokens.dart (mismos valores que la web) y tema.dart (Material 3)
└── utilidades/                  Formatos de fecha/precio y validaciones de formularios
```

## Diseño

Material 3 con el mismo sistema de diseño del cliente web (`lib/tema/tokens.dart`), tomando
ideas de apps de librerías y lectura (Libby, Goodreads, Kindle, Buscalibre) y de Shopify POS:

- `ColorScheme` propio (neutros cálidos y verde de marca `#1F5C4A`), IBM Plex Sans para la
  interfaz y Literata para los títulos de libros (incluidas en `assets/fuentes`, licencia SIL OFL).
- Inicio con buscador (`SearchBar`), cifras del inventario calculadas por el servidor y
  distribución de los ejemplares por estado; menú en un `NavigationDrawer`.
- Listar en una tabla con encabezado fijo y la primera columna (título / código) fija al
  desplazar en horizontal; filtros con chips y búsqueda; botón flotante para adicionar.
- Formularios por secciones con el teclado adecuado a cada campo y validación en línea;
  eliminar se confirma en una hoja inferior y los resultados se avisan con un `SnackBar`.
- Estados de un ejemplar como insignias con punto + texto. Íconos Lucide (la misma familia que
  la web). Textos de Material (selector de fecha y hora) en español.
- Ícono de la app con el logotipo (se regenera con `scripts/generar-icono-app.py`).

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
