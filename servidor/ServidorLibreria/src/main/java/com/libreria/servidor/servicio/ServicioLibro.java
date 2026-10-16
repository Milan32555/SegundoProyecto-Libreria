package com.libreria.servidor.servicio;

import com.libreria.servidor.builder.LibroBuilder;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.excepciones.LibreriaException;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.model.LibroInput;
import com.libreria.servidor.model.LibroUpdateInput;
import com.libreria.servidor.observer.ListadoObservable;
import com.libreria.servidor.observer.ObservadorListado;
import com.libreria.servidor.repositorio.RepositorioLibros;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Lógica de negocio (capa "Model" de MVC) del CRUD de Libro.
 * Usa el repositorio Singleton como única fuente de verdad de los datos en memoria,
 * y expone un ListadoObservable para que los clientes puedan suscribirse a cambios
 * en el listado (patrón Observer, exigido en el caso de uso Listar).
 */
@Service
public class ServicioLibro {

    private final RepositorioLibros repositorio = RepositorioLibros.getInstancia();
    private final ListadoObservable<Libro> observable = new ListadoObservable<>();

    public void suscribir(ObservadorListado<Libro> observador) {
        observable.suscribir(observador);
    }

    public void desuscribir(ObservadorListado<Libro> observador) {
        observable.desuscribir(observador);
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

    public Libro crear(LibroInput in) {
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

    public Libro actualizar(String isbn, LibroUpdateInput in) {
        Libro libro = buscarPorIsbn(isbn)
                .orElseThrow(() -> new LibreriaException("No existe un libro con el ISBN " + isbn + "."));
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

    /** Elimina el libro (previamente buscado) y lo devuelve para que el cliente confirme qué se borró. */
    public Libro eliminar(String isbn) {
        Libro libro = buscarPorIsbn(isbn)
                .orElseThrow(() -> new LibreriaException("No existe un libro con el ISBN " + isbn + "."));
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
