<#
.SYNOPSIS
    Converte i CSV CMDB in formato testo strutturato per Copilot Studio Knowledge Base.

.DESCRIPTION
    Eseguire nella cartella dove si trovano i file cmdb_ci_*.csv
    Output: cartella "output_kb" con file .txt pronti da caricare.

.USAGE
    .\convert_for_copilot_studio.ps1
#>

$OutputDir = "output_kb"
$MaxFileSizeBytes = 2500000  # 2.5 MB

# Crea cartella output
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Configurazione campi per tipo
$ServerFields = [ordered]@{
    "name" = "Nome"
    "u_gbl_system_environment" = "Ambiente"
    "sys_class_name" = "Classe"
    "u_gbl_status_dco_atrium" = "Stato DCO Atrium"
    "sys_updated_on" = "Ultimo aggiornamento"
    "u_last_discovery_date" = "Ultima discovery"
    "sys_created_by" = "Creato da"
    "sys_updated_by" = "Aggiornato da"
    "ip_address" = "Indirizzo IP"
    "os" = "Sistema operativo"
    "u_gbl_apm_application" = "Applicazione APM"
    "u_gbl_apm_application.u_sca_apm_ict_line_level_1_reference" = "ICT Line Level 1"
    "u_gbl_apm_applicationcode" = "Codice applicazione APM"
    "sn_vul_qualys_host_id" = "Qualys Host ID"
    "discovery_source" = "Sorgente discovery"
    "u_gbl_datasource" = "Datasource"
    "u_gbl_role" = "Ruolo"
    "sys_created_on" = "Data creazione"
    "sys_id" = "Sys ID"
}

$ApplFields = [ordered]@{
    "name" = "Nome"
    "sys_class_name" = "Classe"
    "category" = "Categoria"
    "version" = "Versione"
    "operational_status" = "Stato operativo"
}

$BusinessAppFields = [ordered]@{
    "name" = "Nome"
    "short_description" = "Descrizione"
    "apm_business_process" = "Processo di business"
    "application_type" = "Tipo applicazione"
    "architecture_type" = "Tipo architettura"
    "install_type" = "Tipo installazione"
    "install_status" = "Stato installazione"
    "life_cycle_stage_status" = "Stato ciclo di vita"
    "life_cycle_stage" = "Fase ciclo di vita"
    "technology_stack" = "Stack tecnologico"
    "user_base" = "Base utenti"
    "platform" = "Piattaforma"
    "last_change_date" = "Data ultimo cambiamento"
    "owned_by" = "Responsabile"
    "it_application_owner" = "IT Application Owner"
    "sys_updated_by" = "Aggiornato da"
    "business_criticality" = "Criticita business"
    "emergency_tier" = "Tier emergenza"
    "data_classification" = "Classificazione dati"
    "certified" = "Certificato"
    "model_id" = "Model ID"
}

function Convert-RowToText {
    param(
        [Parameter(Mandatory)]$Row,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )
    $lines = @()
    foreach ($key in $FieldMapping.Keys) {
        $value = $Row.$key
        if ($value -and $value.Trim() -ne "") {
            $lines += "$($FieldMapping[$key]): $($value.Trim())"
        }
    }
    return ($lines -join "`n")
}

function Write-ChunkedFiles {
    param(
        [Parameter(Mandatory)][string[]]$TextBlocks,
        [Parameter(Mandatory)][string]$Prefix
    )

    $fileIndex = 1
    $currentContent = ""
    $separator = "`n---`n"
    $filesWritten = @()

    foreach ($block in $TextBlocks) {
        $entry = $block + $separator
        $newSize = [System.Text.Encoding]::UTF8.GetByteCount($currentContent + $entry)

        if ($newSize -gt $MaxFileSizeBytes) {
            if ($currentContent -ne "") {
                $filename = "${Prefix}_${fileIndex}.txt"
                $filepath = Join-Path $OutputDir $filename
                [System.IO.File]::WriteAllText($filepath, $currentContent, [System.Text.UTF8Encoding]::new($false))
                $filesWritten += $filepath
                $fileIndex++
            }
            $currentContent = $entry
        } else {
            $currentContent += $entry
        }
    }

    # Ultimo file
    if ($currentContent -ne "") {
        $filename = "${Prefix}_${fileIndex}.txt"
        $filepath = Join-Path $OutputDir $filename
        [System.IO.File]::WriteAllText($filepath, $currentContent, [System.Text.UTF8Encoding]::new($false))
        $filesWritten += $filepath
    }

    return $filesWritten
}

function Process-Category {
    param(
        [Parameter(Mandatory)][string]$CategoryName,
        [Parameter(Mandatory)][string[]]$Files,
        [Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$FieldMapping
    )

    Write-Host "`n============================================================"
    Write-Host "Elaborazione: $CategoryName"
    Write-Host "============================================================"

    $allRows = @()

    foreach ($file in $Files) {
        if (Test-Path $file) {
            try {
                $rows = Import-Csv -Path $file -Encoding UTF8
            } catch {
                try {
                    $rows = Import-Csv -Path $file -Encoding Default
                } catch {
                    Write-Host "  ERRORE: impossibile leggere $file" -ForegroundColor Red
                    continue
                }
            }
            Write-Host "  Letto $file : $($rows.Count) righe"
            $allRows += $rows
        } else {
            Write-Host "  ATTENZIONE: file non trovato: $file" -ForegroundColor Yellow
        }
    }

    Write-Host "  Totale righe lette: $($allRows.Count)"

    # Deduplicazione
    $seen = @{}
    $uniqueRows = @()
    foreach ($row in $allRows) {
        $key = ($FieldMapping.Keys | ForEach-Object { $row.$_ }) -join "|"
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $uniqueRows += $row
        }
    }

    $duplicatesRemoved = $allRows.Count - $uniqueRows.Count
    Write-Host "  Righe dopo deduplicazione: $($uniqueRows.Count) (rimossi $duplicatesRemoved duplicati)"

    # Converti in testo
    $textBlocks = @()
    foreach ($row in $uniqueRows) {
        $block = Convert-RowToText -Row $row -FieldMapping $FieldMapping
        if ($block.Trim() -ne "") {
            $textBlocks += $block
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

Write-Host "Conversione CSV per Copilot Studio Knowledge Base" -ForegroundColor Cyan
Write-Host "=================================================="

# Server
$serverFiles = @("cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv")
Process-Category -CategoryName "server" -Files $serverFiles -FieldMapping $ServerFields

# Applicazioni
$applFiles = @(
    "cmdb_ci_appl_1.csv", "cmdb_ci_appl_2.csv", "cmdb_ci_appl_3.csv", "cmdb_ci_appl_4.csv",
    "cmdb_ci_appl_5.csv", "cmdb_ci_appl_6.csv", "cmdb_ci_appl_7.csv", "cmdb_ci_appl_8.csv"
)
Process-Category -CategoryName "appl" -Files $applFiles -FieldMapping $ApplFields

# Business App
$businessFiles = @("cmdb_ci_business_app.csv")
Process-Category -CategoryName "business_app" -Files $businessFiles -FieldMapping $BusinessAppFields

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "COMPLETATO!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Cartella output: $OutputDir\"
Write-Host "Carica tutti i file .txt su Copilot Studio Knowledge Base."
