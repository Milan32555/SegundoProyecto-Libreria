package com.libreria.servidor.controller;

import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.model.LibroInput;
import com.libreria.servidor.model.LibroUpdateInput;
import com.libreria.servidor.servicio.ServicioEjemplar;
import com.libreria.servidor.servicio.ServicioLibro;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Optional;

/**
 * Controller GraphQL (capa "Controller" de MVC) para el objeto maestro Libro.
 * Delega toda la lógica de negocio a ServicioLibro; esta clase solo traduce
 * entre el protocolo GraphQL y la capa de servicio.
 */
@Controller
public class LibroController {

    private final ServicioLibro servicioLibro;
    private final ServicioEjemplar servicioEjemplar;

    public LibroController(ServicioLibro servicioLibro, ServicioEjemplar servicioEjemplar) {
        this.servicioLibro = servicioLibro;
        this.servicioEjemplar = servicioEjemplar;
    }

    // ---------- Queries ----------

    @QueryMapping
    public List<Libro> libros() {
        return servicioLibro.listar();
    }

    @QueryMapping
    public List<Libro> librosFiltrados(@Argument String autor, @Argument Genero genero) {
        return servicioLibro.filtrar(autor, genero);
    }

    @QueryMapping
    public Optional<Libro> libroPorIsbn(@Argument String isbn) {
        return servicioLibro.buscarPorIsbn(isbn);
    }

    // ---------- Mutations ----------

    @MutationMapping
    public Libro crearLibro(@Argument LibroInput input) {
        return servicioLibro.crear(input);
    }

    @MutationMapping
    public Libro actualizarLibro(@Argument String isbn, @Argument LibroUpdateInput input) {
        return servicioLibro.actualizar(isbn, input);
    }

    @MutationMapping
    public Libro eliminarLibro(@Argument String isbn) {
        return servicioLibro.eliminar(isbn);
    }

    // ---------- Campo calculado: Libro.ejemplares ----------

    /** Resuelve el campo "ejemplares" de Libro con los ejemplares que tienen ese isbn. */
    @SchemaMapping(typeName = "Libro", field = "ejemplares")
    public List<Ejemplar> ejemplares(Libro libro) {
        return servicioEjemplar.porLibro(libro.getIsbn());
    }
}
