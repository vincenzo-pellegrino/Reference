<#
.SYNOPSIS
    Converte i CSV CMDB in formato testo strutturato per Copilot Studio Knowledge Base.

.DESCRIPTION
    I file CSV esportati da ServiceNow hanno un formato non standard:
    ogni riga e' racchiusa tra virgolette esterne e i campi interni usano ""
    come delimitatori. Alcuni campi contengono newline (record multilinea).

    Eseguire nella cartella dove si trovano i file cmdb_ci_*.csv

.USAGE
    .\convert_for_copilot_studio.ps1
#>

$OutputDir = "output_kb"
$MaxFileSizeBytes = 2500000  # 2.5 MB per file

# Crea cartella output
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# === CONFIGURAZIONE CAMPI ===

$ServerFields = [ordered]@{
    "name"                                                        = "Nome"
    "u_gbl_system_environment"                                    = "Ambiente"
    "sys_class_name"                                              = "Classe"
    "u_gbl_status_dco_atrium"                                     = "Stato DCO Atrium"
    "sys_updated_on"                                              = "Ultimo aggiornamento"
    "u_last_discovery_date"                                       = "Ultima discovery"
    "sys_created_by"                                              = "Creato da"
    "sys_updated_by"                                              = "Aggiornato da"
    "ip_address"                                                  = "Indirizzo IP"
    "os"                                                          = "Sistema operativo"
    "u_gbl_apm_application"                                       = "Applicazione APM"
    "u_gbl_apm_application.u_sca_apm_ict_line_level_1_reference"  = "ICT Line Level 1"
    "u_gbl_apm_applicationcode"                                   = "Codice applicazione APM"
    "sn_vul_qualys_host_id"                                       = "Qualys Host ID"
    "discovery_source"                                            = "Sorgente discovery"
    "u_gbl_datasource"                                            = "Datasource"
    "u_gbl_role"                                                  = "Ruolo"
    "sys_created_on"                                              = "Data creazione"
    "sys_id"                                                      = "Sys ID"
}

$ApplFields = [ordered]@{
    "name"               = "Nome"
    "sys_class_name"     = "Classe"
    "category"           = "Categoria"
    "version"            = "Versione"
    "operational_status" = "Stato operativo"
}

$BusinessAppFields = [ordered]@{
    "name"                     = "Nome"
    "short_description"        = "Descrizione"
    "apm_business_process"     = "Processo di business"
    "application_type"         = "Tipo applicazione"
    "architecture_type"        = "Tipo architettura"
    "install_type"             = "Tipo installazione"
    "install_status"           = "Stato installazione"
    "life_cycle_stage_status"  = "Stato ciclo di vita"
    "life_cycle_stage"         = "Fase ciclo di vita"
    "technology_stack"         = "Stack tecnologico"
    "user_base"                = "Base utenti"
    "platform"                 = "Piattaforma"
    "last_change_date"         = "Data ultimo cambiamento"
    "owned_by"                 = "Responsabile"
    "it_application_owner"     = "IT Application Owner"
    "sys_updated_by"           = "Aggiornato da"
    "business_criticality"     = "Criticita business"
    "emergency_tier"           = "Tier emergenza"
    "data_classification"      = "Classificazione dati"
    "certified"                = "Certificato"
    "model_id"                 = "Model ID"
}

# === FUNZIONI ===

function Join-MultiLineRecords {
    <#
    .SYNOPSIS
        Unisce righe fisiche che appartengono allo stesso record logico.
        
        Nel formato ServiceNow, ogni record e' racchiuso in virgolette esterne "...".
        Se un campo contiene un newline, il record si estende su piu' righe fisiche.
        
        Regola: contare le virgolette. Quando il totale e' PARI, il record e' completo.
        (aperta " + tutte le "" interne + chiusa " = sempre pari)
    #>
    param([string[]]$Lines)

    $records = [System.Collections.Generic.List[string]]::new()
    $buffer = ""

    foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        if ($buffer -eq "") {
            $buffer = $line
        } else {
            # Unisci con spazio (i newline nei campi diventano spazi nella KB)
            $buffer = $buffer + " " + $line
        }

        # Conta le virgolette nel buffer
        $quoteCount = 0
        for ($i = 0; $i -lt $buffer.Length; $i++) {
            if ($buffer[$i] -eq '"') { $quoteCount++ }
        }

        # Se pari, il record e' completo
        if ($quoteCount % 2 -eq 0) {
            $records.Add($buffer)
            $buffer = ""
        }
    }

    # Se c'e' un buffer residuo, aggiungilo comunque
    if ($buffer -ne "") {
        $records.Add($buffer)
    }

    return $records
}

function Unescape-ServiceNowLine {
    <#
    .SYNOPSIS
        Converte una riga dal formato ServiceNow a CSV standard.
        Input:  "campo1,""campo2"",""campo3"""
        Output: campo1,"campo2","campo3"
    #>
    param([string]$Line)

    $trimmed = $Line.Trim()
    if ($trimmed.Length -lt 2) { return $trimmed }

    # Se inizia e finisce con ", rimuovi quote esterne e unescape
    if ($trimmed[0] -eq '"' -and $trimmed[-1] -eq '"') {
        $inner = $trimmed.Substring(1, $trimmed.Length - 2)
        # Sostituisci "" con " (unescape standard)
        $result = $inner -replace '""', '"'
        return $result
    }

    return $trimmed
}

function Parse-CsvLine {
    <#
    .SYNOPSIS
        Parsa una riga CSV standard e restituisce un array di campi.
        Gestisce campi quotati con virgolette e virgole interne.
    #>
    param([string]$Line)

    $fields = [System.Collections.Generic.List[string]]::new()
    $current = [System.Text.StringBuilder]::new()
    $inQuotes = $false
    $i = 0

    while ($i -lt $Line.Length) {
        $c = $Line[$i]

        if ($inQuotes) {
            if ($c -eq '"') {
                if (($i + 1) -lt $Line.Length -and $Line[$i + 1] -eq '"') {
                    # Escaped quote ""
                    $current.Append('"') | Out-Null
                    $i += 2
                    continue
                } else {
                    # Fine campo quotato
                    $inQuotes = $false
                    $i++
                    continue
                }
            } else {
                $current.Append($c) | Out-Null
            }
        } else {
            if ($c -eq '"') {
                $inQuotes = $true
            } elseif ($c -eq ',') {
                $fields.Add($current.ToString())
                $current.Clear() | Out-Null
            } else {
                $current.Append($c) | Out-Null
            }
        }
        $i++
    }

    # Ultimo campo
    $fields.Add($current.ToString())

    return ,$fields.ToArray()
}

function Import-NonStandardCsv {
    <#
    .SYNOPSIS
        Legge un CSV ServiceNow non standard con supporto per:
        - Virgolette esterne per riga
        - Campi multilinea (newline dentro i campi)
        - Header duplicati
    #>
    param(
        [Parameter(Mandatory)][string]$Path
    )

    # Prova diversi encoding
    $rawLines = $null
    $encodings = @("utf-8", "iso-8859-1", "windows-1252")

    foreach ($encName in $encodings) {
        try {
            $enc = [System.Text.Encoding]::GetEncoding($encName)
            $rawLines = [System.IO.File]::ReadAllLines($Path, $enc)
            if ($rawLines.Count -gt 1) { break }
        } catch {
            continue
        }
    }

    if (-not $rawLines -or $rawLines.Count -lt 2) {
        Write-Host "  ERRORE: impossibile leggere o file vuoto: $Path" -ForegroundColor Red
        return @()
    }

    Write-Host "  Righe fisiche: $($rawLines.Count). Unione record multilinea..." -NoNewline

    # Unisci record multilinea
    $logicalRecords = Join-MultiLineRecords $rawLines

    Write-Host " $($logicalRecords.Count) record logici." -NoNewline

    if ($logicalRecords.Count -lt 2) {
        Write-Host " ERRORE: nessun dato." -ForegroundColor Red
        return @()
    }

    # Parsa header
    $headerLine = Unescape-ServiceNowLine $logicalRecords[0]
    $headers = Parse-CsvLine $headerLine

    # Deduplica header
    $seen = @{}
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $h = $headers[$i].Trim()
        if ($h -eq "") { $h = "campo_$i" }
        if ($seen.ContainsKey($h)) {
            $seen[$h]++
            $headers[$i] = "${h}_$($seen[$h])"
        } else {
            $seen[$h] = 1
            $headers[$i] = $h
        }
    }

    Write-Host " Parsing dati..." -NoNewline

    # Parsa righe dati
    $results = [System.Collections.Generic.List[PSCustomObject]]::new()
    $headerCount = $headers.Count
    $errorCount = 0

    for ($r = 1; $r -lt $logicalRecords.Count; $r++) {
        $csvLine = Unescape-ServiceNowLine $logicalRecords[$r]
        
        try {
            $fields = Parse-CsvLine $csvLine

            $obj = [ordered]@{}
            for ($j = 0; $j -lt $headerCount; $j++) {
                if ($j -lt $fields.Count) {
                    $obj[$headers[$j]] = $fields[$j]
                } else {
                    $obj[$headers[$j]] = ""
                }
            }
            $results.Add([PSCustomObject]$obj)
        } catch {
            $errorCount++
            if ($errorCount -le 5) {
                Write-Host "`n    Errore riga $r : $_" -ForegroundColor Yellow
            }
        }
    }

    if ($errorCount -gt 5) {
        Write-Host "`n    ... e altri $($errorCount - 5) errori" -ForegroundColor Yellow
    }

    Write-Host " OK ($($results.Count) righe, $errorCount errori)"
    return $results
}

function Convert-RowToText {
    param(
        [Parameter(Mandatory)]$Row,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($key in $FieldMapping.Keys) {
        $value = $Row.$key
        if ($value -and $value.ToString().Trim() -ne "") {
            # Rimuovi newline residui e normalizza spazi
            $cleanValue = $value.ToString().Trim() -replace '\s+', ' '
            $lines.Add("$($FieldMapping[$key]): $cleanValue")
        }
    }
    return ($lines -join "`n")
}

function Write-ChunkedFiles {
    param(
        [string]$Prefix,
        $TextBlocks
    )

    if (-not $TextBlocks -or $TextBlocks.Count -eq 0) {
        Write-Host "  Nessun blocco da scrivere, skip."
        return @()
    }

    $fileIndex = 1
    $sb = [System.Text.StringBuilder]::new()
    $separator = "`n---`n"
    $filesWritten = [System.Collections.Generic.List[string]]::new()

    foreach ($block in $TextBlocks) {
        $entry = $block + $separator
        $newSize = [System.Text.Encoding]::UTF8.GetByteCount($sb.ToString() + $entry)

        if ($newSize -gt $MaxFileSizeBytes -and $sb.Length -gt 0) {
            $filename = "${Prefix}_${fileIndex}.txt"
            $filepath = Join-Path $OutputDir $filename
            [System.IO.File]::WriteAllText($filepath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
            $filesWritten.Add($filepath)
            $fileIndex++
            $sb.Clear() | Out-Null
        }
        $sb.Append($entry) | Out-Null
    }

    # Ultimo file
    if ($sb.Length -gt 0) {
        $filename = "${Prefix}_${fileIndex}.txt"
        $filepath = Join-Path $OutputDir $filename
        [System.IO.File]::WriteAllText($filepath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
        $filesWritten.Add($filepath)
    }

    return $filesWritten
}

function Process-Category {
    param(
        [Parameter(Mandatory)][string]$CategoryName,
        [Parameter(Mandatory)][string[]]$CsvFiles,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping,
        [bool]$FilterEmptyName = $true
    )

    Write-Host "`n============================================================"
    Write-Host "Elaborazione: $CategoryName"
    Write-Host "============================================================"

    $allRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($file in $CsvFiles) {
        if (Test-Path $file) {
            $rows = Import-NonStandardCsv -Path $file
            if ($rows -and $rows.Count -gt 0) {
                foreach ($r in $rows) { $allRows.Add($r) }
            }
        } else {
            Write-Host "  ATTENZIONE: file non trovato: $file" -ForegroundColor Yellow
        }
    }

    Write-Host "  Totale righe lette: $($allRows.Count)"

    if ($allRows.Count -eq 0) {
        Write-Host "  Nessuna riga da elaborare, skip." -ForegroundColor Yellow
        return
    }

    # Deduplicazione basata su TUTTI i campi del mapping
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $uniqueRows = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($row in $allRows) {
        $keyParts = [System.Collections.Generic.List[string]]::new()
        foreach ($k in $FieldMapping.Keys) {
            $val = $row.$k
            if ($val) { $keyParts.Add($val.ToString()) } else { $keyParts.Add("") }
        }
        $key = $keyParts -join "|"
        
        # Non deduplicare righe con chiave completamente vuota
        $isAllEmpty = ($keyParts | Where-Object { $_.Trim() -ne "" }).Count -eq 0
        if ($isAllEmpty) {
            # Skip righe completamente vuote
            continue
        }
        
        if ($seen.Add($key)) {
            $uniqueRows.Add($row)
        }
    }

    $duplicatesRemoved = $allRows.Count - $uniqueRows.Count
    Write-Host "  Righe dopo deduplicazione: $($uniqueRows.Count) (rimossi $duplicatesRemoved duplicati/vuoti)"

    # Filtra righe senza nome (opzionale)
    $workingRows = $uniqueRows
    if ($FilterEmptyName) {
        $filteredRows = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($row in $uniqueRows) {
            if ($row.name -and $row.name.ToString().Trim() -ne "") {
                $filteredRows.Add($row)
            }
        }
        $emptyRemoved = $uniqueRows.Count - $filteredRows.Count
        if ($emptyRemoved -gt 0) {
            Write-Host "  Righe senza nome rimosse: $emptyRemoved"
        }
        $workingRows = $filteredRows
    }

    Write-Host "  Righe da convertire: $($workingRows.Count)"

    # Converti in testo
    $textBlocks = [System.Collections.Generic.List[string]]::new()
    foreach ($row in $workingRows) {
        $block = Convert-RowToText -Row $row -FieldMapping $FieldMapping
        if ($block.Trim() -ne "") {
            $textBlocks.Add($block)
        }
    }

    Write-Host "  Blocchi di testo generati: $($textBlocks.Count)"

    # Scrivi file
    $files = Write-ChunkedFiles -TextBlocks $textBlocks -Prefix "kb_$CategoryName"
    if ($files -and $files.Count -gt 0) {
        Write-Host "  File generati: $($files.Count)"
        foreach ($f in $files) {
            $sizeMB = [math]::Round((Get-Item $f).Length / 1MB, 2)
            Write-Host "    - $f ($sizeMB MB)"
        }
    }
}

# === ESECUZIONE ===

Write-Host "Conversione CSV CMDB per Copilot Studio Knowledge Base" -ForegroundColor Cyan
Write-Host "========================================================"
Write-Host "Formato CSV: ServiceNow (virgolette doppie, campi multilinea)"
Write-Host ""

# Server
$serverFiles = @("cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv")
Process-Category -CategoryName "server" -CsvFiles $serverFiles -FieldMapping $ServerFields -FilterEmptyName $true

# Applicazioni
$applFiles = @(
    "cmdb_ci_appl_1.csv", "cmdb_ci_appl_2.csv", "cmdb_ci_appl_3.csv", "cmdb_ci_appl_4.csv",
    "cmdb_ci_appl_5.csv", "cmdb_ci_appl_6.csv", "cmdb_ci_appl_7.csv", "cmdb_ci_appl_8.csv"
)
Process-Category -CategoryName "appl" -CsvFiles $applFiles -FieldMapping $ApplFields -FilterEmptyName $true

# Business App
$businessFiles = @("cmdb_ci_business_app.csv")
Process-Category -CategoryName "business_app" -CsvFiles $businessFiles -FieldMapping $BusinessAppFields -FilterEmptyName $false

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "COMPLETATO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Cartella output: $OutputDir\"
Write-Host "Carica tutti i file .txt su Copilot Studio Knowledge Base."
