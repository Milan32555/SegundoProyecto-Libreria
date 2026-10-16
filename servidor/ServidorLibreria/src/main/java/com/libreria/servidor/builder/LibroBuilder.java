package com.libreria.servidor.builder;

import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.model.Libro;

import java.time.LocalDateTime;

/**
 * Patrón Builder: construye un {@link Libro} paso a paso de forma fluida,
 * en vez de usar un constructor con 7 parámetros posicionales.
 *
 * Uso: new LibroBuilder().conIsbn(...).conTitulo(...)....construir();
 */
public class LibroBuilder {

    private String isbn;
    private String titulo;
    private String autor;
    private double precio;
    private int numeroPaginas;
    private LocalDateTime fechaPublicacion;
    private Genero genero;

    public LibroBuilder conIsbn(String isbn) {
        this.isbn = isbn;
        return this;
    }

    public LibroBuilder conTitulo(String titulo) {
        this.titulo = titulo;
        return this;
    }

    public LibroBuilder conAutor(String autor) {
        this.autor = autor;
        return this;
    }

    public LibroBuilder conPrecio(double precio) {
        this.precio = precio;
        return this;
    }

    public LibroBuilder conNumeroPaginas(int numeroPaginas) {
        this.numeroPaginas = numeroPaginas;
        return this;
    }

    public LibroBuilder conFechaPublicacion(LocalDateTime fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
        return this;
    }

    public LibroBuilder conGenero(Genero genero) {
        this.genero = genero;
        return this;
    }

    public Libro construir() {
        return new Libro(isbn, titulo, autor, precio, numeroPaginas, fechaPublicacion, genero);
    }
}
