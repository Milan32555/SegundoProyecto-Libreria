package com.libreria.servidor.controller;

import com.libreria.servidor.model.ResumenInventario;
import com.libreria.servidor.servicio.ServicioResumen;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

/** Controller GraphQL del resumen del inventario (ventana principal de los clientes). */
@Controller
public class ResumenController {

    private final ServicioResumen servicioResumen;

    public ResumenController(ServicioResumen servicioResumen) {
        this.servicioResumen = servicioResumen;
    }

    @QueryMapping
    public ResumenInventario resumenInventario() {
        return servicioResumen.resumen();
    }
}
