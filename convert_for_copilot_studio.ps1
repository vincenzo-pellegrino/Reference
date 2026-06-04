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

function Fix-ServiceNowCsvLine {
    <#
    .SYNOPSIS
        Corregge una riga CSV nel formato ServiceNow non standard.
        
        Formato ServiceNow: "campo1,""campo2"",""campo3"""
        Dopo fix (CSV standard): campo1,"campo2","campo3"
        
        Il formato e':
        - Riga intera racchiusa tra virgolette esterne
        - Campi interni (dal secondo in poi) delimitati da ""
        - Virgolette vuote "" rappresentano campo vuoto
    #>
    param([string]$Line)

    $trimmed = $Line.Trim()

    # Se la riga non inizia e finisce con ", restituiscila cosi' com'e'
    if (-not ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"'))) {
        return $trimmed
    }

    # Rimuovi virgoletta esterna iniziale e finale
    $inner = $trimmed.Substring(1, $trimmed.Length - 2)

    # Ora il contenuto ha il pattern:
    #   campo1,""campo2"",""campo3"","""",...
    # Dove ,"" e' l'inizio di un campo quotato e "", e' la fine
    # 
    # Strategia: sostituiamo ,"" con ," e "", con ", 
    # poi gestiamo il caso del campo vuoto """" -> ""
    # 
    # Ma attenzione: dobbiamo distinguere tra:
    #   ,"" come inizio campo -> ,"
    #   "" come fine campo prima di , -> ",
    #   """" come campo vuoto -> "",""  (diventa "","")
    #
    # Approccio piu' sicuro: split manuale sul pattern

    # Il separatore tra campi nel formato ServiceNow e':
    #   primo campo: tutto fino alla prima ,""
    #   campi successivi: tra "","" 
    #   ultimo campo: dopo l'ultimo "",  fino alla fine (che termina con "")

    # Split sul pattern "","" per ottenere i campi
    $fields = [System.Collections.Generic.List[string]]::new()
    
    # Troviamo il primo campo (non e' quotato internamente)
    $firstSep = $inner.IndexOf(',""')
    if ($firstSep -eq -1) {
        # Un solo campo, restituisci senza virgolette esterne
        return $inner
    }

    $firstField = $inner.Substring(0, $firstSep)
    $fields.Add($firstField)

    # Il resto dopo il primo ,"" e prima dell'ultimo ""
    $rest = $inner.Substring($firstSep + 2)  # skip the ,"
    # $rest ora inizia con " e il contenuto dei campi successivi separati da "",""
    # e termina con ""

    # Rimuovi la " iniziale e la "" finale
    if ($rest.StartsWith('"')) {
        $rest = $rest.Substring(1)
    }
    if ($rest.EndsWith('""')) {
        $rest = $rest.Substring(0, $rest.Length - 2)
    } elseif ($rest.EndsWith('"')) {
        $rest = $rest.Substring(0, $rest.Length - 1)
    }

    # Ora splittiamo su "","" per ottenere i campi rimanenti
    $remainingFields = $rest -split '""?,""'

    foreach ($f in $remainingFields) {
        # Rimuovi eventuali virgolette residue ai bordi
        $clean = $f.TrimStart('"').TrimEnd('"')
        $fields.Add($clean)
    }

    # Ricostruisci come CSV standard: ogni campo tra virgolette (per sicurezza)
    $csvFields = $fields | ForEach-Object {
        $escaped = $_ -replace '"', '""'
        "`"$escaped`""
    }

    return ($csvFields -join ",")
}

function Import-NonStandardCsv {
    <#
    .SYNOPSIS
        Legge un CSV con formato non standard ServiceNow e restituisce oggetti PSCustomObject.
        Preprocessa le righe e usa ConvertFrom-Csv.
    #>
    param(
        [Parameter(Mandatory)][string]$Path
    )

    # Prova diversi encoding
    $lines = $null
    $encodings = @("utf-8", "iso-8859-1", "windows-1252")

    foreach ($encName in $encodings) {
        try {
            $enc = [System.Text.Encoding]::GetEncoding($encName)
            $lines = [System.IO.File]::ReadAllLines($Path, $enc)
            if ($lines.Count -gt 1) { break }
        } catch {
            continue
        }
    }

    if (-not $lines -or $lines.Count -lt 2) {
        Write-Host "  ERRORE: impossibile leggere o file vuoto: $Path" -ForegroundColor Red
        return @()
    }

    Write-Host "  Preprocessing $($lines.Count) righe..." -NoNewline

    # Correggi tutte le righe
    $fixedLines = [System.Collections.Generic.List[string]]::new($lines.Count)
    foreach ($line in $lines) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $fixedLines.Add((Fix-ServiceNowCsvLine $line))
        }
    }

    Write-Host " done. Parsing CSV..." -NoNewline

    # Unisci e parsa con ConvertFrom-Csv
    $csvText = $fixedLines -join "`n"
    try {
        $results = $csvText | ConvertFrom-Csv
        Write-Host " OK"
        return $results
    } catch {
        Write-Host " ERRORE nel parsing: $_" -ForegroundColor Red
        return @()
    }
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
