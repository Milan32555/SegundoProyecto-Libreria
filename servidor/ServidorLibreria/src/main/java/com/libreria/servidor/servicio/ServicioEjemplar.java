package com.libreria.servidor.servicio;

import com.libreria.servidor.builder.EjemplarBuilder;
import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.EjemplarUpdateInput;
import com.libreria.servidor.observer.ListadoObservable;
import com.libreria.servidor.observer.ObservadorListado;
import com.libreria.servidor.repositorio.RepositorioEjemplares;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/** Lógica de negocio del CRUD de Ejemplar (clase detalle, 0..* por Libro). */
@Service
public class ServicioEjemplar {

    private final RepositorioEjemplares repositorio = RepositorioEjemplares.getInstancia();
    private final ListadoObservable<Ejemplar> observable = new ListadoObservable<>();
    private final ServicioLibro servicioLibro;

    public ServicioEjemplar(ServicioLibro servicioLibro) {
        this.servicioLibro = servicioLibro;
    }

    public void suscribir(ObservadorListado<Ejemplar> observador) {
        observable.suscribir(observador);
    }

    public void desuscribir(ObservadorListado<Ejemplar> observador) {
        observable.desuscribir(observador);
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

    public Ejemplar crear(EjemplarInput in) {
        if (in.codigo() == null || in.codigo().isBlank()) {
            throw new LibreriaException("El código del ejemplar es obligatorio.");
        }
        if (buscarPorCodigo(in.codigo()).isPresent()) {
            throw new LibreriaException("Ya existe un ejemplar con el código " + in.codigo().trim() + ".");
        }
        if (in.isbnLibro() == null || servicioLibro.buscarPorIsbn(in.isbnLibro()).isEmpty()) {
            throw new LibreriaException("No existe un libro con el ISBN " + in.isbnLibro() + ".");
        }
        validar(in.estado(), in.ubicacion(), in.fechaIngreso(), in.precioReposicion());

        Ejemplar ejemplar = new EjemplarBuilder()
                .conCodigo(in.codigo().trim())
                .conEstado(in.estado())
                .conUbicacion(in.ubicacion().trim())
                .conFechaIngreso(in.fechaIngreso())
                .conPrecioReposicion(in.precioReposicion())
                .conIsbnLibro(in.isbnLibro().trim())
                .construir();

        repositorio.agregar(ejemplar);
        notificarListado();
        return ejemplar;
    }

    public Ejemplar actualizar(String codigo, EjemplarUpdateInput in) {
        Ejemplar ejemplar = buscarPorCodigo(codigo)
                .orElseThrow(() -> new LibreriaException("No existe un ejemplar con el código " + codigo + "."));
        validar(in.estado(), in.ubicacion(), in.fechaIngreso(), in.precioReposicion());

        ejemplar.setEstado(in.estado());
        ejemplar.setUbicacion(in.ubicacion().trim());
        ejemplar.setFechaIngreso(in.fechaIngreso());
        ejemplar.setPrecioReposicion(in.precioReposicion());

        notificarListado();
        return ejemplar;
    }

    public Ejemplar eliminar(String codigo) {
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
