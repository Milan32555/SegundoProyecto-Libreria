package com.libreria.servidor.servicio;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.model.ConteoEstado;
import com.libreria.servidor.model.Ejemplar;
import com.libreria.servidor.model.ResumenInventario;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * Calcula el resumen del inventario (totales y ejemplares por estado) para la ventana
 * principal de los clientes. Los clientes no cuentan nada: muestran lo que devuelve este servicio.
 */
@Service
public class ServicioResumen {

    private final ServicioLibro servicioLibro;
    private final ServicioEjemplar servicioEjemplar;

    public ServicioResumen(ServicioLibro servicioLibro, ServicioEjemplar servicioEjemplar) {
        this.servicioLibro = servicioLibro;
        this.servicioEjemplar = servicioEjemplar;
    }

    public ResumenInventario resumen() {
        int totalLibros = servicioLibro.listar().size();
        List<Ejemplar> ejemplares = servicioEjemplar.listar();
        int totalEjemplares = ejemplares.size();

        List<ConteoEstado> porEstado = Arrays.stream(EstadoEjemplar.values())
                .map(estado -> {
                    int cantidad = (int) ejemplares.stream().filter(e -> e.getEstado() == estado).count();
                    double porcentaje = totalEjemplares == 0 ? 0 : cantidad * 100.0 / totalEjemplares;
                    return new ConteoEstado(estado, cantidad, porcentaje);
                })
                .toList();

        return new ResumenInventario(totalLibros, totalEjemplares, porEstado);
    }
}
