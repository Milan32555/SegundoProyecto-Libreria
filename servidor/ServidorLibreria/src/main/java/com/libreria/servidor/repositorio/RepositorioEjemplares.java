package com.libreria.servidor.repositorio;

import com.libreria.servidor.builder.EjemplarBuilder;
import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.model.Ejemplar;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Patrón Singleton: única instancia dueña de la colección en memoria de Ejemplares. */
public final class RepositorioEjemplares {

    private static RepositorioEjemplares instancia;

    private final List<Ejemplar> ejemplares = new ArrayList<>();

    private RepositorioEjemplares() {
        cargarDatosDePrueba();
    }

    public static synchronized RepositorioEjemplares getInstancia() {
        if (instancia == null) {
            instancia = new RepositorioEjemplares();
        }
        return instancia;
    }

    public synchronized List<Ejemplar> listar() {
        return new ArrayList<>(ejemplares);
    }

    public synchronized void agregar(Ejemplar ejemplar) {
        ejemplares.add(ejemplar);
    }

    public synchronized boolean eliminar(Ejemplar ejemplar) {
        return ejemplares.remove(ejemplar);
    }

    private void cargarDatosDePrueba() {
        ejemplares.add(new EjemplarBuilder()
                .conCodigo("EJ-001").conEstado(EstadoEjemplar.DISPONIBLE).conUbicacion("Estante A1")
                .conFechaIngreso(LocalDateTime.of(2024, 2, 10, 9, 0)).conPrecioReposicion(65000)
                .conIsbnLibro("978-0307474728").construir());
        ejemplares.add(new EjemplarBuilder()
                .conCodigo("EJ-002").conEstado(EstadoEjemplar.PRESTADO).conUbicacion("Estante A1")
                .conFechaIngreso(LocalDateTime.of(2024, 2, 10, 9, 5)).conPrecioReposicion(65000)
                .conIsbnLibro("978-0307474728").construir());
        ejemplares.add(new EjemplarBuilder()
                .conCodigo("EJ-003").conEstado(EstadoEjemplar.DISPONIBLE).conUbicacion("Estante B2")
                .conFechaIngreso(LocalDateTime.of(2024, 3, 2, 11, 30)).conPrecioReposicion(48000)
                .conIsbnLibro("978-8420471839").construir());
    }
}
