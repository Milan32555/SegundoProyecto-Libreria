package com.libreria.servidor.repositorio;

import com.libreria.servidor.builder.EjemplarBuilder;
import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.model.Ejemplar;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Patrón Singleton: única instancia dueña de la colección en memoria de Ejemplares. */
public final class RepositorioEjemplares {

    private static RepositorioEjemplares instancia;

    private final List<Ejemplar> ejemplares = new ArrayList<>();

    private RepositorioEjemplares() {
        cargarDatosDePrueba();
    }

    public static synchronized RepositorioEjemplares getInstancia() {
        if (instancia == null) {
            instancia = new RepositorioEjemplares();
        }
        return instancia;
    }

    public synchronized List<Ejemplar> listar() {
        return new ArrayList<>(ejemplares);
    }

    public synchronized void agregar(Ejemplar ejemplar) {
        ejemplares.add(ejemplar);
    }

    public synchronized boolean eliminar(Ejemplar ejemplar) {
        return ejemplares.remove(ejemplar);
    }

    /**
     * Inventario inicial: 20 copias de los libros de {@link RepositorioLibros} en estados variados
     * (10 disponibles, 6 prestadas, 2 dañadas y 2 dadas de baja). "Delirio" no tiene copias.
     */
    private void cargarDatosDePrueba() {
        final String cienAnos = "978-0307474728";
        final String voragine = "978-8437609355";
        final String maria = "978-9589012338";
        final String olvido = "978-9584215000";
        final String rosario = "978-9584239563";
        final String ejercitos = "978-8483103913";
        final String pedroParamo = "978-9681649500";
        final String ficciones = "978-8420633121";
        final String rayuela = "978-8437624747";
        final String veintePoemas = "978-9580469117";
        final String venasAbiertas = "978-8432311451";

        agregarSemilla("EJ-001", EstadoEjemplar.DISPONIBLE, "Estante A1", LocalDateTime.of(2024, 2, 10, 9, 0), 65000, 4, cienAnos);
        agregarSemilla("EJ-002", EstadoEjemplar.PRESTADO, "Estante A1", LocalDateTime.of(2024, 2, 10, 9, 5), 65000, 9, cienAnos);
        agregarSemilla("EJ-003", EstadoEjemplar.DISPONIBLE, "Estante B2", LocalDateTime.of(2024, 3, 2, 11, 30), 48000, 2, voragine);
        agregarSemilla("EJ-004", EstadoEjemplar.PRESTADO, "Estante A1", LocalDateTime.of(2025, 1, 15, 10, 20), 65000, 6, cienAnos);
        agregarSemilla("EJ-005", EstadoEjemplar.PRESTADO, "Estante B2", LocalDateTime.of(2024, 8, 21, 16, 45), 48000, 5, voragine);
        agregarSemilla("EJ-006", EstadoEjemplar.DISPONIBLE, "Estante B3", LocalDateTime.of(2024, 5, 6, 8, 40), 39000, 3, maria);
        agregarSemilla("EJ-007", EstadoEjemplar.DANIADO, "Bodega", LocalDateTime.of(2023, 11, 14, 15, 10), 39000, 11, maria);
        agregarSemilla("EJ-008", EstadoEjemplar.PRESTADO, "Estante C1", LocalDateTime.of(2025, 3, 3, 9, 15), 69000, 7, olvido);
        agregarSemilla("EJ-009", EstadoEjemplar.DISPONIBLE, "Estante C1", LocalDateTime.of(2025, 3, 3, 9, 20), 69000, 2, olvido);
        agregarSemilla("EJ-010", EstadoEjemplar.DISPONIBLE, "Estante B4", LocalDateTime.of(2024, 9, 12, 14, 0), 45000, 1, rosario);
        agregarSemilla("EJ-011", EstadoEjemplar.DADO_DE_BAJA, "Bodega", LocalDateTime.of(2022, 6, 30, 11, 0), 45000, 15, rosario);
        agregarSemilla("EJ-012", EstadoEjemplar.DISPONIBLE, "Estante B4", LocalDateTime.of(2025, 6, 18, 10, 35), 58000, 0, ejercitos);
        agregarSemilla("EJ-013", EstadoEjemplar.PRESTADO, "Estante D1", LocalDateTime.of(2024, 4, 22, 12, 10), 42000, 8, pedroParamo);
        agregarSemilla("EJ-014", EstadoEjemplar.DISPONIBLE, "Estante D1", LocalDateTime.of(2026, 2, 9, 9, 50), 42000, 1, pedroParamo);
        agregarSemilla("EJ-015", EstadoEjemplar.DISPONIBLE, "Estante D2", LocalDateTime.of(2025, 8, 27, 17, 25), 52000, 3, ficciones);
        agregarSemilla("EJ-016", EstadoEjemplar.PRESTADO, "Estante D2", LocalDateTime.of(2024, 10, 1, 13, 30), 89000, 4, rayuela);
        agregarSemilla("EJ-017", EstadoEjemplar.DANIADO, "Bodega", LocalDateTime.of(2023, 7, 19, 10, 5), 89000, 10, rayuela);
        agregarSemilla("EJ-018", EstadoEjemplar.DISPONIBLE, "Mostrador", LocalDateTime.of(2026, 5, 4, 11, 45), 35000, 0, veintePoemas);
        agregarSemilla("EJ-019", EstadoEjemplar.DISPONIBLE, "Estante E1", LocalDateTime.of(2025, 11, 10, 15, 55), 79000, 2, venasAbiertas);
        agregarSemilla("EJ-020", EstadoEjemplar.DADO_DE_BAJA, "Bodega", LocalDateTime.of(2021, 9, 8, 9, 30), 79000, 14, venasAbiertas);
    }

    private void agregarSemilla(String codigo, EstadoEjemplar estado, String ubicacion, LocalDateTime ingreso,
                                double precioReposicion, int prestamos, String isbnLibro) {
        ejemplares.add(new EjemplarBuilder()
                .conCodigo(codigo).conEstado(estado).conUbicacion(ubicacion)
                .conFechaIngreso(ingreso).conPrecioReposicion(precioReposicion)
                .conNumeroPrestamos(prestamos).conIsbnLibro(isbnLibro).construir());
    }
}
