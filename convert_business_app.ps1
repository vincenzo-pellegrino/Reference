<#
.SYNOPSIS
    Converte cmdb_ci_business_app.csv in file .txt per Copilot Studio KB.

.DESCRIPTION
    Gestisce il formato ServiceNow con record multilinea (newline nei campi).
    Genera file da max 500KB per evitare errori di upload.

.USAGE
    cd <cartella con il CSV>
    .\convert_business_app.ps1
#>

$InputFile = "cmdb_ci_business_app.csv"
$OutputDir = "output_kb"
$MaxFileSizeBytes = 500000  # 500 KB per file
$Prefix = "kb_business_app"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

if (-not (Test-Path $InputFile)) {
    Write-Host "ERRORE: $InputFile non trovato!" -ForegroundColor Red
    exit 1
}

# === FIELD MAPPING ===
$FieldLabels = [ordered]@{
    0  = "Nome"
    1  = "Descrizione"
    2  = "Processo di business"
    3  = "Tipo applicazione"
    4  = "Tipo architettura"
    5  = "Tipo installazione"
    6  = "Stato installazione"
    7  = "Stato ciclo di vita"
    8  = "Fase ciclo di vita"
    9  = "Stack tecnologico"
    10 = "Base utenti"
    11 = "Piattaforma"
    12 = "Data ultimo cambiamento"
    13 = "Responsabile"
    14 = "IT Application Owner"
    15 = "Aggiornato da"
    16 = "Criticita business"
    17 = "Tier emergenza"
    18 = "Classificazione dati"
    19 = "Certificato"
    20 = "Model ID"
}

# === FUNZIONI ===

function Read-AllRecords {
    <#
    .SYNOPSIS
        Legge il file e restituisce i record logici.
        Formato ServiceNow: ogni record inizia con " e finisce con "
        Se un campo contiene newline, il record si estende su piu' righe.
        Regola: un record e' completo quando il conteggio di " e' pari.
    #>
    param([string]$Path)

    $rawLines = [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::GetEncoding("utf-8"))
    Write-Host "  Righe fisiche: $($rawLines.Count)"

    $records = New-Object System.Collections.Generic.List[string]
    $buffer = ""
    $skippedFirst = $false

    foreach ($line in $rawLines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # Prima riga = header, skippa
        if (-not $skippedFirst) {
            $skippedFirst = $true
            continue
        }

        if ($buffer -eq "") {
            $buffer = $line
        } else {
            $buffer = $buffer + " " + $line
        }

        # Conta virgolette: se pari, record completo
        $count = 0
        for ($i = 0; $i -lt $buffer.Length; $i++) {
            if ($buffer[$i] -eq '"') { $count++ }
        }

        if ($count % 2 -eq 0) {
            $records.Add($buffer)
            $buffer = ""
        }
    }

    # Residuo
    if ($buffer -ne "") {
        $records.Add($buffer)
    }

    return $records
}

function Parse-ServiceNowRecord {
    <#
    .SYNOPSIS
        Parsa un record ServiceNow e restituisce array di valori.
        Input: "val1,""val2"",""val3"""
        1. Strip quote esterne -> val1,""val2"",""val3""
        2. Replace "" -> " -> val1,"val2","val3"
        3. Split CSV standard
    #>
    param([string]$Record)

    $t = $Record.Trim()
    if ($t.Length -lt 2) { return ,@($t) }

    # Strip quote esterne
    if ($t[0] -eq '"' -and $t[$t.Length - 1] -eq '"') {
        $inner = $t.Substring(1, $t.Length - 2)
    } else {
        $inner = $t
    }

    # Unescape
    $csv = $inner.Replace('""', '"')

    # Split
    $fields = New-Object System.Collections.Generic.List[string]
    $sb = New-Object System.Text.StringBuilder
    $inQ = $false

    for ($i = 0; $i -lt $csv.Length; $i++) {
        $c = $csv[$i]
        if ($inQ) {
            if ($c -eq '"') {
                if (($i + 1) -lt $csv.Length -and $csv[$i + 1] -eq '"') {
                    [void]$sb.Append('"')
                    $i++
                } else {
                    $inQ = $false
                }
            } else {
                [void]$sb.Append($c)
            }
        } else {
            if ($c -eq '"') {
                $inQ = $true
            } elseif ($c -eq ',') {
                [void]$fields.Add($sb.ToString())
                [void]$sb.Clear()
            } else {
                [void]$sb.Append($c)
            }
        }
    }
    [void]$fields.Add($sb.ToString())

    return ,$fields.ToArray()
}

# === MAIN ===

Write-Host ""
Write-Host "=== Business App CSV -> Copilot Studio KB ===" -ForegroundColor Cyan
Write-Host ""

# Leggi record logici (gestisce multilinea)
Write-Host "  Lettura $InputFile..." -NoNewline
$records = Read-AllRecords -Path $InputFile
Write-Host " $($records.Count) record logici"

# Parsa e converti in blocchi testo
$textBlocks = New-Object System.Collections.Generic.List[string]
$errCount = 0
$noNameCount = 0
$corruptCount = 0

foreach ($rec in $records) {
    try {
        $fields = Parse-ServiceNowRecord $rec

        # Deve avere almeno qualche campo
        if ($fields.Count -lt 2) { $errCount++; continue }

        # Prendi il nome (campo 0)
        $nome = ""
        if ($fields.Count -gt 0) { $nome = $fields[0].Trim() }

        # Salta record senza nome
        if ($nome -eq "") { $noNameCount++; continue }

        # Verifica che non sia corrotto: se il nome contiene ,", e' spazzatura
        if ($nome -match ',"\s*,') { $corruptCount++; continue }

        # Costruisci blocco testo
        $lines = New-Object System.Collections.Generic.List[string]

        for ($i = 0; $i -lt $fields.Count -and $i -lt 21; $i++) {
            $val = $fields[$i].Trim() -replace '[\r\n]+', ' '
            # Salta valori vuoti o che contengono solo virgole/virgolette (corrotti)
            if ($val -eq "" -or $val -match '^[,"\s]+$') { continue }
            
            $label = $FieldLabels[$i]
            if ($label) {
                [void]$lines.Add("${label}: $val")
            }
        }

        if ($lines.Count -ge 2) {
            [void]$textBlocks.Add(($lines -join "`n"))
        }
    } catch {
        $errCount++
    }
}

Write-Host "  Record validi: $($textBlocks.Count)"
Write-Host "  Senza nome: $noNameCount"
Write-Host "  Corrotti: $corruptCount"
Write-Host "  Errori: $errCount"

# Deduplicazione
$seen = New-Object System.Collections.Generic.HashSet[string]
$unique = New-Object System.Collections.Generic.List[string]
foreach ($block in $textBlocks) {
    if ($seen.Add($block)) {
        [void]$unique.Add($block)
    }
}
Write-Host "  Unici: $($unique.Count) (dup: $($textBlocks.Count - $unique.Count))"

# Scrivi file chunked
if ($unique.Count -eq 0) {
    Write-Host "  Nessun output!" -ForegroundColor Red
    exit 1
}

# Rimuovi vecchi file
Get-ChildItem -Path $OutputDir -Filter "${Prefix}_*.txt" | Remove-Item -Force

$fileIndex = 1
$sb = New-Object System.Text.StringBuilder
$currentSize = 0
$filesWritten = @()

foreach ($block in $unique) {
    $entry = $block + "`n---`n"
    $entrySize = [System.Text.Encoding]::UTF8.GetByteCount($entry)

    if (($currentSize + $entrySize) -gt $MaxFileSizeBytes -and $sb.Length -gt 0) {
        $fp = Join-Path $OutputDir "${Prefix}_${fileIndex}.txt"
        [System.IO.File]::WriteAllText($fp, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
        $filesWritten += $fp
        $fileIndex++
        [void]$sb.Clear()
        $currentSize = 0
    }
    [void]$sb.Append($entry)
    $currentSize += $entrySize
}

if ($sb.Length -gt 0) {
    $fp = Join-Path $OutputDir "${Prefix}_${fileIndex}.txt"
    [System.IO.File]::WriteAllText($fp, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
    $filesWritten += $fp
}

Write-Host ""
Write-Host "  FILE GENERATI: $($filesWritten.Count)" -ForegroundColor Green
foreach ($f in $filesWritten) {
    $kb = [math]::Round((Get-Item $f).Length / 1KB, 0)
    Write-Host "    $f (${kb} KB)"
}
Write-Host ""
Write-Host "Carica i file su Copilot Studio -> Knowledge -> File upload" -ForegroundColor Green
