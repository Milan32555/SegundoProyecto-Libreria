import '../modelos/libro.dart';
import 'cliente_graphql.dart';

const String _camposLibro = 'isbn titulo autor precio numeroPaginas fechaPublicacion genero';

List<Libro> _aLibros(Object? lista) => (lista as List).map((e) => Libro.desdeJson(e as Map<String, dynamic>)).toList();

Libro? _aLibroOpcional(Object? json) => json == null ? null : Libro.desdeJson(json as Map<String, dynamic>);

Future<List<Libro>> listarLibros() async {
  final data = await ClienteGraphQL().ejecutar('query { libros { $_camposLibro } }');
  return _aLibros(data['libros']);
}

/// Listar con filtro: el filtrado se hace del lado del servidor.
Future<List<Libro>> listarLibrosFiltrados({String? autor, String? genero}) async {
  final data = await ClienteGraphQL().ejecutar(
    '''query (\$autor: String, \$genero: Genero) {
         librosFiltrados(autor: \$autor, genero: \$genero) { $_camposLibro }
       }''',
    variables: {
      'autor': (autor == null || autor.trim().isEmpty) ? null : autor.trim(),
      'genero': (genero == null || genero.isEmpty) ? null : genero,
    },
  );
  return _aLibros(data['librosFiltrados']);
}

Future<Libro?> buscarLibroPorIsbn(String isbn) async {
  final data = await ClienteGraphQL().ejecutar(
    'query (\$isbn: ID!) { libroPorIsbn(isbn: \$isbn) { $_camposLibro } }',
    variables: {'isbn': isbn.trim()},
  );
  return _aLibroOpcional(data['libroPorIsbn']);
}

Future<Libro?> buscarLibroPorTitulo(String titulo) async {
  final data = await ClienteGraphQL().ejecutar(
    'query (\$titulo: String!) { libroPorTitulo(titulo: \$titulo) { $_camposLibro } }',
    variables: {'titulo': titulo.trim()},
  );
  return _aLibroOpcional(data['libroPorTitulo']);
}

/// Número de revisión de la colección en el servidor (lo usa el Observer de Listar).
Future<int> consultarRevisionLibros() async {
  final data = await ClienteGraphQL().ejecutar('query { revisionLibros }');
  return data['revisionLibros'] as int;
}

Future<Libro> crearLibro({
  required String isbn,
  required String titulo,
  required String autor,
  required double precio,
  required int numeroPaginas,
  required String fechaPublicacion,
  required String genero,
}) async {
  final data = await ClienteGraphQL().ejecutar(
    'mutation (\$input: LibroInput!) { crearLibro(input: \$input) { $_camposLibro } }',
    variables: {
      'input': {
        'isbn': isbn,
        'titulo': titulo,
        'autor': autor,
        'precio': precio,
        'numeroPaginas': numeroPaginas,
        'fechaPublicacion': fechaPublicacion,
        'genero': genero,
      },
    },
  );
  return Libro.desdeJson(data['crearLibro'] as Map<String, dynamic>);
}

Future<Libro> actualizarLibro({
  required String isbn,
  required String titulo,
  required String autor,
  required double precio,
  required int numeroPaginas,
  required String fechaPublicacion,
  required String genero,
}) async {
  final data = await ClienteGraphQL().ejecutar(
    '''mutation (\$isbn: ID!, \$input: LibroUpdateInput!) {
         actualizarLibro(isbn: \$isbn, input: \$input) { $_camposLibro }
       }''',
    variables: {
      'isbn': isbn,
      'input': {
        'titulo': titulo,
        'autor': autor,
        'precio': precio,
        'numeroPaginas': numeroPaginas,
        'fechaPublicacion': fechaPublicacion,
        'genero': genero,
      },
    },
  );
  return Libro.desdeJson(data['actualizarLibro'] as Map<String, dynamic>);
}

Future<Libro> eliminarLibro(String isbn) async {
  final data = await ClienteGraphQL().ejecutar(
    'mutation (\$isbn: ID!) { eliminarLibro(isbn: \$isbn) { $_camposLibro } }',
    variables: {'isbn': isbn},
  );
  return Libro.desdeJson(data['eliminarLibro'] as Map<String, dynamic>);
}
