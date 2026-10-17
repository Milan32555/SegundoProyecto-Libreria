import { describe, expect, it } from "vitest";
import { aValorDeInputFecha, formatearFecha, formatearFechaLarga, formatearPrecio, saludo } from "./formato";

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

  it("escribe la fecha larga y el saludo del inicio", () => {
    expect(formatearFechaLarga(new Date(2026, 9, 17))).toBe("Sábado, 17 de octubre");
    expect(formatearFechaLarga(new Date(2026, 2, 2))).toBe("Lunes, 2 de marzo");
    expect(saludo(new Date(2026, 0, 1, 8))).toBe("Buenos días");
    expect(saludo(new Date(2026, 0, 1, 15))).toBe("Buenas tardes");
    expect(saludo(new Date(2026, 0, 1, 22))).toBe("Buenas noches");
    expect(saludo(new Date(2026, 0, 1, 2))).toBe("Buenas noches");
  });
});
