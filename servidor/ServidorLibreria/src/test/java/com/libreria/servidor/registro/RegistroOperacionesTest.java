package com.libreria.servidor.registro;

import com.libreria.servidor.registro.RegistroOperaciones.Operacion;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/** Pruebas del texto que el servidor escribe en consola por cada operación GraphQL. */
class RegistroOperacionesTest {

    @Test
    void identificaAlClientePorElEncabezado() {
        assertThat(RegistroOperaciones.nombreCliente("web")).isEqualTo("Cliente web");
        assertThat(RegistroOperaciones.nombreCliente(" MOVIL ")).isEqualTo("App móvil");
        assertThat(RegistroOperaciones.nombreCliente(null)).isEqualTo("Desconocido");
        assertThat(RegistroOperaciones.nombreCliente("graphiql")).isEqualTo("graphiql");
    }

    @Test
    void reconoceElTipoYLosCamposDeLaOperacion() {
        Operacion listar = Operacion.analizar("""
                query ($autor: String) {
                  librosFiltrados(autor: $autor) { isbn titulo }
                  totalLibrosFiltrados(autor: $autor)
                }""", null);
        Operacion crear = Operacion.analizar("mutation ($input: LibroInput!) { crearLibro(input: $input) { isbn } }", null);

        assertThat(listar).isEqualTo(new Operacion("consulta", List.of("librosFiltrados", "totalLibrosFiltrados")));
        assertThat(crear).isEqualTo(new Operacion("mutación", List.of("crearLibro")));
        assertThat(Operacion.analizar("{ revisionLibros }", null).esSoloRevision()).isTrue();
        assertThat(listar.esSoloRevision()).isFalse();
        assertThat(Operacion.analizar("esto no es graphql {", null).campos()).containsExactly("(no válida)");
    }

    @Test
    void laLineaMuestraClienteOperacionYDatosClave() {
        Map<String, Object> filtro = new HashMap<>();
        filtro.put("autor", "garcia");
        filtro.put("genero", null);
        Map<String, Object> creacion = Map.of("input",
                Map.of("isbn", "978-1", "titulo", "Pedro Páramo", "autor", "Juan Rulfo", "precio", 39000));

        assertThat(RegistroOperaciones.linea("Cliente web",
                new Operacion("consulta", List.of("librosFiltrados", "totalLibrosFiltrados")), filtro, null))
                .isEqualTo("Cliente web  | consulta librosFiltrados + totalLibrosFiltrados (autor=garcia)");
        assertThat(RegistroOperaciones.linea("App móvil", new Operacion("mutación", List.of("crearLibro")), creacion, null))
                .isEqualTo("App móvil    | mutación crearLibro (isbn=978-1, titulo=Pedro Páramo)");
        assertThat(RegistroOperaciones.linea("App móvil", new Operacion("mutación", List.of("eliminarLibro")),
                Map.of("isbn", "978-0307474728"), "No se puede eliminar el libro"))
                .endsWith("eliminarLibro (isbn=978-0307474728)  -> RECHAZADA: No se puede eliminar el libro");
    }
}
