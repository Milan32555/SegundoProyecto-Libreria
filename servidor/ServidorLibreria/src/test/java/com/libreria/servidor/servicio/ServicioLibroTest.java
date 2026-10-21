package com.libreria.servidor.servicio;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.model.LibroInput;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Pruebas de la lógica de negocio de Libro. Los repositorios son Singleton (comparten
 * la colección con el resto de pruebas), por eso cada prueba usa ISBN únicos.
 */
class ServicioLibroTest {

    private static final LocalDateTime FECHA = LocalDateTime.of(2001, 9, 11, 0, 0);

    private ServicioLibro servicio;

    @BeforeEach
    void setUp() {
        servicio = new ServicioLibro();
    }

    private static String isbnUnico() {
        return "TEST-" + UUID.randomUUID();
    }

    private static LibroInput libro(String isbn, String titulo, String autor, Genero genero) {
        return new LibroInput(isbn, titulo, autor, 42000, 250, FECHA, genero);
    }

    @Test
    void crearAgregaElLibroALaColeccion() {
        String isbn = isbnUnico();

        Libro creado = servicio.crear(libro("  " + isbn + "  ", " El túnel ", " Ernesto Sábato ", Genero.FICCION));

        assertThat(creado.getIsbn()).isEqualTo(isbn);
        assertThat(creado.getTitulo()).isEqualTo("El túnel");
        assertThat(creado.getAutor()).isEqualTo("Ernesto Sábato");
        assertThat(servicio.listar()).extracting(Libro::getIsbn).contains(isbn);
    }

    @Test
    void noPermiteIsbnDuplicadoSinImportarMayusculas() {
        String isbn = isbnUnico();
        servicio.crear(libro(isbn, "Uno", "Autor", Genero.OTRO));

        assertThatThrownBy(() -> servicio.crear(libro(isbn.toLowerCase(), "Dos", "Autor", Genero.OTRO)))
                .isInstanceOf(LibreriaException.class)
                .hasMessageContaining("Ya existe un libro");
    }

    @Test
    void validaLosAtributosObligatorios() {
        assertThatThrownBy(() -> servicio.crear(libro(" ", "T", "A", Genero.OTRO)))
                .hasMessageContaining("ISBN es obligatorio");
        assertThatThrownBy(() -> servicio.crear(libro(isbnUnico(), " ", "A", Genero.OTRO)))
                .hasMessageContaining("título es obligatorio");
        assertThatThrownBy(() -> servicio.crear(libro(isbnUnico(), "T", null, Genero.OTRO)))
                .hasMessageContaining("autor es obligatorio");
        assertThatThrownBy(() -> servicio.crear(libro(isbnUnico(), "T", "A", null)))
                .hasMessageContaining("género es obligatorio");
        assertThatThrownBy(() -> servicio.crear(new LibroInput(isbnUnico(), "T", "A", 0, 10, FECHA, Genero.OTRO)))
                .hasMessageContaining("precio debe ser mayor que cero");
        assertThatThrownBy(() -> servicio.crear(new LibroInput(isbnUnico(), "T", "A", 10, 0, FECHA, Genero.OTRO)))
                .hasMessageContaining("páginas debe ser mayor que cero");
        assertThatThrownBy(() -> servicio.crear(
                new LibroInput(isbnUnico(), "T", "A", 10, 10, LocalDateTime.now().plusDays(1), Genero.OTRO)))
                .hasMessageContaining("no puede ser futura");
    }

    @Test
    void filtraPorAutorSinTildesNiMayusculasYPorGenero() {
        String isbnPoesia = isbnUnico();
        String isbnHistoria = isbnUnico();
        String autor = "Autora Ñandú " + UUID.randomUUID();
        servicio.crear(libro(isbnPoesia, "Poemas", autor, Genero.POESIA));
        servicio.crear(libro(isbnHistoria, "Crónicas", autor, Genero.HISTORIA));

        String autorSinTildes = autor.toUpperCase().replace("Ú", "U");
        assertThat(servicio.filtrar(autorSinTildes, null))
                .extracting(Libro::getIsbn).containsExactlyInAnyOrder(isbnPoesia, isbnHistoria);
        assertThat(servicio.filtrar(autorSinTildes, Genero.POESIA))
                .extracting(Libro::getIsbn).containsExactly(isbnPoesia);
        assertThat(servicio.filtrar(null, null)).hasSameSizeAs(servicio.listar());

        // El total que muestra la pantalla Listar lo calcula el servidor con el mismo filtro.
        assertThat(servicio.contarFiltrados(autorSinTildes, null)).isEqualTo(2);
        assertThat(servicio.contarFiltrados(autorSinTildes, Genero.POESIA)).isEqualTo(1);
        assertThat(servicio.contarFiltrados(null, null)).isEqualTo(servicio.listar().size());
    }

    @Test
    void buscaUnSoloLibroPorIsbnOPorTitulo() {
        String isbn = isbnUnico();
        String titulo = "Título Único " + UUID.randomUUID();
        servicio.crear(libro(isbn, titulo, "Autor", Genero.CIENCIA));

        assertThat(servicio.buscarPorIsbn(" " + isbn.toLowerCase() + " ")).map(Libro::getIsbn).contains(isbn);
        assertThat(servicio.buscarPorTitulo(titulo.toUpperCase().replace("Í", "I"))).map(Libro::getIsbn).contains(isbn);
        assertThat(servicio.buscarPorIsbn("no-existe")).isEmpty();
        assertThat(servicio.buscarPorTitulo("  ")).isEmpty();
        assertThat(servicio.buscarPorIsbn(null)).isEmpty();
    }

    @Test
    void actualizaLosAtributosEditables() {
        String isbn = isbnUnico();
        servicio.crear(libro(isbn, "Viejo", "Autor", Genero.OTRO));
        LocalDateTime nuevaFecha = LocalDateTime.of(1999, 1, 2, 3, 4);

        Libro actualizado = servicio.actualizar(
                new LibroInput(" " + isbn.toLowerCase() + " ", "Nuevo", "Otro Autor", 99000.5, 321, nuevaFecha, Genero.HISTORIA));

        assertThat(actualizado.getIsbn()).isEqualTo(isbn);
        assertThat(actualizado.getTitulo()).isEqualTo("Nuevo");
        assertThat(actualizado.getAutor()).isEqualTo("Otro Autor");
        assertThat(actualizado.getPrecio()).isEqualTo(99000.5);
        assertThat(actualizado.getNumeroPaginas()).isEqualTo(321);
        assertThat(actualizado.getFechaPublicacion()).isEqualTo(nuevaFecha);
        assertThat(actualizado.getGenero()).isEqualTo(Genero.HISTORIA);
        assertThat(servicio.buscarPorIsbn(isbn)).map(Libro::getTitulo).contains("Nuevo");
    }

    @Test
    void actualizarOEliminarUnLibroInexistenteFalla() {
        assertThatThrownBy(() -> servicio.actualizar(new LibroInput("no-existe", "T", "A", 1, 1, FECHA, Genero.OTRO)))
                .hasMessageContaining("No existe");
        assertThatThrownBy(() -> servicio.actualizar(new LibroInput("  ", "T", "A", 1, 1, FECHA, Genero.OTRO)))
                .hasMessageContaining("El ISBN es obligatorio");
        assertThatThrownBy(() -> servicio.eliminar("no-existe")).hasMessageContaining("No existe");
    }

    @Test
    void eliminaUnLibroSinEjemplares() {
        String isbn = isbnUnico();
        servicio.crear(libro(isbn, "Efímero", "Autor", Genero.OTRO));

        Libro eliminado = servicio.eliminar(isbn);

        assertThat(eliminado.getIsbn()).isEqualTo(isbn);
        assertThat(servicio.buscarPorIsbn(isbn)).isEmpty();
    }

    @Test
    void noEliminaUnLibroQueTieneEjemplares() {
        String isbn = isbnUnico();
        servicio.crear(libro(isbn, "Con ejemplares", "Autor", Genero.OTRO));
        ServicioEjemplar servicioEjemplar = new ServicioEjemplar(servicio);
        String codigo = "EJ-" + UUID.randomUUID();
        servicioEjemplar.crear(new EjemplarInput(codigo, EstadoEjemplar.DISPONIBLE, "Estante Z",
                FECHA, 1000, 0, isbn));

        assertThatThrownBy(() -> servicio.eliminar(isbn))
                .isInstanceOf(LibreriaException.class)
                .hasMessageContaining("tiene 1 ejemplar(es)");
        assertThat(servicio.buscarPorIsbn(isbn)).isPresent();

        servicioEjemplar.eliminar(codigo);
        assertThat(servicio.eliminar(isbn).getIsbn()).isEqualTo(isbn);
    }

    @Test
    void cadaCambioNotificaALosObservadoresYAumentaLaRevision() {
        int[] notificaciones = {0};
        servicio.suscribir(listado -> notificaciones[0]++);
        int revisionInicial = servicio.revision();
        String isbn = isbnUnico();

        servicio.crear(libro(isbn, "Observado", "Autor", Genero.OTRO));
        servicio.actualizar(new LibroInput(isbn, "Observado 2", "Autor", 1, 1, FECHA, Genero.OTRO));
        servicio.eliminar(isbn);

        assertThat(notificaciones[0]).isEqualTo(3);
        assertThat(servicio.revision()).isEqualTo(revisionInicial + 3);
    }

    @Test
    void unaOperacionFallidaNoNotifica() {
        int revisionInicial = servicio.revision();

        assertThatThrownBy(() -> servicio.crear(libro(isbnUnico(), "", "A", Genero.OTRO)));

        assertThat(servicio.revision()).isEqualTo(revisionInicial);
    }
}
