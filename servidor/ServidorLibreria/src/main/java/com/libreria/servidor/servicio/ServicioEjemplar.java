package com.libreria.servidor.servicio;

import com.libreria.servidor.builder.EjemplarBuilder;
import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.EjemplarUpdateInput;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.observer.ListadoObservable;
import com.libreria.servidor.observer.ObservadorListado;
import com.libreria.servidor.observer.RevisionListado;
import com.libreria.servidor.repositorio.RepositorioEjemplares;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Lógica de negocio del CRUD de Ejemplar (clase detalle, 0..* por Libro).
 * Mismo diseño que {@link ServicioLibro}: repositorio Singleton, Observer y
 * operaciones de escritura synchronized.
 */
@Service
public class ServicioEjemplar {

    private final RepositorioEjemplares repositorio = RepositorioEjemplares.getInstancia();
    private final ListadoObservable<Ejemplar> observable = new ListadoObservable<>();
    private final RevisionListado<Ejemplar> revision = new RevisionListado<>();
    private final ServicioLibro servicioLibro;

    public ServicioEjemplar(ServicioLibro servicioLibro) {
        this.servicioLibro = servicioLibro;
        observable.suscribir(revision);
    }

    public void suscribir(ObservadorListado<Ejemplar> observador) {
        observable.suscribir(observador);
    }

    public void desuscribir(ObservadorListado<Ejemplar> observador) {
        observable.desuscribir(observador);
    }

    /** Número que aumenta con cada cambio de la colección (lo usa el Observer de los clientes). */
    public int revision() {
        return revision.getRevision();
    }

    public List<Ejemplar> listar() {
        return repositorio.listar();
    }

    /** Listar por filtro: estado y/o isbn del libro al que pertenece. */
    public List<Ejemplar> filtrar(EstadoEjemplar estado, String isbnLibro) {
        return repositorio.listar().stream()
                .filter(e -> estado == null || e.getEstado() == estado)
                .filter(e -> isbnLibro == null || isbnLibro.isBlank()
                        || e.getIsbnLibro().equalsIgnoreCase(isbnLibro.trim()))
                .toList();
    }

    /** Cuántos ejemplares cumplen el filtro (la pantalla Listar muestra este total, no lo cuenta). */
    public int contarFiltrados(EstadoEjemplar estado, String isbnLibro) {
        return filtrar(estado, isbnLibro).size();
    }

    public List<Ejemplar> porLibro(String isbnLibro) {
        return filtrar(null, isbnLibro);
    }

    public Optional<Ejemplar> buscarPorCodigo(String codigo) {
        if (codigo == null) {
            return Optional.empty();
        }
        String buscado = codigo.trim();
        return repositorio.listar().stream()
                .filter(e -> e.getCodigo().equalsIgnoreCase(buscado))
                .findFirst();
    }

    public synchronized Ejemplar crear(EjemplarInput in) {
        if (in.codigo() == null || in.codigo().isBlank()) {
            throw new LibreriaException("El código del ejemplar es obligatorio.");
        }
        if (buscarPorCodigo(in.codigo()).isPresent()) {
            throw new LibreriaException("Ya existe un ejemplar con el código " + in.codigo().trim() + ".");
        }
        Libro libro = servicioLibro.buscarPorIsbn(in.isbnLibro())
                .orElseThrow(() -> new LibreriaException("No existe un libro con el ISBN " + in.isbnLibro() + "."));
        validar(in.estado(), in.ubicacion(), in.fechaIngreso(), in.precioReposicion());
        if (in.numeroPrestamos() < 0) {
            throw new LibreriaException("El número de préstamos no puede ser negativo.");
        }

        Ejemplar ejemplar = new EjemplarBuilder()
                .conCodigo(in.codigo().trim())
                .conEstado(in.estado())
                .conUbicacion(in.ubicacion().trim())
                .conFechaIngreso(in.fechaIngreso())
                .conPrecioReposicion(in.precioReposicion())
                .conNumeroPrestamos(in.numeroPrestamos())
                .conIsbnLibro(libro.getIsbn())
                .construir();

        repositorio.agregar(ejemplar);
        notificarListado();
        return ejemplar;
    }

    /**
     * Actualiza un ejemplar. El número de préstamos no llega del cliente: lo lleva el servidor.
     * Regla de negocio: cada vez que el ejemplar pasa de otro estado a PRESTADO, se registra
     * un préstamo más (seguir en PRESTADO o cambiar a otro estado no lo modifica).
     */
    public synchronized Ejemplar actualizar(String codigo, EjemplarUpdateInput in) {
        Ejemplar ejemplar = buscarPorCodigo(codigo)
                .orElseThrow(() -> new LibreriaException("No existe un ejemplar con el código " + codigo + "."));
        validar(in.estado(), in.ubicacion(), in.fechaIngreso(), in.precioReposicion());

        boolean seAcabaDePrestar = ejemplar.getEstado() != EstadoEjemplar.PRESTADO
                && in.estado() == EstadoEjemplar.PRESTADO;
        if (seAcabaDePrestar) {
            ejemplar.setNumeroPrestamos(ejemplar.getNumeroPrestamos() + 1);
        }
        ejemplar.setEstado(in.estado());
        ejemplar.setUbicacion(in.ubicacion().trim());
        ejemplar.setFechaIngreso(in.fechaIngreso());
        ejemplar.setPrecioReposicion(in.precioReposicion());

        notificarListado();
        return ejemplar;
    }

    public synchronized Ejemplar eliminar(String codigo) {
        Ejemplar ejemplar = buscarPorCodigo(codigo)
                .orElseThrow(() -> new LibreriaException("No existe un ejemplar con el código " + codigo + "."));
        repositorio.eliminar(ejemplar);
        notificarListado();
        return ejemplar;
    }

    private void notificarListado() {
        observable.notificarCambio(repositorio::listar);
    }

    private void validar(EstadoEjemplar estado, String ubicacion, LocalDateTime fechaIngreso, double precio) {
        if (estado == null) {
            throw new LibreriaException("El estado del ejemplar es obligatorio.");
        }
        if (ubicacion == null || ubicacion.isBlank()) {
            throw new LibreriaException("La ubicación es obligatoria.");
        }
        if (fechaIngreso == null) {
            throw new LibreriaException("La fecha de ingreso es obligatoria.");
        }
        if (fechaIngreso.isAfter(LocalDateTime.now())) {
            throw new LibreriaException("La fecha de ingreso no puede ser futura.");
        }
        if (precio <= 0) {
            throw new LibreriaException("El precio de reposición debe ser mayor que cero.");
        }
    }
}
