@echo off
REM Doppio click su questo file per spostare tutti i file scaricati.
REM La logica vera e' in sposta.ps1, che deve stare nella stessa cartella.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sposta.ps1"
