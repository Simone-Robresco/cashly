$ErrorActionPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$downloads = Join-Path $env:USERPROFILE "Downloads"
$utf8 = New-Object System.Text.UTF8Encoding($false)  # UTF-8 senza BOM, sempre

Write-Host "Cerco file con destinazione scritta dentro, in `"$downloads`" ..."
Write-Host ""

# Ogni file che Claude genera comincia con una riga tipo:
#   // PATH: features/home/home_page.dart
# Questo script legge quella riga e sa da solo dove spostare il file,
# senza bisogno di un elenco scritto a mano. Cosi' non serve piu'
# aggiornare questo script quando arrivano file nuovi.
#
# Legge e scrive sempre esplicitamente in UTF-8: senza questo, PowerShell
# a volte usa la codifica del sistema e rovina caratteri speciali come "€".

$candidates = Get-ChildItem -Path $downloads -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in ".dart" }

# Raggruppo per destinazione: se per errore ci sono piu' copie dello
# stesso file (es. scaricato due volte), prendo solo la piu' recente.
$byDestination = @{}

foreach ($file in $candidates) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
    if ($lines.Length -eq 0) { continue }
    if ($lines[0] -match '^\s*//\s*PATH:\s*(.+?)\s*$') {
        $relPath = $Matches[1] -replace '/', '\'
        if (-not $byDestination.ContainsKey($relPath)) {
            $byDestination[$relPath] = @()
        }
        $byDestination[$relPath] += $file
    }
}

$movedCount = 0

foreach ($relPath in $byDestination.Keys) {
    $group = $byDestination[$relPath] | Sort-Object LastWriteTime -Descending
    $chosen = $group[0]

    $destPath = Join-Path $scriptDir $relPath
    $destDir = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    # Tolgo la riga "// PATH: ..." dal contenuto finale: era solo
    # un'indicazione per lo script, non deve restare nel codice vero.
    $lines = [System.IO.File]::ReadAllLines($chosen.FullName, [System.Text.Encoding]::UTF8)
    $contentLines = $lines[1..($lines.Length - 1)]
    [System.IO.File]::WriteAllLines($destPath, $contentLines, $utf8)

    Write-Host ("  OK    {0,-28} -> {1}" -f $chosen.Name, $relPath)
    $movedCount++

    foreach ($f in $group) {
        Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "Spostati $movedCount file."
Write-Host ""
Write-Host "Fatto. Premi un tasto per chiudere..."
[void][System.Console]::ReadKey($true)
