import 'dart:convert';

import 'package:cliente_movil_libreria/servicios/cliente_graphql.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Error de negocio que el servidor simulado devuelve en "errors" (como el servidor real).
class ErrorSimulado implements Exception {
  ErrorSimulado(this.mensaje);
  final String mensaje;
}

typedef Resolver = Object? Function(Map<String, dynamic> variables);

/// Servidor GraphQL falso para las pruebas: responde según el campo raíz de cada
/// consulta/mutación y guarda las peticiones recibidas para poder verificarlas.
class ServidorSimulado {
  ServidorSimulado(this.resolvers);

  final Map<String, Resolver> resolvers;
  final List<({String campo, Map<String, dynamic> variables})> peticiones = [];

  static final _campoRaiz = RegExp(r'\{\s*(\w+)');

  /// Conecta el Singleton ClienteGraphQL a este servidor simulado.
  void instalar() => ClienteGraphQL().clienteHttp = MockClient(_responder);

  List<Map<String, dynamic>> variablesDe(String campo) =>
      [for (final p in peticiones) if (p.campo == campo) p.variables];

  Future<http.Response> _responder(http.Request request) async {
    final cuerpo = jsonDecode(request.body) as Map<String, dynamic>;
    final campo = _campoRaiz.firstMatch(cuerpo['query'] as String)!.group(1)!;
    final variables = (cuerpo['variables'] as Map<String, dynamic>?) ?? {};
    peticiones.add((campo: campo, variables: variables));

    final resolver = resolvers[campo];
    if (resolver == null) {
      return _json({'errors': [{'message': 'Campo no simulado: $campo'}]}, 400);
    }
    try {
      return _json({'data': {campo: resolver(variables)}});
    } on ErrorSimulado catch (e) {
      return _json({'errors': [{'message': e.mensaje}], 'data': {campo: null}});
    }
  }

  static http.Response _json(Object cuerpo, [int estado = 200]) => http.Response(
        jsonEncode(cuerpo),
        estado,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}

Map<String, dynamic> libroJson({
  String isbn = '978-9584276193',
  String titulo = 'Delirio',
  String autor = 'Laura Restrepo',
  num precio = 55000,
  int numeroPaginas = 352,
  String fechaPublicacion = '2004-03-01T00:00:00',
  String genero = 'FICCION',
}) =>
    {
      'isbn': isbn,
      'titulo': titulo,
      'autor': autor,
      'precio': precio,
      'numeroPaginas': numeroPaginas,
      'fechaPublicacion': fechaPublicacion,
      'genero': genero,
    };

Map<String, dynamic> ejemplarJson({
  String codigo = 'EJ-001',
  String estado = 'DISPONIBLE',
  String ubicacion = 'Estante A1',
  String fechaIngreso = '2024-02-10T09:00:00',
  num precioReposicion = 65000,
  String isbnLibro = '978-0307474728',
}) =>
    {
      'codigo': codigo,
      'estado': estado,
      'ubicacion': ubicacion,
      'fechaIngreso': fechaIngreso,
      'precioReposicion': precioReposicion,
      'isbnLibro': isbnLibro,
    };
