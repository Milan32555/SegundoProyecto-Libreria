import 'dart:convert';
import 'package:http/http.dart' as http;

/// URL del servidor GraphQL.
///
/// IMPORTANTE: "localhost" en un emulador/dispositivo NO apunta al computador
/// donde corre el servidor. Usa:
///   - Emulador Android:        http://10.0.2.2:8081/graphql
///   - Dispositivo físico / iOS: http://<IP-de-tu-computador>:8081/graphql
const String urlGraphQL = 'http://10.0.2.2:8081/graphql';

/// Excepción con el mensaje que devuelve el servidor GraphQL.
class ErrorGraphQL implements Exception {
  final String mensaje;
  ErrorGraphQL(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Cliente GraphQL propio (sin paquetes externos de GraphQL): envía la
/// consulta/mutación por POST y devuelve el mapa "data", o lanza ErrorGraphQL.
Future<Map<String, dynamic>> ejecutarGraphQL(
  String query, {
  Map<String, dynamic>? variables,
}) async {
  final respuesta = await http.post(
    Uri.parse(urlGraphQL),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query, 'variables': variables ?? {}}),
  );

  if (respuesta.statusCode != 200) {
    throw ErrorGraphQL('El servidor respondió con código HTTP ${respuesta.statusCode}');
  }

  final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

  if (cuerpo['errors'] != null && (cuerpo['errors'] as List).isNotEmpty) {
    final primerError = (cuerpo['errors'] as List).first as Map<String, dynamic>;
    throw ErrorGraphQL(primerError['message'] as String? ?? 'Error desconocido del servidor');
  }

  return cuerpo['data'] as Map<String, dynamic>;
}
