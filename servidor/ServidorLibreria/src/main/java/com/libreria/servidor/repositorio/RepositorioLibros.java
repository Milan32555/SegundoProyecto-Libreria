package com.libreria.servidor.repositorio;

import com.libreria.servidor.builder.LibroBuilder;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.model.Libro;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Patrón Singleton: existe una única instancia de este repositorio en toda la aplicación,
 * dueña exclusiva de la colección en memoria de Libros (tal como exige el enunciado:
 * "la aplicación debe almacenar la información en una Lista").
 *
 * El constructor es privado; el acceso es siempre a través de {@link #getInstancia()}.
 */
public final class RepositorioLibros {

    private static RepositorioLibros instancia;

    private final List<Libro> libros = new ArrayList<>();

    private RepositorioLibros() {
        cargarDatosDePrueba();
    }

    public static synchronized RepositorioLibros getInstancia() {
        if (instancia == null) {
            instancia = new RepositorioLibros();
        }
        return instancia;
    }

    public List<Libro> listar() {
        return new ArrayList<>(libros);
    }

    public void agregar(Libro libro) {
        libros.add(libro);
    }

    public boolean eliminar(Libro libro) {
        return libros.remove(libro);
    }

    private void cargarDatosDePrueba() {
        libros.add(new LibroBuilder()
                .conIsbn("978-0307474728").conTitulo("Cien años de soledad").conAutor("Gabriel García Márquez")
                .conPrecio(65000).conNumeroPaginas(496)
                .conFechaPublicacion(LocalDateTime.of(1967, 5, 30, 0, 0)).conGenero(Genero.FICCION)
                .construir());
        libros.add(new LibroBuilder()
                .conIsbn("978-8420471839").conTitulo("La vorágine").conAutor("José Eustasio Rivera")
                .conPrecio(48000).conNumeroPaginas(384)
                .conFechaPublicacion(LocalDateTime.of(1924, 11, 25, 0, 0)).conGenero(Genero.FICCION)
                .construir());
        libros.add(new LibroBuilder()
                .conIsbn("978-9584276193").conTitulo("Delirio").conAutor("Laura Restrepo")
                .conPrecio(55000).conNumeroPaginas(352)
                .conFechaPublicacion(LocalDateTime.of(2004, 3, 1, 0, 0)).conGenero(Genero.FICCION)
                .construir());
    }
}
