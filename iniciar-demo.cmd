@echo off
rem Doble clic: levanta el servidor, el cliente web y la app en el celular conectado por USB.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\iniciar-demo.ps1"
pause
