# Gestione Centralizzata degli Accessi ai Database Aziendali

## Analisi Executive

**Data:** Marzo 2026 | **Classificazione:** Riservato | **Autore:** vincenzo-pellegrino

---

## 1. Contesto

L'azienda gestisce **43 tecnologie database** distribuite su 10 categorie (RDBMS on-prem, DBaaS cloud, NoSQL, in-memory, time-series, graph, embedded). L'esigenza è governare in modo centralizzato l'accesso a queste tecnologie per utenze interattive (personali), applicative (A2A) e native (DBA), garantendo autenticazione moderna, provisioning automatizzato, auditing completo e conformità normativa.

---

## 2. Panorama dei 43 Database: Compatibilità con Entra ID

L'analisi di compatibilità con Microsoft Entra ID evidenzia una distribuzione eterogenea:

| Livello di Supporto Entra ID | DB | % | Esempi chiave |
|---|:---:|:---:|---|
| ✅ Nativo Control + Data Plane | 8 | 19% | Azure SQL, SQL Server 2022+, Azure PostgreSQL/MySQL, Cosmos DB, MongoDB Atlas, Oracle Cloud |
| 🔶 Supporto Indiretto (SAML/OIDC/Federation) | 9 | 21% | Oracle on-prem ≥19.18, Redshift, SAP HANA, Db2, Neo4j, InfluxDB |
| 🔶 Solo Control Plane via Federation | 10 | 23% | Aurora, DynamoDB, Neptune, Timestream, ElastiCache, RDS, Keyspaces, AlloyDB |
| ❌ Nessun Supporto Nativo | 16 | 37% | PostgreSQL/MySQL/MongoDB/Redis on-prem, MariaDB, Cassandra, Sybase, DB embedded |
| **Totale** | **43** | **100%** | |

**Implicazione strategica:** Solo il 19% dei database supporta nativamente l'autenticazione Entra ID su entrambi i piani. Per il restante 81% è necessario un approccio compensativo basato su PAM (credential vaulting e session proxy).

---

## 3. I Requisiti di Accesso: Perché Non Esiste un'Unica Tecnologia

### 3.1 — Lo Statement

> **Non esiste sul mercato un'unica tecnologia in grado di coprire simultaneamente tutti i requisiti di gestione degli accessi ai database.**

Questa posizione è confermata da Gartner (Magic Quadrant for PAM 2025, Market Guide for IGA 2025) e allineata con i framework di riferimento (NIST Zero Trust, ISO 27001). Il mercato IAM è strutturalmente organizzato in **pilastri specializzati** — nessun vendor ne copre più di 2-3 con un singolo prodotto.

### 3.2 — Perché un'unica tecnologia non è praticabile

Un'unica tecnologia sostitutiva dovrebbe rimpiazzare **non solo la gestione accessi DB**, ma l'intero perimetro funzionale delle quattro piattaforme in essere:

| Piattaforma | Perimetro coperto (oltre i DB) | Sostituibile? |
|---|---|:---:|
| **Microsoft Entra ID** | SSO per migliaia di app SaaS, MFA, Conditional Access, Office 365, device management, B2B federation | ❌ |
| **IMAC** | Lifecycle di tutte le applicazioni aziendali, workflow HR, catalogo servizi IT | ❌ |
| **One Identity Safeguard** | Accesso privilegiato a server, network, cloud console, SSH/RDP session recording | ❌ |
| **Splunk** | SIEM: log da firewall, endpoint, rete, applicazioni, threat detection, incident response | ❌ |

**Conclusione:** Sostituire queste piattaforme con un unico prodotto significherebbe rimpiazzare l'intero stack di Identity, Governance, Privileged Access e Security Monitoring dell'organizzazione. Un approccio monolitico creerebbe un single point of failure architetturale e sacrificherebbe la specializzazione best-in-class di ciascun dominio.

---

## 4. Architettura di Riferimento: Integrazione Best-of-Breed

La strategia corretta è l'**integrazione a layer** delle quattro piattaforme specializzate, ciascuna responsabile del proprio dominio.

### 4.1 — I Quattro Pilastri

```
┌─────────────────────────────────────────────────────────────────────┐
│                          UTENTI & APPLICAZIONI                       │
│   👤 Personali        🖥️ App (A2A interne)      🔗 A2A Esterne      │
└────────┬─────────────────────┬──────────────────────┬───────────────┘
         │                     │                      │
         ▼                     │                      │
┌─────────────────┐            │                      │
│      IMAC       │ ◄── Richieste abilitazione, workflow approvazione,
│  (Governance)   │     catalogo ruoli, campagne attestazione,
│                 │     provisioning/deprovisioning, integrazione HR
└────────┬────────┘            │                      │
         │ SCIM/API            │                      │
         ▼                     │                      │
┌──────────────────────────────┴──────────────────────┴───────────────┐
│                    MICROSOFT ENTRA ID  (IdP)                         │
│  Autenticazione OIDC/SAML · MFA · Conditional Access · Token auth   │
│  Gruppi/ruoli · Managed Identity · Federation verso AWS/GCP         │
└────────┬─────────────────────┬──────────────────────┬───────────────┘
         │ SAML 2.0            │                      │ Managed Identity
         ▼                     │                      │
┌──────────────────────────────┴──────────────────────┴───────────────┐
│                ONE IDENTITY SAFEGUARD  (PAM)                         │
│                                                                      │
│  SPP (Privileged Passwords)    │    SPS (Privileged Sessions)        │
│  · Vault AES-256               │    · Database Proxy                 │
│  · A2A Credential Provider ◄───┘    · Session Recording (video)     │
│  · Password Rotation                · Utenza reale ↔ sessione       │
│  · Policy: A2A ≠ umani              · Command Control               │
│  · JIT Access + Approvazione        · Protocolli: TDS, SQL*Net...   │
└────────┬─────────────────────────────────────────────┬──────────────┘
         │ Credential Injection / Proxy                │ Syslog JSON-CIM
         ▼                                             │
┌──────────────────────────────────────────────────────┤──────────────┐
│                      43 DATABASE                      │              │
│  SQL Server · Oracle · PostgreSQL · MySQL · MongoDB   │              │
│  SAP HANA · Redis · Cosmos DB · Cassandra · Neo4j     │              │
│  DynamoDB · Redshift · Db2 · InfluxDB · ...           │              │
│  Enforcement RBAC locale · Audit nativo · Token auth  │              │
└────────┬──────────────────────────────────────────────┘              │
         │ DB audit log (Syslog/agent)                                │
         ▼                                                            ▼
┌──────────────────────────────────────────────────────────────────────┐
│                        SPLUNK  (SIEM)                                │
│  Ingestion: Safeguard sessions + DB audit + Entra sign-in + IMAC    │
│  Correlazione: Chi → Come → Cosa → Con quale ruolo                  │
│  Alert: A2A abuse, bypass proxy, DDL non autorizzati, fuori orario  │
│  Compliance: SOX, GDPR, NIS2                                        │
└──────────────────────────────────────────────────────────────────────┘
```

### 4.2 — Integrazioni Chiave

| Integrazione | Protocollo | Funzione |
|---|---|---|
| IMAC → Entra ID | SCIM 2.0 / API | Provisioning/deprovisioning automatico |
| Entra ID → Safeguard | SAML 2.0 | Autenticazione federata degli amministratori |
| Entra ID → Database | OIDC / OAuth2 | Token auth per DB compatibili (19% del parco) |
| Safeguard SPP → App | REST API + X.509 | Credential injection A2A (app non conosce la password) |
| Safeguard SPS → Database | Proxy TDS/SQL*Net/PG | Sessione proxied con recording |
| Safeguard → Splunk | Syslog JSON-CIM | Session events, password rotation log |
| Database → Splunk | Syslog / Agent | Audit log nativi (query, login, DDL) |
| Entra ID → Splunk | API / Azure Monitor | Sign-in e audit log |

---

## 5. Copertura dei 17 Requisiti

| # | Requisito | Entra ID | IMAC | Safeguard | Splunk |
|---|---|:---:|:---:|:---:|:---:|
| 1 | Autenticazione centralizzata | ✅ Primario | | ✅ Proxy | |
| 2 | Integrazione Entra ID | ✅ | | ✅ | ✅ |
| 3 | Utenze interattive | ✅ | ✅ | ✅ | ✅ |
| 4 | Utenze A2A esterne | ✅ | ✅ | ✅ | ✅ |
| 5 | Utenze A2A interne (app→DB) | | | ✅ **Primario** | ✅ |
| 6 | Provisioning/Deprovisioning | ✅ | ✅ **Primario** | ✅ | ✅ |
| 7 | RBAC | ✅ | ✅ | | ✅ |
| 8 | Integrazione IMAC | ✅ | ✅ **Primario** | ✅ | ✅ |
| 9 | Auditing completo | ✅ | ✅ | ✅ | ✅ **Primario** |
| 10 | Individuazione utenza reale | ✅ | | ✅ | ✅ **Correlazione** |
| 11 | Campagna attestazione | | ✅ **Primario** | | |
| 12 | Blocco non certificati | ✅ | ✅ | ✅ | |
| 13 | Blocco accesso diretto | | | ✅ **Primario** | ✅ |
| 14 | Inibizione A2A da umani | | | ✅ **Primario** | ✅ |
| 15 | Utenze native | | | ✅ **Primario** | ✅ |
| 16 | Modern auth (token) | ✅ **Primario** | | | |
| 17 | Encryption password | | | ✅ **Primario** | |

**Tutti i 17 requisiti sono coperti dall'architettura integrata.** Nessun singolo pilastro li copre da solo.

---

## 6. Valutazione DBeaver Team Edition

DBeaver Team Edition (piattaforma multi-DB con SSO, RBAC interno, audit query) è stata valutata come ipotesi di accesso centralizzato.

### Posizionamento

DBeaver si colloca come **front-end client** per utenze interattive, **sotto** i pilastri architetturali, non come loro sostituto.

### Sintesi Pro/Contro

| PRO | CONTRO |
|---|---|
| ✅ Client unificato per 100+ DB | ❌ Non è un PAM (no vault, no rotation, no session recording) |
| ✅ SSO nativo con Entra ID (OIDC) | ❌ Non gestisce utenze A2A |
| ✅ RBAC interno e audit query | ❌ Non impedisce accesso diretto al DB |
| ✅ Costo contenuto (~$1.300/anno) | ❌ No provisioning SCIM, no integrazione IMAC |
| ✅ Interfaccia web (CloudBeaver) | ❌ No campagne attestazione |
| | ❌ Se bypassato, perde ogni visibilità |

### Verdetto

| Domanda | Risposta |
|---|:---:|
| Può essere l'unica tecnologia per l'accesso ai DB? | ❌ No |
| Può sostituire Entra ID, Safeguard, IMAC o Splunk? | ❌ No |
| Può essere il client standard per utenze interattive? | ✅ Sì |
| **Valore aggiunto nello stack** | **🟢 Complementare** |

**Raccomandazione:** DBeaver Team Edition può essere adottato come client standard per l'accesso interattivo, a condizione che operi **all'interno** dell'architettura (autenticazione via Entra ID, sessioni via Safeguard SPS, audit su Splunk). Non sostituisce nessun pilastro.

---

## 7. Raccomandazioni Finali

1. **Mantenere l'architettura best-of-breed a 4 pilastri** (Entra ID + IMAC + Safeguard + Splunk). Nessuna unica tecnologia può sostituirla senza perdere copertura funzionale ben oltre il perimetro database.

2. **Prioritizzare la modern authentication** (token Entra ID) per gli 8 DB con supporto nativo, riducendo progressivamente le credenziali locali.

3. **Estendere Safeguard** come compensazione per i 35 DB senza supporto Entra nativo, usando credential injection, database proxy e password rotation automatica.

4. **Garantire audit end-to-end** su Splunk tramite correlazione multi-sorgente: Entra sign-in → Safeguard session → DB audit log → IMAC provisioning.

5. **Valutare DBeaver Team Edition** come client unificato per utenze interattive, integrato con SSO Entra ID e operante tramite il proxy Safeguard SPS.

6. **Non ricercare un'unica tecnologia sostitutiva**: ogni piattaforma dello stack copre funzionalità critiche che vanno ben oltre l'accesso ai database (autenticazione aziendale, accesso privilegiato infrastrutturale, SIEM trasversale, governance di tutte le applicazioni).

---

*Fine documento*