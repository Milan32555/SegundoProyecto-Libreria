package com.libreria.servidor;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.graphql.test.autoconfigure.tester.AutoConfigureGraphQlTester;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.graphql.execution.ErrorType;
import org.springframework.graphql.test.tester.GraphQlTester;

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas de la API GraphQL completa (schema + controllers + servicios + escalar
 * LocalDateTime + manejador de errores), ejecutando las mismas operaciones que
 * envían los clientes React y Flutter.
 */
@SpringBootTest
@AutoConfigureGraphQlTester
class GraphQlApiTest {

    private static final String CREAR_LIBRO = """
            mutation ($input: LibroInput!) {
              crearLibro(input: $input) { isbn titulo autor precio numeroPaginas fechaPublicacion genero }
            }""";

    private static final String CREAR_EJEMPLAR = """
            mutation ($input: EjemplarInput!) {
              crearEjemplar(input: $input) { codigo estado isbnLibro libro { titulo } }
            }""";

    @Autowired
    private GraphQlTester graphQlTester;

    private static Map<String, Object> libroInput(String isbn, String fecha) {
        return Map.of("isbn", isbn, "titulo", "Libro GraphQL", "autor", "Autora API", "precio", 45000.5,
                "numeroPaginas", 210, "fechaPublicacion", fecha, "genero", "CIENCIA");
    }

    private String crearLibro() {
        String isbn = "API-" + UUID.randomUUID();
        graphQlTester.document(CREAR_LIBRO).variable("input", libroInput(isbn, "2020-01-02T03:04:05"))
                .execute().path("crearLibro.isbn").entity(String.class).isEqualTo(isbn);
        return isbn;
    }

    @Test
    void consultaUnLibroConSusEjemplares() {
        graphQlTester.document("""
                        { libroPorIsbn(isbn: "978-0307474728") {
                            titulo autor precio numeroPaginas fechaPublicacion genero ejemplares { codigo } } }""")
                .execute()
                .path("libroPorIsbn.titulo").entity(String.class).isEqualTo("Cien años de soledad")
                .path("libroPorIsbn.numeroPaginas").entity(Integer.class).isEqualTo(496)
                .path("libroPorIsbn.precio").entity(Double.class).isEqualTo(65000.0)
                .path("libroPorIsbn.fechaPublicacion").entity(String.class).isEqualTo("1967-05-30T00:00:00")
                .path("libroPorIsbn.genero").entity(String.class).isEqualTo("FICCION")
                .path("libroPorIsbn.ejemplares[*].codigo").entityList(String.class).contains("EJ-001", "EJ-002");
    }

    @Test
    void consultaUnLibroPorTitulo() {
        graphQlTester.document("{ libroPorTitulo(titulo: \"la voragine\") { isbn } }")
                .execute()
                .path("libroPorTitulo.isbn").entity(String.class).isEqualTo("978-8420471839");
    }

    @Test
    void consultaInexistenteDevuelveNull() {
        graphQlTester.document("{ libroPorIsbn(isbn: \"no-existe\") { isbn } ejemplarPorCodigo(codigo: \"no\") { codigo } }")
                .execute()
                .path("libroPorIsbn").valueIsNull()
                .path("ejemplarPorCodigo").valueIsNull();
    }

    @Test
    void consultaUnEjemplarConSuLibro() {
        graphQlTester.document("{ ejemplarPorCodigo(codigo: \"ej-003\") { codigo estado fechaIngreso libro { titulo } } }")
                .execute()
                .path("ejemplarPorCodigo.codigo").entity(String.class).isEqualTo("EJ-003")
                .path("ejemplarPorCodigo.fechaIngreso").entity(String.class).isEqualTo("2024-03-02T11:30:00")
                .path("ejemplarPorCodigo.libro.titulo").entity(String.class).isEqualTo("La vorágine");
    }

    @Test
    void listaConFiltrosDelLadoDelServidor() {
        graphQlTester.document("{ librosFiltrados(autor: \"garcia marquez\", genero: FICCION) { isbn } }")
                .execute()
                .path("librosFiltrados[*].isbn").entityList(String.class).containsExactly("978-0307474728");

        graphQlTester.document("{ ejemplaresFiltrados(estado: PRESTADO, isbnLibro: \"978-0307474728\") { codigo } }")
                .execute()
                .path("ejemplaresFiltrados[*].codigo").entityList(String.class).contains("EJ-002");
    }

    @Test
    void crudCompletoDeLibroPorGraphQl() {
        String isbn = "API-" + UUID.randomUUID();
        int revisionInicial = revisionLibros();

        graphQlTester.document(CREAR_LIBRO)
                .variable("input", libroInput(isbn, "2020-01-02T03:04"))   // formato de <input type="datetime-local">
                .execute()
                .path("crearLibro.isbn").entity(String.class).isEqualTo(isbn)
                .path("crearLibro.fechaPublicacion").entity(String.class).isEqualTo("2020-01-02T03:04:00");

        graphQlTester.document("""
                        mutation ($isbn: ID!, $input: LibroUpdateInput!) {
                          actualizarLibro(isbn: $isbn, input: $input) { titulo precio fechaPublicacion }
                        }""")
                .variable("isbn", isbn)
                .variable("input", Map.of("titulo", "Actualizado", "autor", "Otra", "precio", 1.5,
                        "numeroPaginas", 9, "fechaPublicacion", "2019-12-31T23:59:59Z", "genero", "OTRO"))
                .execute()
                .path("actualizarLibro.titulo").entity(String.class).isEqualTo("Actualizado")
                .path("actualizarLibro.precio").entity(Double.class).isEqualTo(1.5)
                .path("actualizarLibro.fechaPublicacion").entity(String.class).isEqualTo("2019-12-31T23:59:59");

        graphQlTester.document("mutation ($isbn: ID!) { eliminarLibro(isbn: $isbn) { isbn titulo } }")
                .variable("isbn", isbn)
                .execute()
                .path("eliminarLibro.titulo").entity(String.class).isEqualTo("Actualizado");

        assertThat(revisionLibros()).isGreaterThanOrEqualTo(revisionInicial + 3);
    }

    @Test
    void crudCompletoDeEjemplarPorGraphQl() {
        String isbn = crearLibro();
        String codigo = "API-EJ-" + UUID.randomUUID();

        graphQlTester.document(CREAR_EJEMPLAR)
                .variable("input", Map.of("codigo", codigo, "estado", "DISPONIBLE", "ubicacion", "Estante Q",
                        "fechaIngreso", "2024-06-01T10:00:00", "precioReposicion", 20000, "isbnLibro", isbn))
                .execute()
                .path("crearEjemplar.codigo").entity(String.class).isEqualTo(codigo)
                .path("crearEjemplar.libro.titulo").entity(String.class).isEqualTo("Libro GraphQL");

        graphQlTester.document("""
                        mutation ($codigo: ID!, $input: EjemplarUpdateInput!) {
                          actualizarEjemplar(codigo: $codigo, input: $input) { estado ubicacion }
                        }""")
                .variable("codigo", codigo)
                .variable("input", Map.of("estado", "PRESTADO", "ubicacion", "Mostrador",
                        "fechaIngreso", "2024-06-01T10:00:00", "precioReposicion", 21000))
                .execute()
                .path("actualizarEjemplar.estado").entity(String.class).isEqualTo("PRESTADO")
                .path("actualizarEjemplar.ubicacion").entity(String.class).isEqualTo("Mostrador");

        graphQlTester.document("mutation ($codigo: ID!) { eliminarEjemplar(codigo: $codigo) { codigo } }")
                .variable("codigo", codigo)
                .execute()
                .path("eliminarEjemplar.codigo").entity(String.class).isEqualTo(codigo);
    }

    @Test
    void erroresDeNegocioLleganAlClienteConMensajeLegible() {
        graphQlTester.document(CREAR_LIBRO).variable("input", libroInput("978-0307474728", "2020-01-01T00:00:00"))
                .execute()
                .errors()
                .satisfy(errores -> assertThat(errores).singleElement().satisfies(error -> {
                    assertThat(error.getMessage()).isEqualTo("Ya existe un libro con el ISBN 978-0307474728.");
                    assertThat(error.getErrorType()).isEqualTo(ErrorType.BAD_REQUEST);
                }));
    }

    @Test
    void noSePuedeEliminarUnLibroConEjemplares() {
        graphQlTester.document("mutation { eliminarLibro(isbn: \"978-0307474728\") { isbn } }")
                .execute()
                .errors()
                .satisfy(errores -> assertThat(errores).singleElement()
                        .satisfies(error -> assertThat(error.getMessage()).contains("ejemplar(es) registrado(s)")));
    }

    @Test
    void fechaInvalidaEsRechazada() {
        graphQlTester.document(CREAR_LIBRO).variable("input", libroInput("API-" + UUID.randomUUID(), "30/02/2020"))
                .execute()
                .errors()
                .satisfy(errores -> assertThat(errores).isNotEmpty());
    }

    private int revisionLibros() {
        return graphQlTester.document("{ revisionLibros }").execute()
                .path("revisionLibros").entity(Integer.class).get();
    }
}
