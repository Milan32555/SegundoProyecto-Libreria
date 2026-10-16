package com.libreria.servidor.model;

import com.libreria.servidor.enums.Genero;

import java.time.LocalDateTime;

/**
 * Clase_A (maestro) del diagrama: un Libro puede tener 0..* Ejemplares físicos en inventario.
 * Atributos: isbn (String), titulo (String), autor (String), precio (double),
 * numeroPaginas (int), fechaPublicacion (LocalDateTime), genero (Genero - "otro de elección").
 *
 * En la aplicación los Libros se construyen con {@link com.libreria.servidor.builder.LibroBuilder}
 * (patrón Builder) en lugar de usar directamente el constructor de 7 parámetros.
 */
public class Libro {

    private String isbn;
    private String titulo;
    private String autor;
    private double precio;
    private int numeroPaginas;
    private LocalDateTime fechaPublicacion;
    private Genero genero;

    public Libro() {
    }

    public Libro(String isbn, String titulo, String autor, double precio,
                 int numeroPaginas, LocalDateTime fechaPublicacion, Genero genero) {
        this.isbn = isbn;
        this.titulo = titulo;
        this.autor = autor;
        this.precio = precio;
        this.numeroPaginas = numeroPaginas;
        this.fechaPublicacion = fechaPublicacion;
        this.genero = genero;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
    }

    public double getPrecio() {
        return precio;
    }

    public void setPrecio(double precio) {
        this.precio = precio;
    }

    public int getNumeroPaginas() {
        return numeroPaginas;
    }

    public void setNumeroPaginas(int numeroPaginas) {
        this.numeroPaginas = numeroPaginas;
    }

    public LocalDateTime getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(LocalDateTime fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }

    public Genero getGenero() {
        return genero;
    }

    public void setGenero(Genero genero) {
        this.genero = genero;
    }

    @Override
    public String toString() {
        return "Libro{isbn='" + isbn + "', titulo='" + titulo + "', autor='" + autor
                + "', precio=" + precio + ", numeroPaginas=" + numeroPaginas
                + ", fechaPublicacion=" + fechaPublicacion + ", genero=" + genero + "}";
    }
}
