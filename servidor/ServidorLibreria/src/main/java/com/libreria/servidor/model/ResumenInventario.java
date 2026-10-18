package com.libreria.servidor.model;

import java.util.List;

/**
 * Resumen del inventario que muestra la ventana principal de los clientes:
 * total de libros, total de ejemplares y ejemplares por estado (uno por cada estado,
 * en el orden del enum, incluidos los que tienen cantidad 0).
 */
public record ResumenInventario(int totalLibros, int totalEjemplares, List<ConteoEstado> ejemplaresPorEstado) {
}
