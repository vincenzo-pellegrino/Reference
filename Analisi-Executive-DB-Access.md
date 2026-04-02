# Gestione Centralizzata degli Accessi ai Database Aziendali

## Analisi Executive

**Data:** Marzo 2026 | **Classificazione:** Riservato | **Autore:** vincenzo-pellegrino

---

## 1. Contesto

L'azienda gestisce **43 tecnologie database** distribuite su 10 categorie (RDBMS on-prem, DBaaS cloud, NoSQL, in-memory, time-series, graph, embedded). L'esigenza è governare in modo centralizzato l'accesso a queste tecnologie per utenze interattive (personali), applicative (A2A) e native (DBA), garantendo autenticazione moderna, provisioning automatizzato, auditing completo e conformità normativa.

---

## 2. Inventario Completo dei 43 Database

### 2.1 — Elenco per Famiglia Tecnologica

| # | Tecnologia | Deployment | Famiglia |
|:---:|---|---|---|
| 1 | Microsoft SQL Server | On-prem / Self-managed | RDBMS On-prem |
| 2 | Azure SQL Database | Managed Cloud (Azure) | RDBMS Cloud |
| 3 | Oracle DB Enterprise/Standard | On-prem | RDBMS On-prem |
| 4 | Oracle Cloud Infrastructure Database | Managed Cloud (OCI) | RDBMS Cloud |
| 5 | PostgreSQL | On-prem / Self-managed | RDBMS On-prem |
| 6 | Azure Database for PostgreSQL | Managed Cloud (Azure) | RDBMS Cloud |
| 7 | RDS PostgreSQL | Managed Cloud (AWS) | RDBMS Cloud |
| 8 | MySQL | On-prem / Self-managed | RDBMS On-prem |
| 9 | Azure Database for MySQL | Managed Cloud (Azure) | RDBMS Cloud |
| 10 | MySQL su RDS | Managed Cloud (AWS) | RDBMS Cloud |
| 11 | MariaDB | On-prem / Self-managed | RDBMS On-prem |
| 12 | IBM Db2 | On-prem / Cloud | RDBMS On-prem |
| 13 | SAP/Sybase ASE | On-prem | RDBMS On-prem |
| 14 | Sybase SQL Anywhere Server | On-prem | RDBMS On-prem |
| 15 | Sybase Advantage Database Server | On-prem | RDBMS On-prem |
| 16 | Windows Internal Database | On-prem (embedded) | RDBMS On-prem |
| 17 | Amazon Aurora | Managed Cloud (AWS) | RDBMS Cloud |
| 18 | AlloyDB | Managed Cloud (GCP) | RDBMS Cloud |
| 19 | Azure Cosmos DB | Managed Cloud (Azure) | NoSQL Document |
| 20 | MongoDB Enterprise | On-prem / Self-managed | NoSQL Document |
| 21 | MongoDB Atlas | Managed Cloud | NoSQL Document |
| 22 | Apache CouchDB | On-prem | NoSQL Document |
| 23 | ArangoDB | On-prem | NoSQL Document |
| 24 | Amazon DynamoDB | Managed Cloud (AWS) | NoSQL Key-Value |
| 25 | Redis | On-prem / Self-managed | NoSQL Key-Value |
| 26 | Azure Redis Cache | Managed Cloud (Azure) | NoSQL Key-Value |
| 27 | Amazon ElastiCache (Redis) | Managed Cloud (AWS) | NoSQL Key-Value |
| 28 | Amazon SimpleDB | Managed Cloud (AWS) | NoSQL Key-Value |
| 29 | Cassandra | On-prem / Self-managed | NoSQL Wide-Column |
| 30 | DataStax | On-prem / Cloud | NoSQL Wide-Column |
| 31 | Amazon Keyspaces | Managed Cloud (AWS) | NoSQL Wide-Column |
| 32 | Apache HBase | On-prem | NoSQL Wide-Column |
| 33 | SAP HANA Database | On-prem / Self-managed | In-Memory Enterprise |
| 34 | SAP HANA Service (SAP DC) | Managed/Service | In-Memory Enterprise |
| 35 | Apache Derby | Embedded | Embedded DB |
| 36 | H2 Database Engine | Embedded | Embedded DB |
| 37 | HyperSQL (HSQLDB) | Embedded | Embedded DB |
| 38 | SQLite | Embedded (file-based) | Embedded DB |
| 39 | Amazon Redshift | Managed Cloud (AWS) | Data Warehouse |
| 40 | InfluxDB | On-prem / Cloud | Time-Series |
| 41 | Amazon Timestream | Managed Cloud (AWS) | Time-Series |
| 42 | Neo4j | On-prem / Cloud | Graph DB |
| 43 | Amazon Neptune | Managed Cloud (AWS) | Graph DB |

### 2.2 — Clusterizzazione per Categoria

| Categoria | Conteggio | Tecnologie |
|---|:---:|---|
| RDBMS On-prem | 10 | SQL Server, Oracle, PostgreSQL, MySQL, MariaDB, Db2, SAP ASE, Sybase SQL Anywhere, Sybase Advantage, WID |
| RDBMS Cloud / DBaaS | 8 | Azure SQL, Azure PostgreSQL, Azure MySQL, Oracle Cloud, Aurora, RDS PostgreSQL, RDS MySQL, AlloyDB |
| NoSQL Document | 5 | MongoDB on-prem, MongoDB Atlas, Cosmos DB, CouchDB, ArangoDB |
| NoSQL Key-Value | 5 | DynamoDB, Redis, Azure Redis, ElastiCache, SimpleDB |
| NoSQL Wide-Column | 4 | Cassandra, DataStax, Keyspaces, HBase |
| In-Memory Enterprise | 2 | SAP HANA on-prem, SAP HANA Service |
| Embedded DB | 4 | Derby, H2, HSQLDB, SQLite |
| Data Warehouse | 1 | Amazon Redshift |
| Time-Series | 2 | InfluxDB, Amazon Timestream |
| Graph DB | 2 | Neo4j, Amazon Neptune |
| **Totale** | **43** | |

### 2.3 — Distribuzione per Categoria

| Categoria | Conteggio | % | Distribuzione |
|---|:---:|:---:|---|
| RDBMS On-prem | 10 | 23% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ |
| RDBMS Cloud | 8 | 19% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ |
| NoSQL Document | 5 | 12% | ⬛⬛⬛⬛⬛⬛ |
| NoSQL Key-Value | 5 | 12% | ⬛⬛⬛⬛⬛⬛ |
| NoSQL Wide-Column | 4 | 9% | ⬛⬛⬛⬛⬛ |
| In-Memory | 2 | 5% | ⬛⬛⬛ |
| Embedded | 4 | 9% | ⬛⬛⬛⬛⬛ |
| Data Warehouse | 1 | 2% | ⬛ |
| Time-Series | 2 | 5% | ⬛⬛⬛ |
| Graph | 2 | 5% | ⬛⬛⬛ |
| **Totale** | **43** | **100%** | |

### 2.4 — Addon: Capacità Vector DB

Alcuni database del parco offrono funzionalità vector search come addon:

| Database | Feature Vector |
|---|---|
| MongoDB (Atlas) | Vector Search |
| Oracle Database 23ai | Vector indexing integrato |
| PostgreSQL | pgvector (estensione) |
| Redis | VSS / Azure Redis Cache |

---

## 3. Compatibilità con Microsoft Entra ID

### 3.1 — Riepilogo Sintetico

| Livello di Supporto Entra ID | DB | % | Esempi chiave |
|---|:---:|:---:|---|
| ✅ Nativo Control + Data Plane | 8 | 19% | Azure SQL, SQL Server 2022+, Azure PostgreSQL/MySQL, Cosmos DB, MongoDB Atlas, Oracle Cloud |
| 🔶 Supporto Indiretto (SAML/OIDC/Federation) | 9 | 21% | Oracle on-prem ≥19.18, Redshift, SAP HANA, Db2, Neo4j, InfluxDB |
| 🔶 Solo Control Plane via Federation | 10 | 23% | Aurora, DynamoDB, Neptune, Timestream, ElastiCache, RDS, Keyspaces, AlloyDB |
| ❌ Nessun Supporto Nativo | 16 | 37% | PostgreSQL/MySQL/MongoDB/Redis on-prem, MariaDB, Cassandra, Sybase, DB embedded |
| **Totale** | **43** | **100%** | |

### 3.2 — Compatibilità Entra ID

| Livello Supporto | DB | % | Distribuzione |
|---|:---:|:---:|---|
| ✅ Nativo CP+DP | 8 | 19% | ⬛⬛⬛⬛⬛⬛⬛⬛ |
| 🔶 Indiretto (SAML/OIDC) | 9 | 21% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛ |
| 🔶 Solo CP Federation | 10 | 23% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ |
| ❌ Nessun Supporto | 16 | 37% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ |
| **Totale** | **43** | **100%** | |

> **Dato chiave:** Per l'**81%** del parco servono compensazioni via **PAM** (credential vaulting + session proxy tramite Safeguard).

### 3.3 — Dettaglio Completo per Livello

#### ✅ Supporto Nativo Control Plane + Data Plane (8 DB)

| # | Tecnologia | Note |
|:---:|---|---|
| 1 | Azure SQL Database | Supporto completo: utenti, gruppi, managed identity, MFA, conditional access |
| 2 | SQL Server (on-prem) | Da SQL Server 2022: Entra ID nativo, token-based, Cloud Kerberos Trust |
| 3 | Azure Database for PostgreSQL | Token-based auth, managed identity, gruppi Entra, MFA |
| 4 | Azure Database for MySQL | GA dal 2022; utenti Entra, managed identity, token auth |
| 5 | Azure Cosmos DB | RBAC nativo CP+DP per SQL/NoSQL/PostgreSQL API |
| 6 | Azure Redis Cache | GA dal 2024 (Basic/Standard/Premium); NON su tier Enterprise |
| 7 | MongoDB Atlas | Workforce (OIDC) + Workload (OAuth2). Richiede M10+ |
| 8 | Oracle Cloud Infrastructure DB | Da Oracle 19.18/23ai: OAuth2 token-based con Entra ID |

#### 🔶 Supporto Indiretto (9 DB)

| # | Tecnologia | Control Plane | Data Plane | Note |
|:---:|---|---|---|---|
| 9 | Oracle DB on-prem | 🔶 Indiretto | ✅ Nativo | Da 19.18+: OAuth2 nativo |
| 10 | Amazon Redshift | 🔶 SAML→IAM | ✅ Nativo (IdP Fed.) | Native IdP federation OIDC |
| 11 | SAP HANA on-prem | ✅ SAML 2.0 | 🔶 SAML SSO | SSO via SAML 2.0 |
| 12 | SAP HANA Service | 🔶 SAML | 🔶 SAML | Via SAP Cloud Identity Services |
| 13 | IBM Db2 | 🔶 OIDC/LDAP | 🔶 OIDC/LDAP | Cloud: OIDC. On-prem v11.5+: OIDC/LDAP |
| 14 | Neo4j | 🔶 OIDC | 🔶 OIDC | SSO OIDC per Browser, Bloom, backend |
| 15 | InfluxDB | 🔶 OAuth2 | 🔶 OAuth2 | Entra come OIDC provider |
| 16 | DataStax | 🔶 SAML/OIDC | 🔶 SAML/OIDC | Entra come IdP per Astra DB |
| 17 | SAP ASE | 🔶 Indiretto | 🔶 Indiretto | Via SAP Cloud Identity Services |

#### 🔶 Solo Control Plane Federation (10 DB)

| # | Tecnologia | Note |
|:---:|---|---|
| 18 | Amazon Aurora | Federation Entra→AWS IAM. Data plane: solo IAM nativa |
| 19 | Amazon DynamoDB | Accesso API tramite IAM roles |
| 20 | Amazon Neptune | Solo IAM auth |
| 21 | Amazon SimpleDB | Servizio legacy AWS |
| 22 | Amazon Timestream | Solo IAM auth |
| 23 | Amazon ElastiCache | Solo IAM/AUTH key |
| 24 | RDS PostgreSQL | Data plane: solo IAM o user/password |
| 25 | MySQL su RDS | Come RDS PostgreSQL |
| 26 | Amazon Keyspaces | Solo AWS IAM |
| 27 | AlloyDB | Google IAM; Entra federabile a GCP |

#### ❌ Nessun Supporto (16 DB)

| # | Tecnologia | Note |
|:---:|---|---|
| 28 | MongoDB Enterprise (on-prem) | SCRAM/LDAP/x.509/Kerberos. OIDC solo su Atlas |
| 29 | Redis (on-prem) | Solo AUTH/ACL locali |
| 30 | PostgreSQL (on-prem) | md5/scram/LDAP/GSSAPI/cert |
| 31 | MySQL (on-prem) | Auth nativa/LDAP/PAM |
| 32 | MariaDB | Solo tramite proxy/terze parti |
| 33 | Cassandra (on-prem) | Auth interna o LDAP |
| 34 | Sybase SQL Anywhere | Nessun supporto documentato |
| 35 | Sybase Advantage DB | Prodotto legacy |
| 36 | Apache HBase | Auth Kerberos |
| 37 | Apache Derby | DB embedded Java |
| 38 | Apache CouchDB | Auth interna |
| 39 | ArangoDB | Auth interna |
| 40 | H2 Database Engine | DB embedded Java |
| 41 | HyperSQL (HSQLDB) | DB embedded Java |
| 42 | SQLite | File-based, no autenticazione |
| 43 | Windows Internal Database | SQL Server limitato, non esposto |

**Implicazione strategica:** Solo il 19% dei database supporta nativamente Entra ID su entrambi i piani. Per il restante 81% è necessario un approccio compensativo basato su PAM (credential vaulting e session proxy).

---

## 4. I Requisiti di Accesso: Perché Non Esiste un'Unica Tecnologia

### 4.1 — Lo Statement

> **Non esiste sul mercato un'unica tecnologia in grado di coprire simultaneamente tutti i requisiti di gestione degli accessi ai database.**

Questa posizione è confermata da Gartner (Magic Quadrant for PAM 2025, Market Guide for IGA 2025) e allineata con i framework di riferimento (NIST Zero Trust, ISO 27001). Il mercato IAM è strutturalmente organizzato in **pilastri specializzati** — nessun vendor ne copre più di 2-3 con un singolo prodotto.

### 4.2 — Perché un'unica tecnologia non è praticabile

| Piattaforma | Perimetro coperto (oltre i DB) | Sostituibile? |
|---|---|:---:|
| **Microsoft Entra ID** | SSO per migliaia di app SaaS, MFA, Conditional Access, Office 365, device management, B2B federation | ❌ |
| **IMAC** | Lifecycle di tutte le applicazioni aziendali, workflow HR, catalogo servizi IT | ❌ |
| **One Identity Safeguard** | Accesso privilegiato a server, network, cloud console, SSH/RDP session recording | ❌ |
| **Splunk** | SIEM: log da firewall, endpoint, rete, applicazioni, threat detection, incident response | ❌ |

**Conclusione:** Sostituire queste piattaforme con un unico prodotto significherebbe rimpiazzare l'intero stack di Identity, Governance, Privileged Access e Security Monitoring dell'organizzazione. Un approccio monolitico creerebbe un single point of failure architetturale e sacrificherebbe la specializzazione best-in-class di ciascun dominio.

---

## 5. Architettura di Riferimento: Integrazione Best-of-Breed

La strategia corretta è l'**integrazione a layer** delle quattro piattaforme specializzate, ciascuna responsabile del proprio dominio.

### 5.1 — I Quattro Pilastri

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
└─────────┬─────────────────────┬──────────────────────┬───────────────┘
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

### 5.2 — Integrazioni Chiave

| Integrazione | Protocollo | Funzione |
|---|---|---|
| IMAC → Entra ID | SCIM 2.0 / API | Provisioning/deprovisioning automatico |
| Entra ID → Safeguard | SAML 2.0 | Autenticazione federata degli amministratori |
| Entra ID → Database | OIDC / OAuth2 | Token auth per DB compatibili (19% del parco) |
| Safeguard SPP → App | REST API + X.509 | Credential injection A2A |
| Safeguard SPS → Database | Proxy TDS/SQL*Net/PG | Sessione proxied con recording |
| Safeguard → Splunk | Syslog JSON-CIM | Session events, password rotation log |
| Database → Splunk | Syslog / Agent | Audit log nativi (query, login, DDL) |
| Entra ID → Splunk | API / Azure Monitor | Sign-in e audit log |

---

## 6. Copertura dei 17 Requisiti

### 6.1 — Matrice di Copertura

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

### 6.2 — Distribuzione Responsabilità per Pilastro

| Pilastro | Primario | Contributo | Totale | Distribuzione |
|---|:---:|:---:|:---:|---|
| Entra ID | 2 | 9 | 11 | ⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲 |
| IMAC | 3 | 5 | 8 | ⬛⬛⬛🔲🔲🔲🔲🔲 |
| Safeguard | 5 | 7 | 12 | ⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲 |
| Splunk | 1 | 11 | 12 | ⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲 |

⬛ = Primario, 🔲 = Contributo

> **Nota:** 6 requisiti (#2, #3, #4, #7, #10, #12) sono multi-pilastro e non hanno un singolo responsabile primario. Sono conteggiati come "Contributo" per ogni pilastro coinvolto.

---

## 7. Valutazione DBeaver Team Edition

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

### Mappatura DBeaver vs 17 Requisiti

| Copertura | Requisiti | % | Distribuzione | Dettaglio Requisiti |
|---|:---:|:---:|---|---|
| ✅ Coperto | 1 | 6% | ⬛ | #1 |
| 🔶 Parziale | 6 | 35% | ⬛⬛⬛⬛⬛⬛ | #2, #3, #6, #7, #9, #10 |
| ❌ Non coperto | 10 | 59% | ⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ | #4, #5, #8, #11, #12, #13, #14, #15, #16, #17 |
| **Totale** | **17** | **100%** | | |

> **Verdetto:** DBeaver copre solo **1 requisito su 17** in autonomia. Non è un sostituto dei 4 pilastri.

### Verdetto

| Domanda | Risposta |
|---|:---:|
| Può essere l'unica tecnologia per l'accesso ai DB? | ❌ No |
| Può sostituire Entra ID, Safeguard, IMAC o Splunk? | ❌ No |
| Può essere il client standard per utenze interattive? | ✅ Sì |
| **Valore aggiunto nello stack** | **🟢 Complementare** |

**Raccomandazione:** DBeaver Team Edition può essere adottato come client standard per l'accesso interattivo, a condizione che operi **all'interno** dell'architettura (autenticazione via Entra ID, sessioni via Safeguard SPS, audit su Splunk). Non sostituisce nessun pilastro.

---

## 8. Raccomandazioni Finali

1. **Mantenere l'architettura best-of-breed a 4 pilastri** (Entra ID + IMAC + Safeguard + Splunk). Nessuna unica tecnologia può sostituirla senza perdere copertura funzionale ben oltre il perimetro database.

2. **Prioritizzare la modern authentication** (token Entra ID) per gli 8 DB con supporto nativo, riducendo progressivamente le credenziali locali.

3. **Estendere Safeguard** come compensazione per i 35 DB senza supporto Entra nativo, usando credential injection, database proxy e password rotation automatica.

4. **Garantire audit end-to-end** su Splunk tramite correlazione multi-sorgente: Entra sign-in → Safeguard session → DB audit log → IMAC provisioning.

5. **Non ricercare un'unica tecnologia sostitutiva, ad esempio DBeaver Team Edition**: ogni piattaforma dello stack copre funzionalità critiche che vanno ben oltre l'accesso ai database (autenticazione aziendale, accesso privilegiato infrastrutturale, SIEM trasversale, governance di tutte le applicazioni).

6. **Avviare la trasformazione digitale dei DB verso le Reference di caso d'uso** passando da 43 DB gestiti a 10 DB Reference, semplificando notevolmente la gestione operativa e abbassando l'indice di obsolescenza complessivo.
---

*Fine documento*
