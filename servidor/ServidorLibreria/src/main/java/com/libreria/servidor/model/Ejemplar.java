package com.libreria.servidor.model;

import com.libreria.servidor.enums.EstadoEjemplar;

import java.time.LocalDateTime;

/**
 * Clase_B (detalle) del diagrama: cada Ejemplar pertenece a exactamente un Libro (1..1),
 * y un Libro puede tener 0..* Ejemplares.
 * Atributos: codigo (String/ID), estado (EstadoEjemplar), ubicacion (String),
 * fechaIngreso (LocalDateTime), precioReposicion (double), isbnLibro (String - llave foránea lógica).
 */
public class Ejemplar {

    private String codigo;
    private EstadoEjemplar estado;
    private String ubicacion;
    private LocalDateTime fechaIngreso;
    private double precioReposicion;
    private String isbnLibro;

    public Ejemplar() {
    }

    public Ejemplar(String codigo, EstadoEjemplar estado, String ubicacion,
                     LocalDateTime fechaIngreso, double precioReposicion, String isbnLibro) {
        this.codigo = codigo;
        this.estado = estado;
        this.ubicacion = ubicacion;
        this.fechaIngreso = fechaIngreso;
        this.precioReposicion = precioReposicion;
        this.isbnLibro = isbnLibro;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public EstadoEjemplar getEstado() {
        return estado;
    }

    public void setEstado(EstadoEjemplar estado) {
        this.estado = estado;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public LocalDateTime getFechaIngreso() {
        return fechaIngreso;
    }

    public void setFechaIngreso(LocalDateTime fechaIngreso) {
        this.fechaIngreso = fechaIngreso;
    }

    public double getPrecioReposicion() {
        return precioReposicion;
    }

    public void setPrecioReposicion(double precioReposicion) {
        this.precioReposicion = precioReposicion;
    }

    public String getIsbnLibro() {
        return isbnLibro;
    }

    public void setIsbnLibro(String isbnLibro) {
        this.isbnLibro = isbnLibro;
    }

    @Override
    public String toString() {
        return "Ejemplar{codigo='" + codigo + "', estado=" + estado + ", ubicacion='" + ubicacion
                + "', fechaIngreso=" + fechaIngreso + ", precioReposicion=" + precioReposicion
                + ", isbnLibro='" + isbnLibro + "'}";
    }
}
