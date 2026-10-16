package com.libreria.servidor.builder;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.model.Ejemplar;

import java.time.LocalDateTime;

/** Patrón Builder para {@link Ejemplar}, análogo a {@link LibroBuilder}. */
public class EjemplarBuilder {

    private String codigo;
    private EstadoEjemplar estado;
    private String ubicacion;
    private LocalDateTime fechaIngreso;
    private double precioReposicion;
    private String isbnLibro;

    public EjemplarBuilder conCodigo(String codigo) {
        this.codigo = codigo;
        return this;
    }

    public EjemplarBuilder conEstado(EstadoEjemplar estado) {
        this.estado = estado;
        return this;
    }

    public EjemplarBuilder conUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
        return this;
    }

    public EjemplarBuilder conFechaIngreso(LocalDateTime fechaIngreso) {
        this.fechaIngreso = fechaIngreso;
        return this;
    }

    public EjemplarBuilder conPrecioReposicion(double precioReposicion) {
        this.precioReposicion = precioReposicion;
        return this;
    }

    public EjemplarBuilder conIsbnLibro(String isbnLibro) {
        this.isbnLibro = isbnLibro;
        return this;
    }

    public Ejemplar construir() {
        return new Ejemplar(codigo, estado, ubicacion, fechaIngreso, precioReposicion, isbnLibro);
    }
}
