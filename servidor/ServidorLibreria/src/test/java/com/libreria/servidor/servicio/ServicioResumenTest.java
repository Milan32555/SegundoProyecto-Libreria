package com.libreria.servidor.servicio;

import com.libreria.servidor.enums.EstadoEjemplar;
import com.libreria.servidor.enums.Genero;
import com.libreria.servidor.model.ConteoEstado;
import com.libreria.servidor.model.EjemplarInput;
import com.libreria.servidor.model.LibroInput;
import com.libreria.servidor.model.ResumenInventario;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

/** Pruebas del resumen del inventario que muestra la ventana principal de los clientes. */
class ServicioResumenTest {

    private static final LocalDateTime FECHA = LocalDateTime.of(2024, 1, 15, 10, 0);

    private ServicioLibro servicioLibro;
    private ServicioEjemplar servicioEjemplar;
    private ServicioResumen servicio;

    @BeforeEach
    void setUp() {
        servicioLibro = new ServicioLibro();
        servicioEjemplar = new ServicioEjemplar(servicioLibro);
        servicio = new ServicioResumen(servicioLibro, servicioEjemplar);
    }

    private static int cantidad(ResumenInventario resumen, EstadoEjemplar estado) {
        return resumen.ejemplaresPorEstado().stream()
                .filter(c -> c.estado() == estado)
                .findFirst().orElseThrow()
                .cantidad();
    }

    @Test
    void losTotalesCoincidenConLasColecciones() {
        ResumenInventario resumen = servicio.resumen();

        assertThat(resumen.totalLibros()).isEqualTo(servicioLibro.listar().size());
        assertThat(resumen.totalEjemplares()).isEqualTo(servicioEjemplar.listar().size());
        assertThat(resumen.ejemplaresPorEstado()).extracting(ConteoEstado::estado)
                .containsExactly(EstadoEjemplar.values());
        assertThat(resumen.ejemplaresPorEstado().stream().mapToInt(ConteoEstado::cantidad).sum())
                .isEqualTo(resumen.totalEjemplares());
        assertThat(resumen.ejemplaresPorEstado().stream().mapToDouble(ConteoEstado::porcentaje).sum())
                .isCloseTo(100.0, within(1e-9));
    }

    @Test
    void cadaCambioSeReflejaEnElResumen() {
        ResumenInventario antes = servicio.resumen();
        String isbn = "TEST-" + UUID.randomUUID();

        servicioLibro.crear(new LibroInput(isbn, "Resumen", "Autor", 1000, 10, FECHA, Genero.OTRO));
        servicioEjemplar.crear(new EjemplarInput("EJ-" + UUID.randomUUID(), EstadoEjemplar.DADO_DE_BAJA,
                "Bodega", FECHA, 1000, 0, isbn));
        ResumenInventario despues = servicio.resumen();

        assertThat(despues.totalLibros()).isEqualTo(antes.totalLibros() + 1);
        assertThat(despues.totalEjemplares()).isEqualTo(antes.totalEjemplares() + 1);
        assertThat(cantidad(despues, EstadoEjemplar.DADO_DE_BAJA))
                .isEqualTo(cantidad(antes, EstadoEjemplar.DADO_DE_BAJA) + 1);
        assertThat(cantidad(despues, EstadoEjemplar.DISPONIBLE))
                .isEqualTo(cantidad(antes, EstadoEjemplar.DISPONIBLE));
    }

    @Test
    void elPorcentajeEsLaParteDelTotalEnCadaEstado() {
        ResumenInventario resumen = servicio.resumen();

        for (ConteoEstado conteo : resumen.ejemplaresPorEstado()) {
            assertThat(conteo.porcentaje())
                    .isCloseTo(conteo.cantidad() * 100.0 / resumen.totalEjemplares(), within(1e-9));
        }
    }
}
