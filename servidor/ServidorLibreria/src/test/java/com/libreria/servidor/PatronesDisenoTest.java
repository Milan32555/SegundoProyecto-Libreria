package com.libreria.servidor;

import com.libreria.servidor.builder.EjemplarBuilder;
import com.libreria.servidor.builder.LibroBuilder;
import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.observer.ListadoObservable;
import com.libreria.servidor.observer.ObservadorListado;
import com.libreria.servidor.observer.RevisionListado;
import com.libreria.servidor.repositorio.RepositorioEjemplares;
import com.libreria.servidor.repositorio.RepositorioLibros;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** Verifica el comportamiento de los patrones Singleton, Builder y Observer. */
class PatronesDisenoTest {

    @Test
    void singletonDevuelveSiempreLaMismaInstancia() {
        assertThat(RepositorioLibros.getInstancia()).isSameAs(RepositorioLibros.getInstancia());
        assertThat(RepositorioEjemplares.getInstancia()).isSameAs(RepositorioEjemplares.getInstancia());
    }

    @Test
    void singletonCargaLosDatosDePrueba() {
        assertThat(RepositorioLibros.getInstancia().listar())
                .extracting(Libro::getIsbn).contains("978-0307474728", "978-8437609355", "978-8420401751");
        assertThat(RepositorioEjemplares.getInstancia().listar())
                .extracting(Ejemplar::getCodigo).contains("EJ-001", "EJ-002", "EJ-003");
    }

    @Test
    void listarDevuelveUnaCopiaParaProtegerLaColeccion() {
        List<Libro> copia = RepositorioLibros.getInstancia().listar();
        int tamanoOriginal = RepositorioLibros.getInstancia().listar().size();

        copia.clear();

        assertThat(RepositorioLibros.getInstancia().listar()).hasSize(tamanoOriginal);
    }

    @Test
    void builderAsignaTodosLosAtributosDelLibro() {
        LocalDateTime fecha = LocalDateTime.of(1955, 1, 1, 0, 0);

        Libro libro = new LibroBuilder().conIsbn("123").conTitulo("Pedro Páramo").conAutor("Juan Rulfo")
                .conPrecio(39000.5).conNumeroPaginas(124).conFechaPublicacion(fecha).conGenero(Genero.FICCION)
                .construir();

        assertThat(libro.getIsbn()).isEqualTo("123");
        assertThat(libro.getTitulo()).isEqualTo("Pedro Páramo");
        assertThat(libro.getAutor()).isEqualTo("Juan Rulfo");
        assertThat(libro.getPrecio()).isEqualTo(39000.5);
        assertThat(libro.getNumeroPaginas()).isEqualTo(124);
        assertThat(libro.getFechaPublicacion()).isEqualTo(fecha);
        assertThat(libro.getGenero()).isEqualTo(Genero.FICCION);
    }

    @Test
    void builderAsignaTodosLosAtributosDelEjemplar() {
        LocalDateTime fecha = LocalDateTime.of(2024, 2, 10, 9, 0);

        Ejemplar ejemplar = new EjemplarBuilder().conCodigo("EJ-X").conEstado(EstadoEjemplar.PRESTADO)
                .conUbicacion("Estante C3").conFechaIngreso(fecha).conPrecioReposicion(15000)
                .conNumeroPrestamos(12).conIsbnLibro("123").construir();

        assertThat(ejemplar.getCodigo()).isEqualTo("EJ-X");
        assertThat(ejemplar.getEstado()).isEqualTo(EstadoEjemplar.PRESTADO);
        assertThat(ejemplar.getUbicacion()).isEqualTo("Estante C3");
        assertThat(ejemplar.getFechaIngreso()).isEqualTo(fecha);
        assertThat(ejemplar.getPrecioReposicion()).isEqualTo(15000);
        assertThat(ejemplar.getNumeroPrestamos()).isEqualTo(12);
        assertThat(ejemplar.getIsbnLibro()).isEqualTo("123");
    }

    @Test
    void observableNotificaSoloALosSuscritos() {
        ListadoObservable<String> observable = new ListadoObservable<>();
        List<List<String>> recibidos = new ArrayList<>();
        ObservadorListado<String> observador = recibidos::add;

        observable.suscribir(observador);
        observable.notificarCambio(() -> List.of("a", "b"));
        observable.desuscribir(observador);
        observable.notificarCambio(() -> List.of("c"));

        assertThat(recibidos).containsExactly(List.of("a", "b"));
    }

    @Test
    void revisionListadoCuentaLosCambios() {
        ListadoObservable<String> observable = new ListadoObservable<>();
        RevisionListado<String> revision = new RevisionListado<>();
        observable.suscribir(revision);

        observable.notificarCambio(List::of);
        observable.notificarCambio(List::of);

        assertThat(revision.getRevision()).isEqualTo(2);
    }
}
