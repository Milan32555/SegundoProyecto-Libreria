import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// URL del servidor GraphQL.
///
/// Se puede cambiar sin tocar el código al ejecutar la app:
///   flutter run --dart-define=URL_GRAPHQL=http://192.168.1.10:8081/graphql
///
/// Si no se indica, se usa:
///   - Emulador Android: http://10.0.2.2:8081/graphql (así ve el emulador al computador)
///   - Web / Windows:    http://localhost:8081/graphql
///   - Dispositivo físico: hay que pasar la IP del computador con --dart-define.
String get urlGraphQL {
  const configurada = String.fromEnvironment('URL_GRAPHQL');
  if (configurada.isNotEmpty) return configurada;
  final esAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return esAndroid ? 'http://10.0.2.2:8081/graphql' : 'http://localhost:8081/graphql';
}

/// Excepción con un mensaje listo para mostrarle al usuario (del servidor o de conexión).
class ErrorGraphQL implements Exception {
  final String mensaje;
  ErrorGraphQL(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Patrón Singleton: única instancia del cliente que se comunica con el servidor GraphQL.
///
/// Todas las peticiones de la app pasan por aquí: envía la consulta/mutación por POST y
/// devuelve el mapa "data", o lanza [ErrorGraphQL]. (Cliente propio, sin paquetes de GraphQL.)
class ClienteGraphQL {
  static final ClienteGraphQL _instancia = ClienteGraphQL._interno();

  factory ClienteGraphQL() => _instancia;

  ClienteGraphQL._interno();

  static const _tiempoMaximo = Duration(seconds: 10);

  /// Con este encabezado el servidor sabe qué cliente hizo cada operación (lo muestra en consola).
  static const encabezadoCliente = {'X-Cliente': 'movil'};

  http.Client _http = http.Client();

  /// Permite que las pruebas reemplacen la conexión real por una simulada.
  @visibleForTesting
  set clienteHttp(http.Client cliente) => _http = cliente;

  Future<Map<String, dynamic>> ejecutar(String query, {Map<String, dynamic>? variables}) async {
    final url = urlGraphQL;
    final http.Response respuesta;
    try {
      respuesta = await _http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json', ...encabezadoCliente},
            body: jsonEncode({'query': query, 'variables': variables ?? {}}),
          )
          .timeout(_tiempoMaximo);
    } on TimeoutException {
      throw ErrorGraphQL('El servidor no respondió a tiempo ($url).');
    } on Exception {
      throw ErrorGraphQL('No se pudo conectar con el servidor ($url). Verifique que esté en ejecución.');
    }

    // Se lee el cuerpo aunque el código HTTP sea de error: ahí viene el mensaje del servidor.
    final cuerpo = _decodificar(respuesta.bodyBytes);
    final errores = cuerpo?['errors'];
    if (errores is List && errores.isNotEmpty) {
      final primero = errores.first;
      final mensaje = primero is Map ? primero['message'] : null;
      throw ErrorGraphQL(mensaje is String ? mensaje : 'Error desconocido del servidor.');
    }

    final data = cuerpo?['data'];
    if (respuesta.statusCode != 200 || data is! Map<String, dynamic>) {
      throw ErrorGraphQL('El servidor respondió con código HTTP ${respuesta.statusCode}.');
    }
    return data;
  }

  static Map<String, dynamic>? _decodificar(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes));
      return json is Map<String, dynamic> ? json : null;
    } on FormatException {
      return null;
    }
  }
}
