<#
.SYNOPSIS
    Converte i CSV CMDB in formato testo strutturato per Copilot Studio Knowledge Base.

.DESCRIPTION
    I file CSV esportati da ServiceNow hanno un formato non standard:
    ogni riga e' racchiusa tra virgolette esterne e i campi interni usano ""
    come delimitatori. Questo script preprocessa il CSV, lo converte in
    blocchi di testo strutturati e li splitta in file .txt da max 2.5 MB.

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

function Fix-CsvLine {
    <#
    .SYNOPSIS
        Corregge una riga CSV nel formato ServiceNow non standard.
        Formato input:  "campo1,""campo2"",""campo3"""
        Formato output: campo1,"campo2","campo3"
    #>
    param([string]$Line)

    $trimmed = $Line.Trim()

    # Se la riga inizia e finisce con " ed ha "" interni, e' formato ServiceNow
    if ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) {
        # Rimuovi la virgoletta esterna iniziale e finale
        $inner = $trimmed.Substring(1, $trimmed.Length - 2)
        # Sostituisci "" con " (unescape delle virgolette interne)
        $inner = $inner -replace '""', '"'
        return $inner
    }

    return $trimmed
}

function Import-NonStandardCsv {
    <#
    .SYNOPSIS
        Legge un CSV con formato non standard ServiceNow e restituisce oggetti PSCustomObject.
    #>
    param(
        [Parameter(Mandatory)][string]$Path
    )

    $results = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Prova diversi encoding
    $encodings = @(
        [System.Text.Encoding]::UTF8,
        [System.Text.Encoding]::GetEncoding("iso-8859-1"),
        [System.Text.Encoding]::GetEncoding("windows-1252")
    )

    $lines = $null
    foreach ($enc in $encodings) {
        try {
            $lines = [System.IO.File]::ReadAllLines($Path, $enc)
            if ($lines.Count -gt 0) { break }
        } catch {
            continue
        }
    }

    if (-not $lines -or $lines.Count -lt 2) {
        Write-Host "  ERRORE: impossibile leggere o file vuoto: $Path" -ForegroundColor Red
        return $results
    }

    # Correggi header
    $headerLine = Fix-CsvLine $lines[0]

    # Parsa l'header con un CSV reader
    $headerReader = [System.IO.StringReader]::new($headerLine)
    $headerCsvReader = [Microsoft.VisualBasic.FileIO.TextFieldParser]::new($headerReader)
    $headerCsvReader.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
    $headerCsvReader.SetDelimiters(",")
    $headerCsvReader.HasFieldsEnclosedInQuotes = $true
    $headers = $headerCsvReader.ReadFields()
    $headerCsvReader.Close()
    $headerReader.Close()

    # Processa ogni riga dati
    for ($i = 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        $fixedLine = Fix-CsvLine $line

        try {
            $lineReader = [System.IO.StringReader]::new($fixedLine)
            $csvParser = [Microsoft.VisualBasic.FileIO.TextFieldParser]::new($lineReader)
            $csvParser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
            $csvParser.SetDelimiters(",")
            $csvParser.HasFieldsEnclosedInQuotes = $true

            $fields = $csvParser.ReadFields()
            $csvParser.Close()
            $lineReader.Close()

            if ($fields) {
                $obj = [ordered]@{}
                for ($j = 0; $j -lt [Math]::Min($headers.Count, $fields.Count); $j++) {
                    $obj[$headers[$j]] = $fields[$j]
                }
                # Riempi eventuali campi mancanti
                for ($j = $fields.Count; $j -lt $headers.Count; $j++) {
                    $obj[$headers[$j]] = ""
                }
                $results.Add([PSCustomObject]$obj)
            }
        } catch {
            # Riga malformata, skip
            continue
        }
    }

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
            $lines.Add("$($FieldMapping[$key]): $($value.ToString().Trim())")
        }
    }
    return ($lines -join "`n")
}

function Write-ChunkedFiles {
    param(
        [Parameter(Mandatory)][System.Collections.Generic.List[string]]$TextBlocks,
        [Parameter(Mandatory)][string]$Prefix
    )

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
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )

    Write-Host "`n============================================================"
    Write-Host "Elaborazione: $CategoryName"
    Write-Host "============================================================"

    $allRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($file in $CsvFiles) {
        if (Test-Path $file) {
            $rows = Import-NonStandardCsv -Path $file
            Write-Host "  Letto $file : $($rows.Count) righe"
            foreach ($r in $rows) { $allRows.Add($r) }
        } else {
            Write-Host "  ATTENZIONE: file non trovato: $file" -ForegroundColor Yellow
        }
    }

    Write-Host "  Totale righe lette: $($allRows.Count)"

    # Deduplicazione
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $uniqueRows = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($row in $allRows) {
        $keyParts = foreach ($k in $FieldMapping.Keys) { $row.$k }
        $key = $keyParts -join "|"
        if ($seen.Add($key)) {
            $uniqueRows.Add($row)
        }
    }

    $duplicatesRemoved = $allRows.Count - $uniqueRows.Count
    Write-Host "  Righe dopo deduplicazione: $($uniqueRows.Count) (rimossi $duplicatesRemoved duplicati)"

    # Filtra righe senza nome (inutili per la knowledge base)
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

    # Converti in testo
    $textBlocks = [System.Collections.Generic.List[string]]::new()
    foreach ($row in $filteredRows) {
        $block = Convert-RowToText -Row $row -FieldMapping $FieldMapping
        if ($block.Trim() -ne "") {
            $textBlocks.Add($block)
        }
    }

    Write-Host "  Blocchi di testo generati: $($textBlocks.Count)"

    # Scrivi file
    $files = Write-ChunkedFiles -TextBlocks $textBlocks -Prefix "kb_$CategoryName"
    Write-Host "  File generati: $($files.Count)"
    foreach ($f in $files) {
        $sizeMB = [math]::Round((Get-Item $f).Length / 1MB, 2)
        Write-Host "    - $f ($sizeMB MB)"
    }
}

# === ESECUZIONE ===

# Carica assembly per TextFieldParser (parsing CSV robusto)
Add-Type -AssemblyName Microsoft.VisualBasic

Write-Host "Conversione CSV CMDB per Copilot Studio Knowledge Base" -ForegroundColor Cyan
Write-Host "========================================================"
Write-Host "Formato CSV rilevato: ServiceNow (virgolette doppie non standard)"
Write-Host ""

# Server
$serverFiles = @("cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv")
Process-Category -CategoryName "server" -CsvFiles $serverFiles -FieldMapping $ServerFields

# Applicazioni
$applFiles = @(
    "cmdb_ci_appl_1.csv", "cmdb_ci_appl_2.csv", "cmdb_ci_appl_3.csv", "cmdb_ci_appl_4.csv",
    "cmdb_ci_appl_5.csv", "cmdb_ci_appl_6.csv", "cmdb_ci_appl_7.csv", "cmdb_ci_appl_8.csv"
)
Process-Category -CategoryName "appl" -CsvFiles $applFiles -FieldMapping $ApplFields

# Business App
$businessFiles = @("cmdb_ci_business_app.csv")
Process-Category -CategoryName "business_app" -CsvFiles $businessFiles -FieldMapping $BusinessAppFields

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "COMPLETATO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Cartella output: $OutputDir\"
Write-Host "Carica tutti i file .txt su Copilot Studio Knowledge Base."
Write-Host ""
Write-Host "Formato output per ogni record:" -ForegroundColor Gray
Write-Host "  Nome: <valore>" -ForegroundColor Gray
Write-Host "  Classe: <valore>" -ForegroundColor Gray
Write-Host "  ..." -ForegroundColor Gray
Write-Host "  ---" -ForegroundColor Gray
