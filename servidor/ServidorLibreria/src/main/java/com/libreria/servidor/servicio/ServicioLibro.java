package com.libreria.servidor.servicio;

import com.libreria.servidor.builder.LibroBuilder;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.model.LibroInput;
import com.libreria.servidor.observer.ListadoObservable;
import com.libreria.servidor.observer.ObservadorListado;
import com.libreria.servidor.observer.RevisionListado;
import com.libreria.servidor.repositorio.RepositorioEjemplares;
import com.libreria.servidor.repositorio.RepositorioLibros;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Lógica de negocio (capa "Model" de MVC) del CRUD de Libro.
 * Usa el repositorio Singleton como única fuente de verdad de los datos en memoria,
 * y expone un ListadoObservable para que se puedan suscribir observadores a los cambios
 * del listado (patrón Observer, exigido en el caso de uso Listar).
 *
 * Las operaciones que modifican la colección son synchronized: "verificar y luego
 * modificar" (p. ej. que el ISBN no exista antes de agregarlo) debe ser atómico cuando
 * varios clientes hacen peticiones al mismo tiempo.
 */
@Service
public class ServicioLibro {

    private final RepositorioLibros repositorio = RepositorioLibros.getInstancia();
    private final RepositorioEjemplares repositorioEjemplares = RepositorioEjemplares.getInstancia();
    private final ListadoObservable<Libro> observable = new ListadoObservable<>();
    private final RevisionListado<Libro> revision = new RevisionListado<>();

    public ServicioLibro() {
        observable.suscribir(revision);
    }

    public void suscribir(ObservadorListado<Libro> observador) {
        observable.suscribir(observador);
    }

    public void desuscribir(ObservadorListado<Libro> observador) {
        observable.desuscribir(observador);
    }

    /** Número que aumenta con cada cambio de la colección (lo usa el Observer de los clientes). */
    public int revision() {
        return revision.getRevision();
    }

    public List<Libro> listar() {
        return repositorio.listar();
    }

    /** Listar objetos por filtro: autor (contiene, sin tildes/mayúsculas) y/o género exacto. */
    public List<Libro> filtrar(String autor, Genero genero) {
        String autorBuscado = normalizar(autor);
        return repositorio.listar().stream()
                .filter(l -> autorBuscado.isEmpty() || normalizar(l.getAutor()).contains(autorBuscado))
                .filter(l -> genero == null || l.getGenero() == genero)
                .toList();
    }

    /** Cuántos libros cumplen el filtro (la pantalla Listar muestra este total, no lo cuenta). */
    public int contarFiltrados(String autor, Genero genero) {
        return filtrar(autor, genero).size();
    }

    /** Consulta de UN SOLO objeto por isbn. */
    public Optional<Libro> buscarPorIsbn(String isbn) {
        if (isbn == null) {
            return Optional.empty();
        }
        String buscado = isbn.trim();
        return repositorio.listar().stream()
                .filter(l -> l.getIsbn().equalsIgnoreCase(buscado))
                .findFirst();
    }

    /** Consulta de UN SOLO objeto por título exacto (sin distinguir tildes ni mayúsculas). */
    public Optional<Libro> buscarPorTitulo(String titulo) {
        String buscado = normalizar(titulo);
        if (buscado.isEmpty()) {
            return Optional.empty();
        }
        return repositorio.listar().stream()
                .filter(l -> normalizar(l.getTitulo()).equals(buscado))
                .findFirst();
    }

    public synchronized Libro crear(LibroInput in) {
        if (in.isbn() == null || in.isbn().isBlank()) {
            throw new LibreriaException("El ISBN es obligatorio.");
        }
        if (buscarPorIsbn(in.isbn()).isPresent()) {
            throw new LibreriaException("Ya existe un libro con el ISBN " + in.isbn().trim() + ".");
        }
        validar(in.titulo(), in.autor(), in.precio(), in.numeroPaginas(), in.fechaPublicacion(), in.genero());

        Libro libro = new LibroBuilder()
                .conIsbn(in.isbn().trim())
                .conTitulo(in.titulo().trim())
                .conAutor(in.autor().trim())
                .conPrecio(in.precio())
                .conNumeroPaginas(in.numeroPaginas())
                .conFechaPublicacion(in.fechaPublicacion())
                .conGenero(in.genero())
                .construir();

        repositorio.agregar(libro);
        notificarListado();
        return libro;
    }

    /**
     * Actualiza el libro cuyo isbn viene en el input. El isbn es la clave del libro:
     * solo sirve para encontrarlo y no se modifica; el resto de los datos se reemplaza.
     */
    public synchronized Libro actualizar(LibroInput in) {
        if (in.isbn() == null || in.isbn().isBlank()) {
            throw new LibreriaException("El ISBN es obligatorio.");
        }
        Libro libro = buscarPorIsbn(in.isbn())
                .orElseThrow(() -> new LibreriaException("No existe un libro con el ISBN " + in.isbn().trim() + "."));
        validar(in.titulo(), in.autor(), in.precio(), in.numeroPaginas(), in.fechaPublicacion(), in.genero());

        libro.setTitulo(in.titulo().trim());
        libro.setAutor(in.autor().trim());
        libro.setPrecio(in.precio());
        libro.setNumeroPaginas(in.numeroPaginas());
        libro.setFechaPublicacion(in.fechaPublicacion());
        libro.setGenero(in.genero());

        notificarListado();
        return libro;
    }

    /**
     * Elimina el libro (previamente buscado) y lo devuelve para que el cliente confirme qué se borró.
     * Un Ejemplar siempre pertenece a un Libro (1..1), así que no se permite eliminar un libro
     * que todavía tiene ejemplares: quedarían "huérfanos".
     */
    public synchronized Libro eliminar(String isbn) {
        Libro libro = buscarPorIsbn(isbn)
                .orElseThrow(() -> new LibreriaException("No existe un libro con el ISBN " + isbn + "."));

        long ejemplares = repositorioEjemplares.listar().stream()
                .filter(e -> e.getIsbnLibro().equalsIgnoreCase(libro.getIsbn()))
                .count();
        if (ejemplares > 0) {
            throw new LibreriaException("No se puede eliminar el libro " + libro.getIsbn() + " porque tiene "
                    + ejemplares + " ejemplar(es) registrado(s). Elimine primero sus ejemplares.");
        }

        repositorio.eliminar(libro);
        notificarListado();
        return libro;
    }

    private void notificarListado() {
        observable.notificarCambio(repositorio::listar);
    }

    private void validar(String titulo, String autor, double precio, int paginas,
                          LocalDateTime fecha, Genero genero) {
        if (titulo == null || titulo.isBlank()) {
            throw new LibreriaException("El título es obligatorio.");
        }
        if (autor == null || autor.isBlank()) {
            throw new LibreriaException("El autor es obligatorio.");
        }
        if (precio <= 0) {
            throw new LibreriaException("El precio debe ser mayor que cero.");
        }
        if (paginas <= 0) {
            throw new LibreriaException("El número de páginas debe ser mayor que cero.");
        }
        if (fecha == null) {
            throw new LibreriaException("La fecha de publicación es obligatoria.");
        }
        if (fecha.isAfter(LocalDateTime.now())) {
            throw new LibreriaException("La fecha de publicación no puede ser futura.");
        }
        if (genero == null) {
            throw new LibreriaException("El género es obligatorio.");
        }
    }

    private static String normalizar(String texto) {
        if (texto == null) {
            return "";
        }
        return Normalizer.normalize(texto.trim().toLowerCase(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
    }
}
