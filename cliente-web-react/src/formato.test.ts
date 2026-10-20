import { describe, expect, it } from "vitest";
import { aValorDeInputFecha, formatearFecha, formatearFechaCorta, formatearFechaLarga, formatearPrecio } from "./formato";

describe("formato", () => {
  it("formatea el precio como moneda", () => {
    expect(formatearPrecio(65000)).toMatch(/65\.000/);
  });

  it("formatea la fecha ISO del servidor de forma legible", () => {
    expect(formatearFecha("1967-05-30T00:00:00")).toMatch(/1967/);
    expect(formatearFecha("no es fecha")).toBe("no es fecha");
  });

  it("convierte la fecha ISO al formato de <input type='datetime-local'>", () => {
    expect(aValorDeInputFecha("2024-02-10T09:05:00")).toBe("2024-02-10T09:05");
  });

  it("muestra la fecha con hora en fichas y solo el día en tablas", () => {
    expect(formatearFecha("2024-02-10T09:05:00")).toMatch(/10\/02\/2024.*09:05/);
    expect(formatearFechaCorta("2024-02-10T09:05:00")).toBe("10/02/2024");
    expect(formatearFechaCorta("no es fecha")).toBe("no es fecha");
  });

  it("escribe la fecha larga del encabezado del inicio", () => {
    expect(formatearFechaLarga(new Date(2026, 9, 17))).toBe("Sábado, 17 de octubre");
    expect(formatearFechaLarga(new Date(2026, 2, 2))).toBe("Lunes, 2 de marzo");
  });
});
