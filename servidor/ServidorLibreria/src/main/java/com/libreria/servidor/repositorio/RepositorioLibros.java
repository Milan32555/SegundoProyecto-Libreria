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
 * Los métodos son synchronized porque varios clientes pueden hacer peticiones a la vez.
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

    public synchronized List<Libro> listar() {
        return new ArrayList<>(libros);
    }

    public synchronized void agregar(Libro libro) {
        libros.add(libro);
    }

    public synchronized boolean eliminar(Libro libro) {
        return libros.remove(libro);
    }

    /**
     * Inventario inicial: literatura colombiana y latinoamericana. Los ISBN son de ediciones
     * reales (verificados en Open Library) y el número de páginas es el de esa edición; la fecha
     * es la de la primera publicación de la obra (día 1 cuando solo se conoce el año).
     * "Delirio" no tiene ejemplares: es el libro que sí se puede eliminar en la demostración.
     */
    private void cargarDatosDePrueba() {
        libros.add(libro("978-0307474728", "Cien años de soledad", "Gabriel García Márquez",
                65000, 496, LocalDateTime.of(1967, 5, 30, 0, 0), Genero.FICCION));
        libros.add(libro("978-8437609355", "La vorágine", "José Eustasio Rivera",
                48000, 390, LocalDateTime.of(1924, 11, 25, 0, 0), Genero.FICCION));
        libros.add(libro("978-8420401751", "Delirio", "Laura Restrepo",
                55000, 352, LocalDateTime.of(2004, 3, 1, 0, 0), Genero.FICCION));
        libros.add(libro("978-9589012338", "María", "Jorge Isaacs",
                39000, 340, LocalDateTime.of(1867, 1, 1, 0, 0), Genero.FICCION));
        libros.add(libro("978-9584215000", "El olvido que seremos", "Héctor Abad Faciolince",
                69000, 274, LocalDateTime.of(2006, 1, 1, 0, 0), Genero.NO_FICCION));
        libros.add(libro("978-9584239563", "Rosario Tijeras", "Jorge Franco",
                45000, 186, LocalDateTime.of(1999, 1, 1, 0, 0), Genero.FICCION));
        libros.add(libro("978-8483103913", "Los ejércitos", "Evelio Rosero",
                58000, 203, LocalDateTime.of(2007, 3, 1, 0, 0), Genero.FICCION));
        libros.add(libro("978-9681649500", "Pedro Páramo", "Juan Rulfo",
                42000, 129, LocalDateTime.of(1955, 3, 19, 0, 0), Genero.FICCION));
        libros.add(libro("978-8420633121", "Ficciones", "Jorge Luis Borges",
                52000, 218, LocalDateTime.of(1944, 1, 1, 0, 0), Genero.FICCION));
        libros.add(libro("978-8437624747", "Rayuela", "Julio Cortázar",
                89000, 746, LocalDateTime.of(1963, 6, 28, 0, 0), Genero.FICCION));
        libros.add(libro("978-9580469117", "Veinte poemas de amor y una canción desesperada", "Pablo Neruda",
                35000, 151, LocalDateTime.of(1924, 6, 1, 0, 0), Genero.POESIA));
        libros.add(libro("978-8432311451", "Las venas abiertas de América Latina", "Eduardo Galeano",
                79000, 379, LocalDateTime.of(1971, 1, 1, 0, 0), Genero.HISTORIA));
    }

    private static Libro libro(String isbn, String titulo, String autor, double precio, int paginas,
                               LocalDateTime publicacion, Genero genero) {
        return new LibroBuilder()
                .conIsbn(isbn).conTitulo(titulo).conAutor(autor)
                .conPrecio(precio).conNumeroPaginas(paginas)
                .conFechaPublicacion(publicacion).conGenero(genero)
                .construir();
    }
}
