import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ListadoObservable } from "./Observable";

describe("ListadoObservable (patrón Observer)", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("notifica a los observadores suscritos y no a los que se desuscribieron", () => {
    const sujeto = new ListadoObservable();
    const primero = vi.fn();
    const segundo = vi.fn();

    sujeto.suscribir(primero);
    const desuscribirSegundo = sujeto.suscribir(segundo);
    sujeto.notificar();
    desuscribirSegundo();
    sujeto.notificar();

    expect(primero).toHaveBeenCalledTimes(2);
    expect(segundo).toHaveBeenCalledTimes(1);
  });

  it("notifica cuando cambia la revisión del servidor (cambios hechos por otro cliente)", async () => {
    let revisionServidor = 7;
    const consultarRevision = vi.fn(async () => revisionServidor);
    const sujeto = new ListadoObservable(consultarRevision, 1000);
    const observador = vi.fn();

    sujeto.suscribir(observador);
    await vi.advanceTimersByTimeAsync(0);
    expect(consultarRevision).toHaveBeenCalledTimes(1);

    await vi.advanceTimersByTimeAsync(1000);
    expect(observador).not.toHaveBeenCalled();

    revisionServidor = 8;
    await vi.advanceTimersByTimeAsync(1000);
    expect(observador).toHaveBeenCalledTimes(1);
  });

  it("solo consulta el servidor mientras alguien observa", async () => {
    const consultarRevision = vi.fn(async () => 1);
    const sujeto = new ListadoObservable(consultarRevision, 1000);

    await vi.advanceTimersByTimeAsync(5000);
    expect(consultarRevision).not.toHaveBeenCalled();

    const desuscribir = sujeto.suscribir(vi.fn());
    await vi.advanceTimersByTimeAsync(2000);
    const llamadas = consultarRevision.mock.calls.length;
    desuscribir();
    await vi.advanceTimersByTimeAsync(5000);

    expect(llamadas).toBe(3);
    expect(consultarRevision).toHaveBeenCalledTimes(llamadas);
  });

  it("sigue vigilando aunque el servidor falle momentáneamente", async () => {
    const consultarRevision = vi.fn()
      .mockResolvedValueOnce(1)
      .mockRejectedValueOnce(new Error("sin conexión"))
      .mockResolvedValue(2);
    const sujeto = new ListadoObservable(consultarRevision, 1000);
    const observador = vi.fn();

    sujeto.suscribir(observador);
    await vi.advanceTimersByTimeAsync(2000);

    expect(observador).toHaveBeenCalledTimes(1);
  });
});
