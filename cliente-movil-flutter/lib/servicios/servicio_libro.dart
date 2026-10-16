import '../modelos/libro.dart';
import 'cliente_graphql.dart';

const String _camposLibro =
    'isbn titulo autor precio numeroPaginas fechaPublicacion genero';

Future<List<Libro>> listarLibros() async {
  final data = await ejecutarGraphQL('query { libros { $_camposLibro } }');
  return (data['libros'] as List)
      .map((e) => Libro.desdeJson(e as Map<String, dynamic>))
      .toList();
}

Future<List<Libro>> listarLibrosFiltrados({String? autor, String? genero}) async {
  final data = await ejecutarGraphQL(
    '''query (\$autor: String, \$genero: Genero) {
         librosFiltrados(autor: \$autor, genero: \$genero) { $_camposLibro }
       }''',
    variables: {
      'autor': (autor == null || autor.isEmpty) ? null : autor,
      'genero': (genero == null || genero.isEmpty) ? null : genero,
    },
  );
  return (data['librosFiltrados'] as List)
      .map((e) => Libro.desdeJson(e as Map<String, dynamic>))
      .toList();
}

Future<Libro?> buscarLibroPorIsbn(String isbn) async {
  final data = await ejecutarGraphQL(
    'query (\$isbn: ID!) { libroPorIsbn(isbn: \$isbn) { $_camposLibro } }',
    variables: {'isbn': isbn},
  );
  final libro = data['libroPorIsbn'];
  return libro == null ? null : Libro.desdeJson(libro as Map<String, dynamic>);
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
  final data = await ejecutarGraphQL(
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
      }
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
  final data = await ejecutarGraphQL(
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
      }
    },
  );
  return Libro.desdeJson(data['actualizarLibro'] as Map<String, dynamic>);
}

Future<Libro> eliminarLibro(String isbn) async {
  final data = await ejecutarGraphQL(
    'mutation (\$isbn: ID!) { eliminarLibro(isbn: \$isbn) { $_camposLibro } }',
    variables: {'isbn': isbn},
  );
  return Libro.desdeJson(data['eliminarLibro'] as Map<String, dynamic>);
}
