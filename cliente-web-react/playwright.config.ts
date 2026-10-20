import { defineConfig } from "@playwright/test";
import path from "node:path";
import { fileURLToPath } from "node:url";

const AQUI = path.dirname(fileURLToPath(import.meta.url));

/**
 * Pruebas de extremo a extremo (E2E) del cliente web contra el servidor REAL.
 *
 * Playwright levanta un servidor GraphQL nuevo (datos de prueba limpios) y el cliente web, y
 * recorre todos los casos de uso en escritorio (1366x768) y en celular (390x844), guardando
 * una captura de cada pantalla.
 *
 * Requisitos: el jar del servidor compilado (./mvnw package) y JAVA_HOME apuntando a un JDK 17.
 *   npm run e2e
 */
const JAVA = process.env.JAVA_HOME ? path.join(process.env.JAVA_HOME, "bin", "java") : "java";
const JAR = path.resolve(AQUI, "../servidor/ServidorLibreria/target/ServidorLibreria-1.0.0.jar");

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: false,
  workers: 1, // todas las pruebas comparten el mismo servidor (datos en memoria)
  retries: 0,
  timeout: 60_000,
  expect: { timeout: 10_000 },
  reporter: [["list"]],
  use: {
    baseURL: "http://localhost:5173",
    locale: "es-CO",
    timezoneId: "America/Bogota",
    trace: "retain-on-failure"
  },
  projects: [
    { name: "escritorio", use: { viewport: { width: 1366, height: 768 } } },
    { name: "celular", use: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true } }
  ],
  webServer: [
    {
      command: `"${JAVA}" -jar "${JAR}"`,
      url: "http://localhost:8081/graphiql",
      reuseExistingServer: false,
      timeout: 90_000
    },
    {
      command: "npx vite --port 5173 --strictPort",
      url: "http://localhost:5173",
      reuseExistingServer: false,
      timeout: 60_000
    }
  ]
});
