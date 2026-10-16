package com.libreria.servidor.servicio;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.EjemplarUpdateInput;
import com.libreria.servidor.model.LibroInput;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/** Pruebas de la lógica de negocio de Ejemplar (detalle de Libro). */
class ServicioEjemplarTest {

    private static final LocalDateTime FECHA = LocalDateTime.of(2024, 5, 10, 14, 30);

    private ServicioLibro servicioLibro;
    private ServicioEjemplar servicio;
    private String isbn;

    @BeforeEach
    void setUp() {
        servicioLibro = new ServicioLibro();
        servicio = new ServicioEjemplar(servicioLibro);
        isbn = "TEST-" + UUID.randomUUID();
        servicioLibro.crear(new LibroInput(isbn, "Libro de prueba", "Autor", 30000, 100, FECHA, Genero.OTRO));
    }

    private static String codigoUnico() {
        return "EJ-" + UUID.randomUUID();
    }

    private EjemplarInput ejemplar(String codigo, EstadoEjemplar estado) {
        return new EjemplarInput(codigo, estado, "Estante A1", FECHA, 30000, isbn);
    }

    @Test
    void crearVinculaElEjemplarConSuLibro() {
        String codigo = codigoUnico();

        Ejemplar creado = servicio.crear(new EjemplarInput(" " + codigo + " ", EstadoEjemplar.DISPONIBLE,
                " Estante B2 ", FECHA, 15000, isbn.toLowerCase()));

        assertThat(creado.getCodigo()).isEqualTo(codigo);
        assertThat(creado.getUbicacion()).isEqualTo("Estante B2");
        // Se guarda el ISBN tal como está registrado en el libro, no como lo escribió el usuario.
        assertThat(creado.getIsbnLibro()).isEqualTo(isbn);
        assertThat(servicio.porLibro(isbn)).extracting(Ejemplar::getCodigo).containsExactly(codigo);
    }

    @Test
    void noPermiteEjemplaresDeUnLibroInexistente() {
        EjemplarInput huerfano = new EjemplarInput(codigoUnico(), EstadoEjemplar.DISPONIBLE, "X", FECHA, 1, "no-existe");

        assertThatThrownBy(() -> servicio.crear(huerfano))
                .isInstanceOf(LibreriaException.class)
                .hasMessageContaining("No existe un libro");
    }

    @Test
    void noPermiteCodigoDuplicado() {
        String codigo = codigoUnico();
        servicio.crear(ejemplar(codigo, EstadoEjemplar.DISPONIBLE));

        assertThatThrownBy(() -> servicio.crear(ejemplar(codigo.toLowerCase(), EstadoEjemplar.PRESTADO)))
                .hasMessageContaining("Ya existe un ejemplar");
    }

    @Test
    void validaLosAtributosObligatorios() {
        assertThatThrownBy(() -> servicio.crear(ejemplar("  ", EstadoEjemplar.DISPONIBLE)))
                .hasMessageContaining("código del ejemplar es obligatorio");
        assertThatThrownBy(() -> servicio.crear(ejemplar(codigoUnico(), null)))
                .hasMessageContaining("estado del ejemplar es obligatorio");
        assertThatThrownBy(() -> servicio.crear(
                new EjemplarInput(codigoUnico(), EstadoEjemplar.DISPONIBLE, "", FECHA, 1, isbn)))
                .hasMessageContaining("ubicación es obligatoria");
        assertThatThrownBy(() -> servicio.crear(
                new EjemplarInput(codigoUnico(), EstadoEjemplar.DISPONIBLE, "X", FECHA, -5, isbn)))
                .hasMessageContaining("mayor que cero");
        assertThatThrownBy(() -> servicio.crear(new EjemplarInput(codigoUnico(), EstadoEjemplar.DISPONIBLE, "X",
                LocalDateTime.now().plusHours(2), 1, isbn)))
                .hasMessageContaining("no puede ser futura");
    }

    @Test
    void filtraPorEstadoYPorLibro() {
        String disponible = codigoUnico();
        String prestado = codigoUnico();
        servicio.crear(ejemplar(disponible, EstadoEjemplar.DISPONIBLE));
        servicio.crear(ejemplar(prestado, EstadoEjemplar.PRESTADO));

        assertThat(servicio.filtrar(null, isbn))
                .extracting(Ejemplar::getCodigo).containsExactlyInAnyOrder(disponible, prestado);
        assertThat(servicio.filtrar(EstadoEjemplar.PRESTADO, isbn))
                .extracting(Ejemplar::getCodigo).containsExactly(prestado);
        assertThat(servicio.filtrar(EstadoEjemplar.PRESTADO, null))
                .allMatch(e -> e.getEstado() == EstadoEjemplar.PRESTADO);
        assertThat(servicio.filtrar(null, "  ")).hasSameSizeAs(servicio.listar());
    }

    @Test
    void actualizaYEliminaUnEjemplar() {
        String codigo = codigoUnico();
        servicio.crear(ejemplar(codigo, EstadoEjemplar.DISPONIBLE));
        LocalDateTime nuevaFecha = LocalDateTime.of(2023, 1, 1, 8, 0);

        Ejemplar actualizado = servicio.actualizar(codigo,
                new EjemplarUpdateInput(EstadoEjemplar.DANIADO, " Bodega ", nuevaFecha, 12345.5));

        assertThat(actualizado.getEstado()).isEqualTo(EstadoEjemplar.DANIADO);
        assertThat(actualizado.getUbicacion()).isEqualTo("Bodega");
        assertThat(actualizado.getFechaIngreso()).isEqualTo(nuevaFecha);
        assertThat(actualizado.getPrecioReposicion()).isEqualTo(12345.5);
        assertThat(actualizado.getIsbnLibro()).isEqualTo(isbn);

        assertThat(servicio.eliminar(codigo).getCodigo()).isEqualTo(codigo);
        assertThat(servicio.buscarPorCodigo(codigo)).isEmpty();
        assertThatThrownBy(() -> servicio.eliminar(codigo)).hasMessageContaining("No existe un ejemplar");
    }

    @Test
    void cadaCambioAumentaLaRevision() {
        int revisionInicial = servicio.revision();
        String codigo = codigoUnico();

        servicio.crear(ejemplar(codigo, EstadoEjemplar.DISPONIBLE));
        servicio.eliminar(codigo);

        assertThat(servicio.revision()).isEqualTo(revisionInicial + 2);
    }
}
