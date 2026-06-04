<#
.SYNOPSIS
    Converte i CSV CMDB (formato ServiceNow) in testo per Copilot Studio.

.DESCRIPTION
    Formato dei file:
    - Header: CSV standard con campi quotati ("name","sys_class_name",...)
    - Righe dati: formato ServiceNow wrappato ("val1,""val2"",""val3""")
    
    Lo script detecta automaticamente il formato di ogni riga.

.USAGE
    cd <cartella con i CSV>
    .\convert_for_copilot_studio.ps1
#>

$OutputDir = "output_kb"
$MaxFileSizeBytes = 2500000  # 2.5 MB per file

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# === CONFIGURAZIONE ===

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

function Split-CsvFields {
    <#
    .SYNOPSIS
        Parsa una riga CSV standard in un array di valori.
        Gestisce campi quotati, virgole interne, quote escaped ("").
    #>
    param([string]$Line)

    $fields = [System.Collections.Generic.List[string]]::new()
    $sb = [System.Text.StringBuilder]::new()
    $inQuotes = $false
    $i = 0
    $len = $Line.Length

    while ($i -lt $len) {
        $c = $Line[$i]

        if ($inQuotes) {
            if ($c -eq '"') {
                if (($i + 1) -lt $len -and $Line[$i + 1] -eq '"') {
                    # Escaped quote ""
                    $sb.Append('"') | Out-Null
                    $i += 2
                    continue
                } else {
                    # Fine campo quotato
                    $inQuotes = $false
                    $i++
                    continue
                }
            } else {
                $sb.Append($c) | Out-Null
            }
        } else {
            if ($c -eq '"') {
                $inQuotes = $true
            } elseif ($c -eq ',') {
                $fields.Add($sb.ToString())
                $sb.Clear() | Out-Null
            } else {
                $sb.Append($c) | Out-Null
            }
        }
        $i++
    }
    $fields.Add($sb.ToString())

    return ,$fields.ToArray()
}

function Parse-SmartLine {
    <#
    .SYNOPSIS
        Parsa una riga detectando automaticamente il formato:
        
        Formato A (CSV standard): "name","sys_class_name","category"
          -> Dopo il primo " si trova il contenuto del primo campo, poi "," separa i campi
          
        Formato B (ServiceNow wrapped): "val1,""val2"",""val3"""
          -> Tutta la riga e' wrappata in virgolette esterne, i separatori interni sono ,""
          
        Come distinguerli:
          - Se dopo la prima " troviamo "," (quote-comma-quote) PRIMA di trovare ,"" (comma-quote-quote)
            -> e' formato A (CSV standard)
          - Altrimenti -> formato B (ServiceNow)
          
        Approccio pratico: prova come CSV standard, se otteniamo il numero atteso di campi, ok.
        Altrimenti prova ServiceNow unwrap.
    #>
    param(
        [string]$Line,
        [int]$ExpectedFields
    )

    $trimmed = $Line.Trim()
    # Rimuovi BOM se presente
    if ($trimmed.Length -gt 0 -and [int]$trimmed[0] -eq 0xFEFF) {
        $trimmed = $trimmed.Substring(1)
    }

    if ($trimmed.Length -lt 2) { return ,$trimmed }

    # Tentativo 1: parsa come CSV standard
    $fields = Split-CsvFields $trimmed
    if ($fields.Count -ge $ExpectedFields) {
        return ,$fields
    }

    # Tentativo 2: se la riga inizia e finisce con ", prova ServiceNow unwrap
    if ($trimmed[0] -eq '"' -and $trimmed[-1] -eq '"') {
        $inner = $trimmed.Substring(1, $trimmed.Length - 2)
        $unescaped = $inner -replace '""', '"'
        $fields2 = Split-CsvFields $unescaped
        if ($fields2.Count -ge $ExpectedFields) {
            return ,$fields2
        }
        # Se neanche cosi' funziona, restituisci comunque il meglio che abbiamo
        if ($fields2.Count -gt $fields.Count) {
            return ,$fields2
        }
    }

    return ,$fields
}

function Import-SmartCsv {
    <#
    .SYNOPSIS
        Legge un file CSV con auto-detect del formato (standard o ServiceNow).
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )

    # Leggi file
    $rawLines = $null
    foreach ($encName in @("utf-8", "iso-8859-1", "windows-1252")) {
        try {
            $enc = [System.Text.Encoding]::GetEncoding($encName)
            $rawLines = [System.IO.File]::ReadAllLines($Path, $enc)
            if ($rawLines.Count -gt 1) { break }
        } catch { continue }
    }

    if (-not $rawLines -or $rawLines.Count -lt 2) {
        Write-Host " ERRORE: file vuoto" -ForegroundColor Red
        return @()
    }

    # Parsa header - prova con tanti campi quanti ne cerchiamo
    $expectedCount = $FieldMapping.Count
    $headerFields = Parse-SmartLine -Line $rawLines[0] -ExpectedFields $expectedCount

    Write-Host " [$($headerFields.Count) colonne]" -NoNewline

    # Trova posizioni dei campi che ci interessano
    $positionMap = [ordered]@{}
    $mapped = @{}

    for ($i = 0; $i -lt $headerFields.Count; $i++) {
        $colName = $headerFields[$i].Trim()
        if ($FieldMapping.Contains($colName) -and -not $mapped.ContainsKey($colName)) {
            $positionMap[$i] = $colName
            $mapped[$colName] = $true
        }
    }

    if ($positionMap.Count -eq 0) {
        Write-Host " ERRORE MAPPING!" -ForegroundColor Red
        Write-Host "      Primi 5 header: $($headerFields[0..([Math]::Min(4,$headerFields.Count-1))] -join ' | ')" -ForegroundColor Yellow
        return @()
    }

    Write-Host " [mappati: $($positionMap.Count)]" -NoNewline

    # Parsa righe dati
    $results = [System.Collections.Generic.List[hashtable]]::new()
    $errorCount = 0

    for ($r = 1; $r -lt $rawLines.Count; $r++) {
        $line = $rawLines[$r]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        try {
            $fields = Parse-SmartLine -Line $line -ExpectedFields $headerFields.Count

            $record = @{}
            foreach ($pos in $positionMap.Keys) {
                if ($pos -lt $fields.Count) {
                    $val = $fields[$pos].Trim()
                    if ($val -ne "") {
                        $colName = $positionMap[$pos]
                        $record[$colName] = $val
                    }
                }
            }

            if ($record.Count -gt 0) {
                $results.Add($record)
            }
        } catch {
            $errorCount++
        }
    }

    Write-Host " -> $($results.Count) record"
    if ($errorCount -gt 0) {
        Write-Host "      ($errorCount errori di parsing)" -ForegroundColor Yellow
    }
    return $results
}

function Write-ChunkedFiles {
    param(
        [string]$Prefix,
        $TextBlocks
    )

    if (-not $TextBlocks -or $TextBlocks.Count -eq 0) {
        return @()
    }

    $fileIndex = 1
    $sb = [System.Text.StringBuilder]::new()
    $separator = "`n---`n"
    $filesWritten = [System.Collections.Generic.List[string]]::new()
    $currentSize = 0

    foreach ($block in $TextBlocks) {
        $entry = $block + $separator
        $entrySize = [System.Text.Encoding]::UTF8.GetByteCount($entry)

        if (($currentSize + $entrySize) -gt $MaxFileSizeBytes -and $sb.Length -gt 0) {
            $filename = "${Prefix}_${fileIndex}.txt"
            $filepath = Join-Path $OutputDir $filename
            [System.IO.File]::WriteAllText($filepath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
            $filesWritten.Add($filepath)
            $fileIndex++
            $sb.Clear() | Out-Null
            $currentSize = 0
        }
        $sb.Append($entry) | Out-Null
        $currentSize += $entrySize
    }

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
        [bool]$RequireName = $true
    )

    Write-Host "`n============================================================"
    Write-Host "Elaborazione: $CategoryName"
    Write-Host "============================================================"

    $allRecords = [System.Collections.Generic.List[hashtable]]::new()

    foreach ($file in $CsvFiles) {
        if (Test-Path $file) {
            Write-Host "  $file" -NoNewline
            $rows = Import-SmartCsv -Path $file -FieldMapping $FieldMapping
            if ($rows -and $rows.Count -gt 0) {
                foreach ($r in $rows) { $allRecords.Add($r) }
            }
        } else {
            Write-Host "  FILE NON TROVATO: $file" -ForegroundColor Yellow
        }
    }

    Write-Host "`n  Totale record: $($allRecords.Count)"

    if ($allRecords.Count -eq 0) {
        Write-Host "  Nessun dato." -ForegroundColor Yellow
        return
    }

    # Filtra record senza nome
    if ($RequireName) {
        $before = $allRecords.Count
        $filtered = [System.Collections.Generic.List[hashtable]]::new()
        foreach ($rec in $allRecords) {
            if ($rec.ContainsKey("name") -and $rec["name"].Trim() -ne "") {
                $filtered.Add($rec)
            }
        }
        $allRecords = $filtered
        $removed = $before - $allRecords.Count
        if ($removed -gt 0) {
            Write-Host "  Senza nome rimossi: $removed"
        }
    }

    # Deduplicazione
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $uniqueRecords = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($rec in $allRecords) {
        $parts = [System.Collections.Generic.List[string]]::new()
        foreach ($k in $FieldMapping.Keys) {
            if ($rec.ContainsKey($k)) { $parts.Add($rec[$k]) } else { $parts.Add("") }
        }
        $key = $parts -join "|"
        if ($seen.Add($key)) {
            $uniqueRecords.Add($rec)
        }
    }

    Write-Host "  Unici: $($uniqueRecords.Count) (duplicati rimossi: $($allRecords.Count - $uniqueRecords.Count))"

    # Converti in blocchi di testo
    $textBlocks = [System.Collections.Generic.List[string]]::new()
    foreach ($rec in $uniqueRecords) {
        $lines = [System.Collections.Generic.List[string]]::new()
        foreach ($csvCol in $FieldMapping.Keys) {
            if ($rec.ContainsKey($csvCol)) {
                $val = $rec[$csvCol] -replace '[\r\n]+', ' '
                if ($val.Trim() -ne "") {
                    $lines.Add("$($FieldMapping[$csvCol]): $val")
                }
            }
        }
        if ($lines.Count -gt 0) {
            $textBlocks.Add(($lines -join "`n"))
        }
    }

    Write-Host "  Blocchi testo: $($textBlocks.Count)"

    if ($textBlocks.Count -gt 0) {
        $files = Write-ChunkedFiles -TextBlocks $textBlocks -Prefix "kb_$CategoryName"
        Write-Host "  FILE GENERATI: $($files.Count)" -ForegroundColor Green
        foreach ($f in $files) {
            $sizeMB = [math]::Round((Get-Item $f).Length / 1MB, 2)
            Write-Host "    -> $f ($sizeMB MB)"
        }
    } else {
        Write-Host "  Nessun output." -ForegroundColor Yellow
    }
}

# === ESECUZIONE ===

Write-Host ""
Write-Host "=== CSV CMDB -> Copilot Studio Knowledge Base ===" -ForegroundColor Cyan
Write-Host "Output: .\$OutputDir\"
Write-Host ""

# Server
$serverFiles = @("cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv")
Process-Category -CategoryName "server" -CsvFiles $serverFiles -FieldMapping $ServerFields -RequireName $true

# Applicazioni
$applFiles = @(
    "cmdb_ci_appl_1.csv", "cmdb_ci_appl_2.csv", "cmdb_ci_appl_3.csv", "cmdb_ci_appl_4.csv",
    "cmdb_ci_appl_5.csv", "cmdb_ci_appl_6.csv", "cmdb_ci_appl_7.csv", "cmdb_ci_appl_8.csv"
)
Process-Category -CategoryName "appl" -CsvFiles $applFiles -FieldMapping $ApplFields -RequireName $true

# Business App
$businessFiles = @("cmdb_ci_business_app.csv")
Process-Category -CategoryName "business_app" -CsvFiles $businessFiles -FieldMapping $BusinessAppFields -RequireName $false

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "COMPLETATO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Output in: $(Resolve-Path $OutputDir)" -ForegroundColor Green
Write-Host ""
Write-Host "Carica i file .txt su Copilot Studio -> Knowledge -> File upload"
