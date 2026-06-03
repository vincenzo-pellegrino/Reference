"""
Script per convertire i CSV CMDB in formato testo strutturato
compatibile con Microsoft Copilot Studio Knowledge Base.

Uso:
    python convert_for_copilot_studio.py

Requisiti:
    - I file CSV devono essere nella stessa cartella dello script
    - Python 3.7+

Output:
    - Cartella "output_kb/" con file .txt splittati (max 2.5 MB ciascuno)
"""

import csv
import os
import io

OUTPUT_DIR = "output_kb"
MAX_FILE_SIZE_BYTES = 2_500_000  # 2.5 MB per file

# Definizione dei file e dei loro header/mapping
FILE_CONFIGS = {
    "server": {
        "files": ["cmdb_ci_server_1.csv", "cmdb_ci_server_2.csv"],
        "fields": {
            "name": "Nome",
            "u_gbl_system_environment": "Ambiente",
            "sys_class_name": "Classe",
            "u_gbl_status_dco_atrium": "Stato DCO Atrium",
            "sys_updated_on": "Ultimo aggiornamento",
            "u_last_discovery_date": "Ultima discovery",
            "sys_created_by": "Creato da",
            "sys_updated_by": "Aggiornato da",
            "ip_address": "Indirizzo IP",
            "os": "Sistema operativo",
            "u_gbl_apm_application": "Applicazione APM",
            "u_gbl_apm_application.u_sca_apm_ict_line_level_1_reference": "ICT Line Level 1",
            "u_gbl_apm_applicationcode": "Codice applicazione APM",
            "sn_vul_qualys_host_id": "Qualys Host ID",
            "discovery_source": "Sorgente discovery",
            "u_gbl_datasource": "Datasource",
            "u_gbl_role": "Ruolo",
            "sys_created_on": "Data creazione",
            "sys_id": "Sys ID",
        },
    },
    "appl": {
        "files": [
            "cmdb_ci_appl_1.csv",
            "cmdb_ci_appl_2.csv",
            "cmdb_ci_appl_3.csv",
            "cmdb_ci_appl_4.csv",
            "cmdb_ci_appl_5.csv",
            "cmdb_ci_appl_6.csv",
            "cmdb_ci_appl_7.csv",
            "cmdb_ci_appl_8.csv",
        ],
        "fields": {
            "name": "Nome",
            "sys_class_name": "Classe",
            "category": "Categoria",
            "version": "Versione",
            "operational_status": "Stato operativo",
        },
    },
    "business_app": {
        "files": ["cmdb_ci_business_app.csv"],
        "fields": {
            "name": "Nome",
            "short_description": "Descrizione",
            "apm_business_process": "Processo di business",
            "application_type": "Tipo applicazione",
            "architecture_type": "Tipo architettura",
            "install_type": "Tipo installazione",
            "install_status": "Stato installazione",
            "life_cycle_stage_status": "Stato ciclo di vita",
            "life_cycle_stage": "Fase ciclo di vita",
            "technology_stack": "Stack tecnologico",
            "user_base": "Base utenti",
            "platform": "Piattaforma",
            "last_change_date": "Data ultimo cambiamento",
            "owned_by": "Responsabile",
            "it_application_owner": "IT Application Owner",
            "sys_updated_by": "Aggiornato da",
            "business_criticality": "Criticità business",
            "emergency_tier": "Tier emergenza",
            "data_classification": "Classificazione dati",
            "certified": "Certificato",
            "model_id": "Model ID",
        },
    },
}


def read_csv_rows(filepath):
    """Legge un CSV e restituisce le righe come dizionari."""
    rows = []
    encodings = ["utf-8-sig", "utf-8", "latin-1", "cp1252"]

    for enc in encodings:
        try:
            with open(filepath, "r", encoding=enc, errors="replace") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    rows.append(row)
            print(f"  Letto {filepath} ({enc}): {len(rows)} righe")
            return rows
        except Exception as e:
            continue

    print(f"  ERRORE: impossibile leggere {filepath}")
    return []


def row_to_text(row, field_mapping):
    """Converte una riga CSV in blocco di testo strutturato."""
    lines = []
    for csv_field, label in field_mapping.items():
        value = row.get(csv_field, "").strip()
        if value:
            lines.append(f"{label}: {value}")
    return "\n".join(lines)


def deduplicate_rows(rows):
    """Rimuove righe duplicate basandosi su tutti i campi."""
    seen = set()
    unique = []
    for row in rows:
        key = tuple(sorted(row.items()))
        if key not in seen:
            seen.add(key)
            unique.append(row)
    return unique


def write_chunked_files(text_blocks, prefix):
    """Scrive i blocchi di testo in file splittati per dimensione massima."""
    file_index = 1
    current_content = ""
    separator = "\n---\n"
    files_written = []

    for block in text_blocks:
        entry = block + separator
        # Se aggiungere questa entry supera il limite, salva e ricomincia
        if len((current_content + entry).encode("utf-8")) > MAX_FILE_SIZE_BYTES:
            if current_content:
                filename = f"{prefix}_{file_index}.txt"
                filepath = os.path.join(OUTPUT_DIR, filename)
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(current_content)
                files_written.append(filepath)
                file_index += 1
            current_content = entry
        else:
            current_content += entry

    # Scrivi l'ultimo file
    if current_content:
        filename = f"{prefix}_{file_index}.txt"
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(current_content)
        files_written.append(filepath)

    return files_written


def process_category(category_name, config):
    """Processa una categoria di file CSV."""
    print(f"\n{'='*60}")
    print(f"Elaborazione: {category_name}")
    print(f"{'='*60}")

    all_rows = []
    for filepath in config["files"]:
        if os.path.exists(filepath):
            rows = read_csv_rows(filepath)
            all_rows.extend(rows)
        else:
            print(f"  ATTENZIONE: file non trovato: {filepath}")

    print(f"  Totale righe lette: {len(all_rows)}")

    # Deduplica
    unique_rows = deduplicate_rows(all_rows)
    print(f"  Righe dopo deduplicazione: {len(unique_rows)} (rimossi {len(all_rows) - len(unique_rows)} duplicati)")

    # Converti in testo
    text_blocks = []
    for row in unique_rows:
        block = row_to_text(row, config["fields"])
        if block.strip():
            text_blocks.append(block)

    print(f"  Blocchi di testo generati: {len(text_blocks)}")

    # Scrivi file splittati
    files = write_chunked_files(text_blocks, f"kb_{category_name}")
    print(f"  File generati: {len(files)}")
    for f in files:
        size_mb = os.path.getsize(f) / (1024 * 1024)
        print(f"    - {f} ({size_mb:.2f} MB)")

    return files


def main():
    # Crea cartella output
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    all_files = []
    for category_name, config in FILE_CONFIGS.items():
        files = process_category(category_name, config)
        all_files.extend(files)

    print(f"\n{'='*60}")
    print(f"COMPLETATO!")
    print(f"{'='*60}")
    print(f"File totali generati: {len(all_files)}")
    print(f"Cartella output: {OUTPUT_DIR}/")
    print(f"\nCarica tutti i file .txt dalla cartella '{OUTPUT_DIR}' su Copilot Studio Knowledge Base.")


if __name__ == "__main__":
    main()
