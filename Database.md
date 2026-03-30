[Analisi Database Aziendali e Gestione accesso 2](#_Toc225781283)

[Database presenti in Azienda 2](#_Toc225781284)

[Clusterizzazione per Use Case gestito 4](#_Toc225781285)

[1) Relazionali (SQL / RDBMS) - on‑prem / self‑managed 4](#_Toc225781286)

[2) Relazionali (SQL) - Managed Cloud / DBaaS 4](#_Toc225781287)

[3) In‑memory Enterprise DB (Real‑time Analytics) 4](#_Toc225781288)

[4) In‑memory / Embedded Relational DB 5](#_Toc225781289)

[5) Cloud Data Warehouse (Analytical DB / MPP) 5](#_Toc225781290)

[6) NoSQL - Document / Multi‑model (document‑oriented) 5](#_Toc225781291)

[7) NoSQL - Key‑Value 5](#_Toc225781292)

[8) NoSQL - Wide‑Column Store 5](#_Toc225781293)

[9) Time‑Series DB 5](#_Toc225781294)

[10) Graph DB 6](#_Toc225781295)

[Vector DB (feature‑addon) 6](#_Toc225781296)

[Compatibilità Database Aziendali con Entra ID 6](#_Toc225781297)

[Legenda 6](#_Toc225781298)

[Tabella di Compatibilità (43 Tecnologie) 6](#_Toc225781299)

[Supporto Nativo Control Plane + Data Plane 7](#_Toc225781300)

[Data Plane Nativo + Control Plane Indiretto 8](#_Toc225781301)

[Supporto Indiretto (SAML/OIDC/Federation) 8](#_Toc225781302)

[Solo Control Plane Indiretto (Federation → IAM cloud provider) 9](#_Toc225781303)

[Nessun Supporto 10](#_Toc225781304)

[Riepilogo Sintetico 12](#_Toc225781305)

[Note Importanti 12](#_Toc225781306)

[Analisi dei Requisiti di Accesso Centralizzato ai Database 13](#_Toc225781307)

[Statement: Perché non esiste un'unica tecnologia 13](#_Toc225781308)

[La posizione di Gartner 13](#_Toc225781309)

[Perché non basta sostituire con un unico prodotto 14](#_Toc225781310)

[Il rischio del "vendor lock-in monolitico" 14](#_Toc225781311)

[Disegno Architetturale 15](#_Toc225781312)

[Diagramma Principale: Flusso Completo 15](#_Toc225781313)

[Protocolli e Standard Utilizzati 17](#_Toc225781314)

[Copertura dei Requisiti nell'Architettura 18](#_Toc225781315)

[Valutazione DBeaver come Ipotesi di Accesso Centralizzato ai Database 20](#_Toc225781316)

[Cos'è DBeaver Team Edition 20](#_Toc225781317)

[Funzionalità di DBeaver Team Edition 20](#_Toc225781318)

[Posizionamento di DBeaver nell'Architettura 22](#_Toc225781319)

[Analisi Pro e Contro 23](#_Toc225781320)

[Mappatura DBeaver vs Requisiti 25](#_Toc225781321)

[Integrazione di DBeaver con lo Stack Tecnologico Attuale 26](#_Toc225781322)

[Scenario di Utilizzo Raccomandato per DBeaver 27](#_Toc225781323)

[Verdetto su DBeaver 28](#_Toc225781324)

[Statement Conclusivo 28](#_Toc225781325)

# Analisi Database Aziendali e Gestione accesso

## Database presenti in Azienda

Sono stati identificati **43 Database** da varie fonti aziendali:

**Microsoft SQL Server**

- Varianti:
  - **SQL Server (on‑prem/self‑managed)**
  - **Azure SQL Database / "Azure SQL Server" (managed cloud)**

**Oracle Database**

- Varianti:
  - **Oracle DB Enterpise - Standard (on‑prem)**
  - **Oracle Cloud Infrastructure Database (managed/service)**

**PostgreSQL**

- Varianti:
  - **PostgreSQL (on‑prem/self‑managed)**
  - **Azure Database for PostgreSQL / Microsoft Azure PostgreSQL (managed cloud)**
  - **RDS PostgreSQL (managed cloud)**

**MySQL**

- Varianti:
  - **MySQL (on‑prem/self‑managed)**
  - **Azure Database for MySQL / Azure MySQL (managed cloud)**
  - **MySQL su RDS (managed cloud)**

**MongoDB**

- Varianti:
  - **MongoDB Enterprise (on‑prem/self‑managed)**
  - **MongoDB Atlas (managed cloud)**

**SAP HANA**

- Varianti:
  - **SAP HANA Database (on‑prem/self‑managed)**
  - **SAP HANA Service (SAP DC) (managed/service)**

**SAP/Sybase (famiglia Sybase in elenco)**

- Varianti:
  - **SAP Adaptive Server Enterprise (ASE) / Sybase ASE**
  - **Sybase SQL Anywhere Server**
  - **Sybase Advantage Database Server**

**Redis**

- Varianti:
  - **Redis (generico)**
  - **Azure Redis Cache (managed)**
  - **Amazon ElastiCache (Redis) (managed)**

**Apache Cassandra (famiglia Cassandra)**

- Varianti:
  - **Cassandra (generico)**
  - **DataStax (Cassandra distribution)**
  - **Amazon Keyspaces (for Apache Cassandra) (managed Cassandra‑compatible)**

**MariaDB**

**Azure Cosmos DB**

**Amazon Aurora**

**Amazon DynamoDB**

**Amazon Redshift**

**Amazon Neptune**

**Amazon SimpleDB**

**Amazon Timestream**

**InfluxDB**

**Neo4j**

**IBM Db2**

**Apache Derby**

**Apache CouchDB**

**ArangoDB**

**H2 Database Engine**

**HyperSQL (HSQLDB)**

**SQLite**

**Windows Internal Database**

**AlloyDB**

**Apache HBase**

### Clusterizzazione per Use Case gestito

#### 1) **Relazionali (SQL / RDBMS) - on‑prem / self‑managed**

- **Microsoft SQL Server** (on‑prem/self‑managed)
- **Oracle Database** (Enterprise/Standard on‑prem)
- **PostgreSQL** (on‑prem/self‑managed)
- **MySQL** (on‑prem/self‑managed)
- **IBM Db2**
- **MariaDB**
- **SAP/Sybase ASE** (SAP ASE / Sybase ASE)
- **Windows Internal Database**
- **Sybase SQL Anywhere Server**
- **Sybase Advantage Database Server**

#### 2) **Relazionali (SQL) - Managed Cloud / DBaaS**

- **Azure SQL Database / "Microsoft Azure SQL Server"**
- **Azure Database for PostgreSQL / Microsoft Azure PostgreSQL**
- **Azure Database for MySQL / Azure MySQL**
- **Oracle Cloud Infrastructure Database** (OCI managed/service)
- **Amazon Aurora**
- **RDS PostgreSQL**
- **MySQL su RDS**
- **AlloyDB**

#### 3) **In‑memory Enterprise DB (Real‑time Analytics)**

- **SAP HANA** (on‑prem / self‑managed)
- **SAP HANA Service (SAP DC)** (managed/service)

#### 4) **In‑memory / Embedded Relational DB**

- **Apache Derby**
- **H2 Database Engine**
- **HyperSQL (HSQLDB)**
- **SQLite**

#### 5) **Cloud Data Warehouse (Analytical DB / MPP)**

- **Amazon Redshift**

#### 6) **NoSQL - Document / Multi‑model (document‑oriented)**

- **MongoDB** (on‑prem / self‑managed)
- **MongoDB Atlas**
- **Azure Cosmos DB**
- **Apache CouchDB**
- **ArangoDB**

#### 7) **NoSQL - Key‑Value**

- **Amazon DynamoDB**
- **Redis**
- **Azure Redis Cache** (managed)
- **Amazon ElastiCache (Redis)** (managed)
- **Amazon SimpleDB**

#### 8) **NoSQL - Wide‑Column Store**

- **Cassandra**
- **DataStax** (Cassandra distribution)
- **Amazon Keyspaces (for Apache Cassandra)** (managed Cassandra compatible)
- **Apache HBase**

#### 9) **Time‑Series DB**

- **InfluxDB**
- **Amazon Timestream**

#### 10) **Graph DB**

- **Neo4j**
- **Amazon Neptune**

#### **Vector DB (**feature‑addon**)**

- **MongoDB** → _Vector Search_ (in particolare Atlas)
- **Oracle Database** → _23ai_ (vector indexing integrato)
- **PostgreSQL** → _pgvector_ (estensione)
- **Redis** → _VSS_ / _Azure Redis Cache_
- **Elasticsearch/OpenSearch** (motore search con vettori / hybrid search)
- **Azure Cognitive Search / Azure AI Search** (servizio search con semantic+vector)

## Compatibilità Database Aziendali con Entra ID

Analisi di compatibilità di 43 tecnologie database con **Microsoft Entra ID** (precedentemente Azure Active Directory), valutando il supporto sia a livello di **Control Plane** (gestione della risorsa/infrastruttura) sia di **Data Plane** (autenticazione per connessione ai dati/esecuzione query).

**Control Plane:** operazioni di gestione della risorsa database (creazione, modifica, eliminazione, configurazione) tramite portali, CLI, API di management. L'autenticazione Entra ID a questo livello consente di gestire chi può amministrare l'infrastruttura.

**Data Plane:** operazioni di accesso ai dati (connessione al database, query, insert, update, delete). L'autenticazione Entra ID a questo livello consente di autenticare utenti e applicazioni direttamente alla connessione dati senza credenziali locali.

### Legenda

- **✅ Nativo** - Supporto nativo integrato con Entra ID, senza componenti aggiuntivi
- **🔶 Indiretto** - Possibile tramite SAML/OIDC/Federation, richiede configurazione aggiuntiva
- **❌ No** - Non supportato nativamente né tramite federazione standard

### Tabella di Compatibilità (43 Tecnologie)

#### Supporto Nativo Control Plane + Data Plane

| **#** | **Tecnologia**                        | **Control Plane** | **Data Plane** | **Note**                                                                                                   |
| ----- | ------------------------------------- | ----------------- | -------------- | ---------------------------------------------------------------------------------------------------------- |
| 1     | Azure SQL Database / Azure SQL Server | ✅ Nativo         | ✅ Nativo      | Supporto completo: utenti, gruppi, managed identity, MFA, conditional access                               |
| 2     | SQL Server (on-prem/self managed)     | ✅ Nativo         | ✅ Nativo      | Da SQL Server 2022: Entra ID nativo su Windows/Linux, token-based, Cloud Kerberos Trust                    |
| 3     | Azure Database for PostgreSQL         | ✅ Nativo         | ✅ Nativo      | Token-based auth, managed identity, gruppi Entra, MFA                                                      |
| 4     | Azure Database for MySQL              | ✅ Nativo         | ✅ Nativo      | GA dal 2022; utenti Entra, managed identity, token auth                                                    |
| 5     | Azure Cosmos DB                       | ✅ Nativo         | ✅ Nativo      | RBAC nativo control+data plane per SQL/NoSQL/PostgreSQL API. Limitato per MongoDB/Gremlin/Table API        |
| 6     | Azure Redis Cache                     | ✅ Nativo         | ✅ Nativo      | GA dal 2024 (Basic/Standard/Premium); token auth, RBAC. NON supportato su tier Enterprise/Enterprise Flash |
| 7     | MongoDB Atlas                         | ✅ Nativo         | ✅ Nativo      | Workforce (OIDC) + Workload (OAuth2) Identity Federation. Richiede M10+. LDAP deprecato in MongoDB 8       |
| 8     | Oracle Cloud Infrastructure Database  | ✅ Nativo         | ✅ Nativo      | Da Oracle 19.18/23ai: OAuth2 token-based con Entra ID; role mapping, managed identity, SSO                 |

#### Data Plane Nativo + Control Plane Indiretto

| **#** | **Tecnologia**                          | **Control Plane**       | **Data Plane**             | **Note**                                                                                       |
| ----- | --------------------------------------- | ----------------------- | -------------------------- | ---------------------------------------------------------------------------------------------- |
| 9     | Oracle DB Enterprise/Standard (on-prem) | 🔶 Indiretto            | ✅ Nativo                  | Da versione 19.18+: OAuth2 nativo con Entra ID. Sotto la 19.18: nessun supporto                |
| 10    | Amazon Redshift                         | 🔶 Indiretto (SAML→IAM) | ✅ Nativo (IdP Federation) | Native IdP federation con Entra ID via OIDC; auto-mapping ruoli, SSO per SQL client e Power BI |

#### Supporto Indiretto (SAML/OIDC/Federation)

| **#** | **Tecnologia**                       | **Control Plane**        | **Data Plane**           | **Note**                                                                                 |
| ----- | ------------------------------------ | ------------------------ | ------------------------ | ---------------------------------------------------------------------------------------- |
| 11    | SAP HANA Database (on-prem)          | ✅ Nativo (SAML 2.0)     | 🔶 Indiretto (SAML SSO)  | SSO via SAML 2.0 per cockpit e app; data plane indiretto con configurazione SAML/JIT     |
| 12    | SAP HANA Service (SAP DC)            | 🔶 Indiretto (SAML)      | 🔶 Indiretto (SAML)      | Via SAP Cloud Identity Services come bridge con Entra ID                                 |
| 13    | IBM Db2                              | 🔶 Indiretto (OIDC/LDAP) | 🔶 Indiretto (OIDC/LDAP) | Cloud (Db2 WoC): OIDC con Azure AD. On-prem (v11.5+): OIDC/LDAP. Legacy: sync via Aquera |
| 14    | Neo4j                                | 🔶 Indiretto (OIDC)      | 🔶 Indiretto (OIDC)      | SSO via OIDC con Entra ID per Browser, Bloom, backend; role mapping via gruppi AD        |
| 15    | InfluxDB                             | 🔶 Indiretto (OAuth2)    | 🔶 Indiretto (OAuth2)    | Entra ID come OIDC provider per admin auth su InfluxDB Clustered/Cloud                   |
| 16    | DataStax (Cassandra distribution)    | 🔶 Indiretto (SAML/OIDC) | 🔶 Indiretto (SAML/OIDC) | Entra ID come IdP SAML/OIDC per Astra DB                                                 |
| 17    | SAP Adaptive Server Enterprise (ASE) | 🔶 Indiretto             | 🔶 Indiretto             | Nessun supporto diretto; possibile via SAP Cloud Identity Services come bridge           |

#### Solo Control Plane Indiretto (Federation → IAM cloud provider)

| **#** | **Tecnologia**               | **Control Plane**            | **Data Plane** | **Note**                                                                       |
| ----- | ---------------------------- | ---------------------------- | -------------- | ------------------------------------------------------------------------------ |
| 18    | Amazon Aurora                | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Federation Entra→AWS IAM Identity Center. Data plane: solo IAM auth nativa AWS |
| 19    | Amazon DynamoDB              | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Accesso API tramite IAM roles; federation Entra→IAM per console/CLI            |
| 20    | Amazon Neptune               | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Solo IAM auth; federation Entra→IAM per console                                |
| 21    | Amazon SimpleDB              | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Servizio legacy AWS; accesso solo via IAM                                      |
| 22    | Amazon Timestream            | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Solo IAM auth; federation Entra→IAM per console                                |
| 23    | Amazon ElastiCache (Redis)   | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Solo IAM/AUTH key; nessun Entra nativo al data plane                           |
| 24    | RDS PostgreSQL               | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Data plane: solo IAM auth AWS o user/password                                  |
| 25    | MySQL su RDS                 | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Come RDS PostgreSQL                                                            |
| 26    | Amazon Keyspaces (Cassandra) | 🔶 Indiretto (SAML→IAM)      | ❌ No          | Solo AWS IAM                                                                   |
| 27    | AlloyDB                      | 🔶 Indiretto (Entra→GCP IAM) | ❌ No          | Auth via Google IAM; Entra federabile a GCP ma login DB non diretto            |

#### Nessun Supporto

| **#** | **Tecnologia**                   | **Control Plane** | **Data Plane** | **Note**                                                                  |
| ----- | -------------------------------- | ----------------- | -------------- | ------------------------------------------------------------------------- |
| 28    | MongoDB Enterprise (on-prem)     | ❌ No             | ❌ No          | Auth SCRAM/LDAP/x.509/Kerberos. OIDC disponibile solo su Atlas            |
| 29    | Redis (generico on-prem)         | ❌ No             | ❌ No          | Redis OSS: solo AUTH/ACL locali, nessun identity provider                 |
| 30    | PostgreSQL (on-prem)             | ❌ No             | ❌ No          | Auth md5/scram/LDAP/GSSAPI/cert. No Entra nativo                          |
| 31    | MySQL (on-prem)                  | ❌ No             | ❌ No          | Auth nativa/LDAP/PAM. No Entra nativo                                     |
| 32    | MariaDB                          | ❌ No             | ❌ No          | Nessun supporto nativo; possibile solo tramite proxy/terze parti          |
| 33    | Cassandra (generico on-prem)     | ❌ No             | ❌ No          | Auth interna o LDAP; no OIDC/SAML nativo                                  |
| 34    | Sybase SQL Anywhere Server       | ❌ No             | ❌ No          | Nessun supporto documentato per Entra ID                                  |
| 35    | Sybase Advantage Database Server | ❌ No             | ❌ No          | Prodotto legacy; nessun supporto                                          |
| 36    | Apache HBase                     | ❌ No             | ❌ No          | Auth Kerberos; indirettamente via Apache Knox ma non nativo               |
| 37    | Apache Derby                     | ❌ No             | ❌ No          | DB embedded Java; auth basica                                             |
| 38    | Apache CouchDB                   | ❌ No             | ❌ No          | Auth interna; no Entra nativo                                             |
| 39    | ArangoDB                         | ❌ No             | ❌ No          | Auth interna; no OIDC/SAML nativo                                         |
| 40    | H2 Database Engine               | ❌ No             | ❌ No          | DB embedded Java; nessun identity provider                                |
| 41    | HyperSQL (HSQLDB)                | ❌ No             | ❌ No          | DB embedded Java; nessun identity provider                                |
| 42    | SQLite                           | ❌ No             | ❌ No          | DB file-based embedded; nessun sistema di autenticazione                  |
| 43    | Windows Internal Database        | ❌ No             | ❌ No          | SQL Server limitato per componenti Windows; non esposto per auth Entra ID |

### Riepilogo Sintetico

| **Livello di supporto**        | **Conteggio** | **Tecnologie**                                                                                                                                                                                 |
| ------------------------------ | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ✅✅ Nativo CP + DP            | 8             | Azure SQL, SQL Server 2022+ on-prem, Azure PostgreSQL, Azure MySQL, Cosmos DB, Azure Redis, MongoDB Atlas, Oracle Cloud DB                                                                     |
| 🔶✅ Indiretto CP + Nativo DP  | 2             | Oracle DB on-prem (≥19.18), Amazon Redshift                                                                                                                                                    |
| ✅🔶 o 🔶🔶 Indiretto entrambi | 7             | SAP HANA on-prem, SAP HANA Service, IBM Db2, Neo4j, InfluxDB, DataStax, SAP ASE                                                                                                                |
| 🔶❌ Solo CP indiretto         | 10            | Aurora, DynamoDB, Neptune, SimpleDB, Timestream, ElastiCache, RDS PostgreSQL, RDS MySQL, Keyspaces, AlloyDB                                                                                    |
| ❌❌ Nessun supporto           | 16            | MongoDB on-prem, Redis on-prem, PostgreSQL on-prem, MySQL on-prem, MariaDB, Cassandra on-prem, Sybase SQL Anywhere, Sybase Advantage, HBase, Derby, CouchDB, ArangoDB, H2, HSQLDB, SQLite, WID |
| **Totale**                     | **43**        |                                                                                                                                                                                                |

### Note Importanti

**Servizi AWS:** Per tutti i servizi Amazon (Aurora, DynamoDB, Neptune, SimpleDB, Timestream, ElastiCache, RDS, Keyspaces), è sempre possibile federare Entra ID con AWS IAM Identity Center via SAML 2.0 per ottenere SSO alla console di gestione. Tuttavia, questo non si traduce in autenticazione Entra ID nativa al data plane (connessione diretta al database), tranne dove esplicitamente indicato (Amazon Redshift Native IdP Federation).

**Servizi Google Cloud:** AlloyDB utilizza Google IAM per l'autenticazione. È possibile federare Entra ID con Google Cloud Identity per il SSO alla console, ma il login diretto al database avviene tramite IAM token o credenziali PostgreSQL native.

**Database embedded/file-based:** SQLite, H2, HSQLDB, Apache Derby non possiedono un sistema di autenticazione enterprise e non sono progettati per integrazione con identity provider esterni.

**Oracle Database on-prem:** Il supporto Entra ID richiede versione 19.18 o successiva. Le versioni precedenti non supportano OAuth2/Entra ID.

**SQL Server on-prem:** Il supporto Entra ID richiede SQL Server 2022 o successivo.

## Analisi dei Requisiti di Accesso Centralizzato ai Database

**Non esiste una singola tecnologia o prodotto che copra tutti i requisiti elencati.** Questa conclusione è confermata da Gartner in tutte le pubblicazioni più recenti (Magic Quadrant for PAM 2025, Market Guide for IGA 2025) e dalle architetture di riferimento di tutti i principali analisti di settore.

La best practice riconosciuta è costruire un'**architettura a layer integrati**, combinando soluzioni best-of-breed che cooperano tramite API, eventi e connettori.

### Statement: Perché non esiste un'unica tecnologia

#### La posizione di Gartner

Gartner identifica **quattro pilastri fondamentali dell'Identity & Access Management** (IAM's 4 Core Pillars - One Identity/Gartner framework):

- **Access Management (AM)** - Autenticazione, SSO, MFA, Federation
- **Identity Governance & Administration (IGA)** - Provisioning, catalogo ruoli, attestazione, compliance
- **Privileged Access Management (PAM)** - Secrets vaulting, session recording, JIT access, credential injection
- **Directory Management (AD/IdP)** - Gestione centralizzata identità, gruppi, attributi

A questi si aggiunge un quinto pilastro trasversale per il contesto database:

- **Database Activity Monitoring (DAM)** - Audit logging, anomaly detection, compliance reporting

**Nessun vendor sul mercato copre completamente tutti e 5 i pilastri con un unico prodotto.** I vendor che più si avvicinano alla convergenza (es. Saviynt con IGA+PAM, CyberArk con PAM+Secrets+Session) coprono al massimo 2-3 pilastri, lasciando sempre scoperti gli altri.

#### Perché non basta sostituire con un unico prodotto

Un'ipotetica singola tecnologia che sostituisse l'intero stack dovrebbe coprire **non solo l'accesso ai database**, ma anche **tutte le altre funzionalità** attualmente erogate dalle tecnologie in essere:

| **Tecnologia attuale** | **Funzionalità coperte (non solo DB)**                                                                                                                                                                                                                  | **Sostituibile con un solo prodotto?**                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Microsoft Entra ID** | Autenticazione di tutti gli utenti aziendali (non solo DB), SSO verso migliaia di applicazioni SaaS, MFA, Conditional Access, Conditional Access per Office 365/Teams/SharePoint, device management, B2B/B2C federation, Privileged Identity Management | ❌ No - è l'IdP aziendale per tutto l'ecosistema, non solo DB |
| **IMAC**               | Portale self-service per richieste di abilitazione a TUTTE le applicazioni aziendali (non solo DB), workflow di approvazione, catalogo servizi IT                                                                                                       | ❌ No - copre il lifecycle di tutte le applicazioni           |
| **Safeguard (PAM)**    | Gestione accessi privilegiati a server, network device, infrastruttura cloud, applicazioni, oltre che a DB. Session recording per SSH/RDP/HTTP, credential vaulting per TUTTE le credenziali privilegiate                                               | ❌ No - copre tutto l'accesso privilegiato infrastrutturale   |
| **Splunk**             | SIEM aziendale: raccolta log da firewall, endpoint, server, applicazioni, network, cloud, oltre che da DB e PAM. Threat detection, incident response, compliance reporting trasversale                                                                  | ❌ No - è il SIEM di tutta l'organizzazione                   |

**Conclusione:** sostituire queste 4 tecnologie con un unico prodotto significherebbe rimpiazzare l'intero stack di Identity, Governance, Privileged Access e Security Monitoring dell'azienda. Questo non è né possibile né consigliabile. La best practice è l'integrazione.

#### Il rischio del "vendor lock-in monolitico"

Gartner e Forrester avvertono esplicitamente che:

- Un approccio monolitico crea **single point of failure** architetturale
- La specializzazione dei vendor (Entra ID per l'autenticazione, CyberArk/Safeguard per il PAM, SailPoint per l'IGA, Splunk per il SIEM) garantisce **best-in-class** su ogni pilastro
- L'integrazione via standard aperti (SAML, OIDC, SCIM, Syslog, REST API) è matura e consolidata
- La convergenza avverrà gradualmente, ma nel 2025-2026 non è ancora completa per nessun vendor

### Disegno Architetturale

#### Diagramma Principale: Flusso Completo

╔══════════════════════════════════════════════════════════════════════════════════╗

║ ATTORI / CONSUMATORI ║

╠══════════════════════════════════════════════════════════════════════════════════╣

║ ║

║ 👤 UTENTE PERSONALE 🖥️ APPLICAZIONE 🔗 INTERFACCIA ESTERNA ║

║ (DBA, analista, sviluppatore) (backend applicativo) (sistema A2A esterno) ║

║ ║

╚═══════╤══════════════════════════════╤═══════════════════════════╤═══════════════╝

│ │ │

│ \[1\] Richiesta accesso │ │

▼ │ │

┌──────────────────────────┐ │ │

│ I M A C │ │ │

│ (Portale Self-Service) │ │ │

│ │ │ │

│ • Richiesta abilitazione │ │ │

│ • Workflow approvazione │ │ │

│ • Catalogo applicazioni │ │ │

└──────────┬───────────────┘ │ │

│ \[2\] Richiesta approvata │ │

│ (API/SCIM) │ │

▼ │ │

┌──────────────────────────────────────┤───────────────────────────┤──────────────┐

│ MICROSOFT ENTRA ID (Identity Provider) │

│ │

│ • Autenticazione centralizzata (OIDC/SAML/OAuth2) │

│ • MFA / Conditional Access │

│ • Gruppi di sicurezza / Ruoli applicativi │

│ • Managed Identity (per app su Azure) │

│ • Token-based authentication per DB compatibili │

│ • Provisioning utenze verso Entra-connected apps │

│ │

│ \[3a\] Token OIDC \[3b\] SAML Federation \[3c\] Managed Identity │

│ (utente pers.) (verso Safeguard) (app Azure → DB) │

└───────┬──────────────────────┬───────────────────────────┬──────────────────────┘

│ │ │

│ │ │

▼ ▼ │

┌──────────────────────────────────────────────────────────┤──────────────────────┐

│ ONE IDENTITY SAFEGUARD (PAM) │ │

│ │ │

│ ┌─────────────────────────────────────────────────────┐ │ │

│ │ SAFEGUARD FOR PRIVILEGED PASSWORDS (SPP) │ │ │

│ │ │ │ │

│ │ • Vault credenziali DB (AES-256) │ │ │

│ │ • Password rotation automatica │ │ │

│ │ • A2A Credential Provider (API REST) ◄─────┼─┘ \[4\] App richiede │

│ │ • Registrazione applicazioni A2A (certificato) │ password via API │

│ │ • JIT access con approvazione │ │

│ │ • Policy: utenze A2A non utilizzabili da umani │ │

│ └─────────────────────────────────────────────────────┘ │

│ │

│ ┌────────   ────────────────────────────────────────────┐ │

│ │ SAFEGUARD FOR PRIVILEGED SESSIONS (SPS) │ │

│ │ │ │

│ │ • Database Proxy (l'utente si collega a SPS, │ │

│ │ SPS inietta le credenziali verso il DB) │ │

│ │ • Session recording completa │ │

│ │ • Associazione utenza reale ↔ sessione DB │ │

│ │ • Blocco comandi pericolosi (command control) │ │

│ │ • Protocolli: SQL\*Net, TDS, PostgreSQL, MySQL... │ │

│ └─────────────────────────────────────────────────────┘ │

│ │

│ Autenticazione amministratori Safeguard: via Entra ID (SAML 2.0 Federation) │

│ │

│ \[5\] Audit log sessioni ──────────────────────────────────────────┐ │

│ (Universal SIEM Forwarder, Syslog JSON-CIM) │ │

└───────┬──────────────────────────────────────────────────────────┬┤─────────────┘

│ ││

│ \[6a\] Connessione proxy \[6b\] Credential inject ││

│ (utente personale) (A2A app→DB) ││

│ ││

▼ ▼│

┌──────────────────────────────────────────────────────────────────┐│

│ D A T A B A S E ││

│ ││

│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ││

│ │SQL Server│ │ Oracle │ │PostgreSQL│ │ MySQL │ ││

│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ ││

│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ││

│ │ MongoDB │ │ SAP HANA │ │ Redis │ │Cosmos DB │ ││

│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ ││

│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ││

│ │Cassandra │ │ Db2 │ │ Redshift │ │ Neo4j │ ... etc. ││

│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ ││

│ ││

│ • Enforcement RBAC locale (ruoli/grant nativi DB) ││

│ • Audit nativo DB (complementare) ││

│ • Entra ID token auth (dove supportato) ││

│ ││

│ \[7\] DB audit log nativi ─────────────────────────────────────┐ ││

└───────────────────────────────────────────────────────────────┤──┘│

│ │

▼ ▼

┌──────────────────────────────────────────────────────────────────────────────┐

│ S P L U N K (SIEM) │

│ │

│ Ingestion da: │

│ ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐ │

│ │ \[5\] Safeguard SPS │ │ \[7\] DB audit log │ │ \[8\] Entra ID │ │

│ │ session events │ │ nativi │ │ sign-in/audit │ │

│ │ (Syslog JSON-CIM)│ │ (Syslog/agent) │ │ log │ │

│ └────────────────────┘ └────────────────────┘ └────────────────────┘ │

│ ┌────────────────────┐ ┌────────────────────┐ │

│ │ \[9\] Safeguard SPP │ │ \[10\] IMAC │ │

│ │ password events │ │ provisioning log │ │

│ │ (rotation, access)│ │ (API/webhook) │ │

│ └────────────────────┘ └────────────────────┘ │

│ │

│ • Correlazione: chi (Entra ID) → cosa ha fatto (Safeguard session) → │

│ quali query (DB audit) → con quale ruolo (provisioning IMAC) │

│ • Dashboard: accessi DB, sessioni privilegiate, anomalie │

│ • Alert: uso improprio utenze A2A, accessi fuori orario, DDL non autorizzati│

│ • Compliance reporting: SOX, GDPR, NIS2 │

│ • Retention: log conservati secondo policy aziendale │

│ │

└──────────────────────────────────────────────────────────────────────────────┘

#### Protocolli e Standard Utilizzati

| **Standard**               | **Dove viene utilizzato**                                                 |
| -------------------------- | ------------------------------------------------------------------------- |
| **SAML 2.0**               | Entra ID ↔ Safeguard (autenticazione federata)                            |
| **OIDC / OAuth2**          | Entra ID ↔ Database (modern authentication token-based)                   |
| **SCIM 2.0**               | IMAC ↔ Entra ID (provisioning/deprovisioning automatico)                  |
| **Syslog (RFC 3164/5424)** | Safeguard → Splunk, DB → Splunk (audit log forwarding)                    |
| **JSON-CIM**               | Formato log Safeguard SPS ottimizzato per Splunk Common Information Model |
| **REST API**               | Safeguard SPP A2A ↔ Applicazioni, IMAC ↔ Safeguard, IMAC ↔ Entra ID       |
| **TLS 1.2+**               | Tutte le comunicazioni in transito                                        |
| **AES-256**                | Encryption credenziali nel vault Safeguard SPP                            |
| **X.509 Certificati**      | Autenticazione applicazioni A2A verso Safeguard SPP                       |

#### Copertura dei Requisiti nell'Architettura

| **#** | **Requisito**                        | **Entra ID**              | **IMAC**                   | **Safeguard (PAM)**                            | **Splunk**                     | **DB nativo**        |
| ----- | ------------------------------------ | ------------------------- | -------------------------- | ---------------------------------------------- | ------------------------------ | -------------------- |
| 1     | Autenticazione centralizzata         | ✅ Primario               |                            | ✅ Proxy per DB non-Entra                      |                                |                      |
| 2     | Integrazione con Entra ID            | ✅                        |                            | ✅ (SAML federation)                           | ✅ (log Entra)                 | ✅ (dove supportato) |
| 3     | Gestione utenze interattive          | ✅ Gruppi/ruoli           | ✅ Richieste               | ✅ Session proxy                               | ✅ Audit                       | ✅ Ruoli locali      |
| 4     | Gestione utenze A2A esterne          | ✅ (token dove possibile) | ✅ Onboarding              | ✅ Vault + API                                 | ✅ Audit                       |                      |
| 5     | Gestione utenze A2A interne (app→DB) |                           |                            | ✅ **Primario** (vault + credential injection) | ✅ Audit                       |                      |
| 6     | Provisioning/Deprovisioning          | ✅ Esecuzione             | ✅ **Primario** (workflow) | ✅ Account privilegiati                        | ✅ Log                         | ✅ Ruoli             |
| 7     | Gestione ruoli RBAC                  | ✅ Gruppi                 | ✅ Catalogo                |                                                |                                | ✅ Enforcement       |
| 8     | Integrazione IMAC                    | ✅ SCIM                   | ✅ **Primario**            | ✅ API                                         | ✅ Log                         |                      |
| 9     | Auditing completo                    | ✅ Sign-in log            | ✅ Prov. log               | ✅ Session recording                           | ✅ **Primario** (correlazione) | ✅ Audit nativo      |
| 10    | Individuazione utenza reale          | ✅ Identità               |                            | ✅ Associazione persona↔sessione               | ✅ **Correlazione**            |                      |
| 11    | Campagna attestazione                |                           | ✅ **Primario**            |                                                |                                |                      |
| 12    | Blocco utenze non certificate        | ✅ Disabilitazione        | ✅ Trigger                 | ✅ Revoca accesso vault                        |                                | ✅ DROP USER         |
| 13    | Blocco accesso diretto al DB         |                           |                            | ✅ **Primario** (solo via proxy)               | ✅ Alert violazioni            | ✅ Firewall regole   |
| 14    | Inibizione uso A2A da umani          |                           |                            | ✅ **Primario** (policy cert+IP)               | ✅ Detection anomalie          |                      |
| 15    | Gestione utenze native               |                           |                            | ✅ **Primario** (vault + rotation)             | ✅ Audit                       |                      |
| 16    | Modern authentication (token)        | ✅ **Primario**           |                            |                                                |                                | ✅ (dove supportato) |
| 17    | Encryption password                  |                           |                            | ✅ **Primario** (AES-256 vault)                |                                | ✅ Hash locale       |

### Valutazione DBeaver come Ipotesi di Accesso Centralizzato ai Database

#### Cos'è DBeaver Team Edition

DBeaver Team Edition è una piattaforma collaborativa per la gestione di database multi-tecnologia, disponibile in modalità desktop e web (CloudBeaver). È progettata per team di sviluppatori, analisti e DBA che necessitano di un punto unico di accesso a molteplici database.

**Edizioni rilevanti:**

- **DBeaver Community** - Open source, uso individuale, funzionalità base
- **DBeaver Enterprise** - Licenza individuale, supporto NoSQL e cloud DB
- **DBeaver Team Edition** - Server centralizzato, collaborazione, RBAC, auditing, SSO

#### Funzionalità di DBeaver Team Edition

| **Funzionalità**                      | **Disponibilità** | **Dettaglio**                                                                                                                                                 |
| ------------------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multi-database support                | ✅ Sì             | 100+ database supportati (SQL Server, Oracle, PostgreSQL, MySQL, MongoDB, Cassandra, Redis, Cosmos DB, Redshift, DynamoDB, SAP HANA, Db2, etc.) via JDBC/ODBC |
| Interfaccia unificata                 | ✅ Sì             | Un unico client (desktop + web) per tutti i DB                                                                                                                |
| SSO con Entra ID                      | ✅ Sì             | Integrazione nativa via OpenID Connect; autenticazione federata con MFA                                                                                       |
| RBAC interno                          | ✅ Sì             | Ruoli e permessi gestibili a livello di Team Edition; assegnazione per utente/gruppo                                                                          |
| Credenziali centralizzate             | ✅ Sì             | Le connessioni DB e credenziali sono gestite centralmente dal server Team Edition                                                                             |
| Audit log query utente                | ✅ Sì             | Log delle query eseguite, con utente, timestamp e database target                                                                                             |
| Collaborazione team                   | ✅ Sì             | Condivisione connessioni, script, dataset tra membri del team                                                                                                 |
| Database proxy                        | ✅ Parziale       | Supporto proxy sessions per connessioni mediate, ma non equivalente a un PAM proxy                                                                            |
| Integrazione IdP esterni              | ✅ Sì             | Active Directory, Okta, Entra ID (SAML/OIDC)                                                                                                                  |
| Integrazione SCIM/provisioning        | ❌ No             | Non supporta provisioning/deprovisioning automatico via SCIM                                                                                                  |
| Integrazione PAM nativa               | ❌ No             | Nessuna integrazione nativa con CyberArk, Safeguard, BeyondTrust                                                                                              |
| Credential injection da vault esterno | ❌ No             | Le credenziali sono nel vault interno DBeaver, non da vault PAM esterni                                                                                       |
| Session recording completa            | ❌ No             | Audit log testuale, ma NON session recording video/replay come PAM                                                                                            |
| Gestione utenze A2A                   | ❌ No             | Progettato per utenze interattive umane, non per connessioni A2A app→DB                                                                                       |
| Password rotation automatica          | ❌ No             | Non gestisce rotazione password su DB                                                                                                                         |
| Blocco accesso diretto al DB          | ❌ No             | Non impedisce accessi diretti al DB al di fuori di DBeaver                                                                                                    |
| Campagne attestazione                 | ❌ No             | Non prevede workflow di attestazione/certificazione accessi                                                                                                   |
| Integrazione IMAC                     | ❌ No             | Non prevede integrazione con portali di richiesta accesso                                                                                                     |
| Export log nativo verso Splunk        | ❌ No nativo      | I log del server possono essere estratti e inviati a Splunk via script/syslog, ma non c'è integrazione nativa                                                 |

#### Posizionamento di DBeaver nell'Architettura

Code

┌──────────────────────────────────────────────────────────────────────┐

│ ARCHITETTURA COMPLETA │

│ │

│ ┌─────────┐ ┌─────────┐ ┌─────────────┐ ┌─────────┐ │

│ │ Entra ID│ │ IMAC │ │ Safeguard │ │ Splunk │ │

│ │ (IdP) │ │ (IGA) │ │ (PAM) │ │ (SIEM) │ │

│ └────┬────┘ └────┬────┘ └──────┬──────┘ └────┬────┘ │

│ │ │ │ │ │

│ └────────────┴───────┬───────┴──────────────┘ │

│ │ │

│ ┌───────┴───────┐ │

│ │ DBeaver │ ◄── Si posiziona QUI: │

│ │ Team Edition │ come CLIENT di accesso │

│ │ │ per utenze INTERATTIVE, │

│ │ (front-end │ SOTTO l'IdP e il PAM, │

│ │ database) │ NON come sostituto │

│ └───────┬───────┘ │

│ │ │

│ ┌───────┴───────┐ │

│ │ DATABASE │ │

│ │ (43 tecnol.) │ │

│ └───────────────┘ │

└──────────────────────────────────────────────────────────────  ───────┘

**DBeaver Team Edition si posiziona come layer di "front-end client" per l'accesso interattivo ai database**, non come sostituto di nessuno dei 4 pilastri architetturali.

#### Analisi Pro e Contro

##### PRO

| **#** | **Vantaggio**                                                                                                        | **Impatto**                                                                              |
| ----- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| 1     | **Unico client multi-database** - Consente di accedere a tutte le 43 tecnologie DB da un'unica interfaccia           | 🟢 Elevato - Standardizza l'esperienza utente e riduce la proliferazione di tool diversi |
| 2     | **SSO nativo con Entra ID** - L'utente si autentica con le credenziali aziendali Entra via OIDC                      | 🟢 Elevato - Elimina credenziali separate per il tool di accesso DB                      |
| 3     | **RBAC interno** - Permette di definire chi può vedere/accedere a quali connessioni DB                               | 🟢 Medio - Aggiunge un layer di controllo, ma non sostituisce il RBAC sul DB             |
| 4     | **Audit log query** - Traccia tutte le query eseguite con utente e timestamp                                         | 🟢 Medio - Complementare (non sostitutivo) al DAM e ai log DB nativi                     |
| 5     | **Gestione centralizzata connessioni** - Le connection string e credenziali sono nel server, non sui PC degli utenti | 🟢 Medio - Riduce il rischio di credenziali sparse su file locali                        |
| 6     | **Interfaccia web (CloudBeaver)** - Accesso via browser senza installazione client                                   | 🟢 Medio - Facilita il deployment e il controllo                                         |
| 7     | **Costo contenuto** - ~\$1.280-1.600/anno per il server, licenze per utente nominativo                               | 🟢 Basso-Medio - Economico rispetto a soluzioni PAM/DAM enterprise                       |
| 8     | **Supporto 100+ database** - Copre tutte le 43 tecnologie dell'analisi e molte altre                                 | 🟢 Elevato - Elimina la necessità di tool specifici per ciascun DB                       |

##### CONTRO

| **#** | **Limite**                                                                                                                                 | **Impatto**      | **Requisito NON coperto**                                          |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- | ------------------------------------------------------------------ |
| 1     | **Non è un PAM** - Non gestisce credential injection, vault, password rotation, session recording video                                    | 🔴 Critico       | Gestione utenze A2A, native, blocco accesso diretto, encryption pw |
| 2     | **Non gestisce utenze A2A** - Progettato per utenze interattive umane, non per connessioni applicazione→DB                                 | 🔴 Critico       | Gestione A2A interne/esterne                                       |
| 3     | **Non impedisce accesso diretto al DB** - Un utente che conosce le credenziali può bypassare DBeaver e connettersi direttamente            | 🔴 Critico       | Blocco accesso utenti diretti                                      |
| 4     | **Non è un IGA** - Non gestisce provisioning/deprovisioning automatico, campagne attestazione, integrazione IMAC                           | 🔴 Critico       | Provisioning, attestazione, IMAC                                   |
| 5     | **Non è un DAM** - L'audit log è limitato alle query eseguite via DBeaver; non cattura attività al di fuori del tool                       | 🔴 Critico       | Auditing completo                                                  |
| 6     | **Non è un SIEM** - Non correla log multi-sorgente, non fa threat detection                                                                | 🔴 Critico       | Auditing, correlazione                                             |
| 7     | **Non integra vault PAM esterni** - Le credenziali sono nel vault interno DBeaver, non recuperate da Safeguard/CyberArk                    | 🟡 Significativo | Modern auth per DB non-Entra                                       |
| 8     | **Nessuna integrazione SCIM** - Non supporta provisioning automatico da Entra ID o IMAC                                                    | 🟡 Significativo | Provisioning/deprovisioning                                        |
| 9     | **Session recording assente** - Registra log testuali, ma non sessioni video/replay forensiche                                             | 🟡 Significativo | Auditing avanzato                                                  |
| 10    | **Export log verso Splunk non nativo** - Richiede script custom o configurazione syslog esterna                                            | 🟡 Significativo | Integrazione SIEM                                                  |
| 11    | **Se bypassato, perde visibilità** - Il controllo esiste solo se tutti usano DBeaver; qualsiasi accesso diretto al DB sfugge completamente | 🔴 Critico       | Blocco accesso diretto                                             |

#### Mappatura DBeaver vs Requisiti

| **#** | **Requisito**                        | **DBeaver lo copre?** | **Note**                                                                        |
| ----- | ------------------------------------ | --------------------- | ------------------------------------------------------------------------------- |
| 1     | Autenticazione centralizzata         | 🔶 Parziale           | SSO Entra ID per login a DBeaver, ma non per TUTTE le modalità di accesso al DB |
| 2     | Integrazione con Entra ID            | ✅ Sì                 | OIDC nativo per autenticazione utenti a DBeaver                                 |
| 3     | Gestione utenze interattive          | 🔶 Parziale           | Gestisce l'accesso via DBeaver, ma non impedisce accessi diretti                |
| 4     | Gestione utenze A2A esterne          | ❌ No                 | Non progettato per questo scenario                                              |
| 5     | Gestione utenze A2A interne (app→DB) | ❌ No                 | Non progettato per questo scenario                                              |
| 6     | Provisioning/Deprovisioning          | ❌ No                 | Nessun supporto SCIM, nessuna integrazione con IMAC                             |
| 7     | Gestione ruoli RBAC                  | 🔶 Parziale           | RBAC interno a DBeaver, ma non governa i ruoli sul DB                           |
| 8     | Integrazione IMAC                    | ❌ No                 | Non prevista                                                                    |
| 9     | Auditing completo                    | 🔶 Parziale           | Solo query eseguite via DBeaver; nessun audit su accessi diretti                |
| 10    | Individuazione utenza reale          | 🔶 Parziale           | Solo se l'utente passa da DBeaver con SSO                                       |
| 11    | Campagna attestazione                | ❌ No                 | Non prevista                                                                    |
| 12    | Blocco utenze non certificate        | ❌ No                 | Non previsto                                                                    |
| 13    | Blocco accesso diretto al DB         | ❌ No                 | Non può impedire connessioni dirette                                            |
| 14    | Inibizione uso A2A da umani          | ❌ No                 | Non previsto                                                                    |
| 15    | Gestione utenze native               | ❌ No                 | Non gestisce credential vaulting/rotation                                       |
| 16    | Modern authentication (token)        | 🔶 Parziale           | Per login a DBeaver sì; per connessione al DB dipende dal driver                |
| 17    | Encryption password                  | ❌ No                 | Vault interno, non enterprise-grade come PAM                                    |

**Risultato: DBeaver copre pienamente 1 requisito su 17, parzialmente 6, e non copre affatto 10.**

#### Integrazione di DBeaver con lo Stack Tecnologico Attuale

| **Integrazione**              | **Fattibilità**        | **Metodo**                                                                                                            | **Limite**                                                                                         |
| ----------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **DBeaver ↔ Entra ID**        | ✅ Nativa              | OIDC / OpenID Connect per SSO                                                                                         | Copre solo l'autenticazione dell'utente a DBeaver, non la credential injection verso il DB         |
| **DBeaver ↔ IMAC**            | ❌ Non prevista        | Nessun connettore                                                                                                     | IMAC non può automaticamente provisionare/deprovisionare accessi su DBeaver                        |
| **DBeaver ↔ Safeguard (PAM)** | 🔶 Parziale/Workaround | L'utente può connettersi a DBeaver passando prima dal proxy Safeguard SPS, oppure DBeaver può usare credenziali proxy | DBeaver non recupera credenziali dal vault Safeguard SPP via API. Non c'è integrazione A2A nativa  |
| **DBeaver ↔ Splunk**          | 🔶 Custom              | Export log del server DBeaver via syslog/script → Splunk                                                              | Non c'è forwarder nativo; richiede configurazione custom (syslog-ng, SC4S, o script periodici)     |
| **DBeaver ↔ Database**        | ✅ Nativa              | JDBC/ODBC per 100+ DB                                                                                                 | Connessione standard; per modern auth (Entra token) dipende dal supporto del driver JDBC specifico |

#### Scenario di Utilizzo Raccomandato per DBeaver

DBeaver Team Edition **non è un'alternativa allo stack architetturale** (Entra ID + IMAC + Safeguard + Splunk), ma può essere un **complemento utile** come client standardizzato per l'accesso interattivo:

Code

👤 Utente ──▶ Entra ID (MFA/SSO) ──▶ Safeguard SPS (proxy) ──▶ DBeaver TE ──▶ Database

│ │

│ │──▶ Query audit log

│ (interno DBeaver)

│

└──▶ Session recording

(Safeguard SPS)

│

└──▶ Splunk

**In questo scenario DBeaver diventa il "client ufficiale"** attraverso cui gli utenti interattivi eseguono query, mantenendo tutti i controlli dello stack:

- L'autenticazione passa comunque da **Entra ID**
- L'accesso privilegiato passa comunque da **Safeguard SPS** (session proxy + recording)
- L'audit completo è comunque garantito da **Splunk** (che riceve log da Safeguard + DB + DBeaver)
- Il provisioning/deprovisioning è comunque gestito da **IMAC**

#### Verdetto su DBeaver

| **Criterio**                                                  | **Valutazione**                                                                                     |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Può DBeaver essere l'unica tecnologia per l'accesso ai DB?    | **❌ No** - mancano troppi requisiti critici (A2A, PAM, IGA, DAM, blocco accesso diretto)           |
| Può DBeaver sostituire Entra ID?                              | **❌ No** - Entra ID gestisce l'intero ecosistema identità aziendale                                |
| Può DBeaver sostituire Safeguard?                             | **❌ No** - nessun vault, rotation, session recording, A2A credential injection                     |
| Può DBeaver sostituire IMAC?                                  | **❌ No** - nessun provisioning/deprovisioning, nessun workflow attestazione                        |
| Può DBeaver sostituire Splunk?                                | **❌ No** - nessuna correlazione multi-sorgente, nessun threat detection                            |
| Può DBeaver essere il client standard per utenze interattive? | **✅ Sì** - come front-end unificato multi-DB, integrato con SSO Entra ID, complementare allo stack |
| Valore aggiunto nello stack                                   | **🟢 Medio** - standardizzazione client, audit query complementare, riduzione tool sprawl           |

### Statement Conclusivo

Alla data della presente analisi (marzo 2026), **non esiste sul mercato un singolo prodotto** che possa sostituire simultaneamente:

- **Microsoft Entra ID** - che gestisce l'autenticazione di decine di migliaia di utenti verso migliaia di applicazioni SaaS, on-prem e cloud, non solo verso i database
- **IMAC** - che gestisce il ciclo di vita delle abilitazioni per tutte le applicazioni aziendali, non solo i database, con workflow personalizzati e integrazione con i processi HR
- **One Identity Safeguard** - che gestisce l'accesso privilegiato a server, dispositivi di rete, infrastruttura cloud e database, con vault, session recording e credential injection
- **Splunk** - che è il SIEM aziendale per la raccolta e correlazione di log da firewall, endpoint, applicazioni, rete, cloud e database

Un eventuale prodotto sostitutivo dovrebbe coprire **tutte queste funzionalità contemporaneamente**, non solo quelle relative all'accesso ai database. Nessun vendor attualmente offre questa completezza, e Gartner non prevede che ciò avvenga nel breve-medio termine.

**DBeaver Team Edition**, pur essendo un ottimo strumento per standardizzare il client di accesso interattivo ai database, **non è un'alternativa a nessuno dei 4 pilastri architetturali**. Si colloca come **complemento a livello di front-end**, utile per ridurre la proliferazione di tool diversi e aggiungere un layer di audit query, ma non può sostituire le funzionalità di autenticazione (Entra ID), governance (IMAC), privileged access (Safeguard) e monitoring (Splunk).

**La strategia corretta è e rimane l'integrazione best-of-breed**, come illustrato nell'architettura di questo documento, sfruttando standard aperti e consolidati (SAML, OIDC, SCIM, Syslog, REST API) per far cooperare le piattaforme specializzate, ciascuna eccellente nel proprio dominio.

Questa architettura garantisce:

- **Nessun single point of failure** architetturale
- **Best-in-class** su ogni pilastro funzionale
- **Flessibilità** nell'evoluzione (un componente può essere sostituito senza impatto sugli altri)
- **Compliance** con i framework di riferimento (Gartner IAM 4 Pillars, NIST Zero Trust, ISO 27001)
- **Audit trail completo end-to-end** dalla richiesta IMAC fino alla singola query SQL eseguita