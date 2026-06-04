<#
.SYNOPSIS
    Converte i CSV CMDB (formato ServiceNow) in testo per Copilot Studio.

.DESCRIPTION
    L'header e' CSV standard: "name","sys_class_name","category",...
    Le righe dati sono wrappate: "val1,""val2"",""val3"""

.USAGE
    cd <cartella con i CSV>
    .\convert_for_copilot_studio.ps1
#>

$OutputDir = "output_kb"
$MaxFileSizeBytes = 2500000

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
                    $sb.Append('"') | Out-Null
                    $i += 2
                    continue
                } else {
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
    param(
        [string]$Line,
        [int]$ExpectedFields
    )

    $trimmed = $Line.Trim()
    if ($trimmed.Length -gt 0 -and [int]$trimmed[0] -eq 0xFEFF) {
        $trimmed = $trimmed.Substring(1)
    }
    if ($trimmed.Length -lt 2) { return ,@($trimmed) }

    # Tentativo 1: CSV standard
    $fields = Split-CsvFields $trimmed
    if ($fields.Count -ge $ExpectedFields) {
        return ,$fields
    }

    # Tentativo 2: ServiceNow wrap (rimuovi quote esterne, unescape "")
    if ($trimmed[0] -eq '"' -and $trimmed[-1] -eq '"') {
        $inner = $trimmed.Substring(1, $trimmed.Length - 2)
        $unescaped = $inner -replace '""', '"'
        $fields2 = Split-CsvFields $unescaped
        if ($fields2.Count -gt $fields.Count) {
            return ,$fields2
        }
    }

    return ,$fields
}

function Import-SmartCsv {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )

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

    # Parsa header
    $expectedCount = $FieldMapping.Count
    $headerFields = Parse-SmartLine -Line $rawLines[0] -ExpectedFields $expectedCount

    Write-Host " [$($headerFields.Count) col]" -NoNewline

    # Trova posizioni - usa array di coppie (non [ordered]@{} che fallisce con int keys)
    $positions = @()  # array di @{Pos=int; Col=string}
    $mapped = @{}

    for ($i = 0; $i -lt $headerFields.Count; $i++) {
        $colName = $headerFields[$i].Trim()
        if ($FieldMapping.Contains($colName) -and -not $mapped.ContainsKey($colName)) {
            $positions += @{ Pos = $i; Col = $colName }
            $mapped[$colName] = $true
        }
    }

    if ($positions.Count -eq 0) {
        Write-Host " ERRORE MAPPING!" -ForegroundColor Red
        Write-Host "      Header: $($headerFields[0..([Math]::Min(4,$headerFields.Count-1))] -join ' | ')" -ForegroundColor Yellow
        return @()
    }

    Write-Host " [map: $($positions.Count)]" -NoNewline

    # Parsa righe
    $results = [System.Collections.Generic.List[hashtable]]::new()
    $errorCount = 0

    for ($r = 1; $r -lt $rawLines.Count; $r++) {
        $line = $rawLines[$r]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        try {
            $fields = Parse-SmartLine -Line $line -ExpectedFields $headerFields.Count

            $record = @{}
            foreach ($p in $positions) {
                $pos = $p.Pos
                $colName = $p.Col
                if ($pos -lt $fields.Count) {
                    $val = $fields[$pos].Trim()
                    if ($val -ne "") {
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
        Write-Host "      ($errorCount errori)" -ForegroundColor Yellow
    }
    return $results
}

function Write-ChunkedFiles {
    param(
        [string]$Prefix,
        $TextBlocks
    )

    if (-not $TextBlocks -or $TextBlocks.Count -eq 0) { return @() }

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
        if ($removed -gt 0) { Write-Host "  Senza nome rimossi: $removed" }
    }

    # Dedup
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $uniqueRecords = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($rec in $allRecords) {
        $parts = [System.Collections.Generic.List[string]]::new()
        foreach ($k in $FieldMapping.Keys) {
            if ($rec.ContainsKey($k)) { $parts.Add($rec[$k]) } else { $parts.Add("") }
        }
        $key = $parts -join "|"
        if ($seen.Add($key)) { $uniqueRecords.Add($rec) }
    }
    Write-Host "  Unici: $($uniqueRecords.Count) (dup: $($allRecords.Count - $uniqueRecords.Count))"

    # Testo
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
        if ($lines.Count -gt 0) { $textBlocks.Add(($lines -join "`n")) }
    }

    Write-Host "  Blocchi: $($textBlocks.Count)"

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

$serverFiles = @("cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv")
Process-Category -CategoryName "server" -CsvFiles $serverFiles -FieldMapping $ServerFields -RequireName $true

$applFiles = @(
    "cmdb_ci_appl_1.csv", "cmdb_ci_appl_2.csv", "cmdb_ci_appl_3.csv", "cmdb_ci_appl_4.csv",
    "cmdb_ci_appl_5.csv", "cmdb_ci_appl_6.csv", "cmdb_ci_appl_7.csv", "cmdb_ci_appl_8.csv"
)
Process-Category -CategoryName "appl" -CsvFiles $applFiles -FieldMapping $ApplFields -RequireName $true

$businessFiles = @("cmdb_ci_business_app.csv")
Process-Category -CategoryName "business_app" -CsvFiles $businessFiles -FieldMapping $BusinessAppFields -RequireName $false

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "COMPLETATO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Output in: $(Resolve-Path $OutputDir)" -ForegroundColor Green
