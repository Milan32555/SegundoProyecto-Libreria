#!/usr/bin/env bash
# Toma las capturas que pide el recorrido en el celular (integration_test/recorrido_test.dart).
# La prueba escribe "CAPTURA:<nombre>" en el registro de Flutter; este script lo lee con
# adb logcat y guarda la pantalla real del teléfono con adb screencap.
#   bash scripts/capturas-celular.sh [carpeta]     (Ctrl+C para terminar)
carpeta="${1:-../Capturas-SegundoProyecto-Libreria/movil}"
mkdir -p "$carpeta"
adb logcat -c
adb logcat -v raw -s flutter:I | while IFS= read -r linea; do
  linea="${linea//$'\r'/}"
  case "$linea" in
    *CAPTURA:*)
      nombre="${linea##*CAPTURA:}"
      adb exec-out screencap -p > "$carpeta/$nombre.png"
      echo "captura: $nombre"
      ;;
  esac
done
