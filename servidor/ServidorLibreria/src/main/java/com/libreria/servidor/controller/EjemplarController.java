package com.libreria.servidor.controller;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.EjemplarUpdateInput;
import com.libreria.servidor.model.Libro;
import com.libreria.servidor.servicio.ServicioEjemplar;
import com.libreria.servidor.servicio.ServicioLibro;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Optional;

/** Controller GraphQL para el objeto detalle Ejemplar. */
@Controller
public class EjemplarController {

    private final ServicioEjemplar servicioEjemplar;
    private final ServicioLibro servicioLibro;

    public EjemplarController(ServicioEjemplar servicioEjemplar, ServicioLibro servicioLibro) {
        this.servicioEjemplar = servicioEjemplar;
        this.servicioLibro = servicioLibro;
    }

    // ---------- Queries ----------

    @QueryMapping
    public List<Ejemplar> ejemplares() {
        return servicioEjemplar.listar();
    }

    @QueryMapping
    public List<Ejemplar> ejemplaresFiltrados(@Argument EstadoEjemplar estado, @Argument String isbnLibro) {
        return servicioEjemplar.filtrar(estado, isbnLibro);
    }

    @QueryMapping
    public Optional<Ejemplar> ejemplarPorCodigo(@Argument String codigo) {
        return servicioEjemplar.buscarPorCodigo(codigo);
    }

    // ---------- Mutations ----------

    @MutationMapping
    public Ejemplar crearEjemplar(@Argument EjemplarInput input) {
        return servicioEjemplar.crear(input);
    }

    @MutationMapping
    public Ejemplar actualizarEjemplar(@Argument String codigo, @Argument EjemplarUpdateInput input) {
        return servicioEjemplar.actualizar(codigo, input);
    }

    @MutationMapping
    public Ejemplar eliminarEjemplar(@Argument String codigo) {
        return servicioEjemplar.eliminar(codigo);
    }

    // ---------- Campo calculado: Ejemplar.libro ----------

    @SchemaMapping(typeName = "Ejemplar", field = "libro")
    public Libro libro(Ejemplar ejemplar) {
        return servicioLibro.buscarPorIsbn(ejemplar.getIsbnLibro()).orElse(null);
    }
}
