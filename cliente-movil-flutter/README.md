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
│   ├── menu_principal.dart · menu_lateral.dart (menú + Ayuda) · acerca_de.dart
│   ├── libro/                   agregar, eliminar, actualizar, listar, consultar
│   ├── ejemplar/                agregar, eliminar, actualizar, listar, consultar
│   └── comunes/                 FichaLibro, FichaEjemplar, CampoFecha, TextoError
└── utilidades/                  Formatos de fecha/precio y validaciones de formularios
```

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
