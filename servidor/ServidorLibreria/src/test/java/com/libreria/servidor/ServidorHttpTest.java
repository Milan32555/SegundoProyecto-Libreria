package com.libreria.servidor;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Levanta el servidor en un puerto real y le habla por HTTP, como lo hacen los clientes
 * (incluida la petición CORS "preflight" que hace el navegador para el cliente web).
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ServidorHttpTest {

    private static final String ORIGEN_CLIENTE_WEB = "http://localhost:5173";

    @LocalServerPort
    private int puerto;

    private final HttpClient http = HttpClient.newHttpClient();

    private URI urlGraphQl() {
        return URI.create("http://localhost:" + puerto + "/graphql");
    }

    @Test
    void respondeConsultasGraphQlPorPost() throws Exception {
        HttpRequest peticion = HttpRequest.newBuilder(urlGraphQl())
                .header("Content-Type", "application/json")
                .header("Origin", ORIGEN_CLIENTE_WEB)
                .POST(HttpRequest.BodyPublishers.ofString("{\"query\":\"{ libros { isbn titulo } }\"}"))
                .build();

        HttpResponse<String> respuesta = http.send(peticion, HttpResponse.BodyHandlers.ofString());

        assertThat(respuesta.statusCode()).isEqualTo(200);
        assertThat(respuesta.body()).contains("\"data\"").contains("978-0307474728");
        assertThat(respuesta.headers().firstValue("Access-Control-Allow-Origin")).isPresent();
    }

    @Test
    void permiteElPreflightCorsDelClienteWeb() throws Exception {
        HttpRequest preflight = HttpRequest.newBuilder(urlGraphQl())
                .header("Origin", ORIGEN_CLIENTE_WEB)
                .header("Access-Control-Request-Method", "POST")
                .header("Access-Control-Request-Headers", "content-type")
                .method("OPTIONS", HttpRequest.BodyPublishers.noBody())
                .build();

        HttpResponse<String> respuesta = http.send(preflight, HttpResponse.BodyHandlers.ofString());

        assertThat(respuesta.statusCode()).isEqualTo(200);
        assertThat(respuesta.headers().firstValue("Access-Control-Allow-Origin")).isPresent();
    }
}
