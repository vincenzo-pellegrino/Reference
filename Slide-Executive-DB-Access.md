---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }
  h1 {
    color: #0078D4;
  }
  h2 {
    color: #2B579A;
  }
  table {
    font-size: 0.7em;
  }
---

<!-- Slide 1: Title -->

# Gestione Centralizzata Accessi Database
## Analisi Executive — Marzo 2026

**43 tecnologie database** · **4 pilastri architetturali** · **17 requisiti**

> Non esiste un'unica tecnologia. La strategia è l'**integrazione best-of-breed**.

---

<!-- Slide 2: Compatibilità Entra ID -->

# Compatibilità Entra ID: 43 Database Analizzati

| Livello di supporto | # DB | % |
|---|:---:|:---:|
| ✅✅ Nativo Control + Data Plane | **8** | 19% |
| 🔶 Supporto Indiretto (SAML/OIDC) | **9** | 21% |
| 🔶 Solo Control Plane Federation | **10** | 23% |
| ❌❌ Nessun Supporto | **16** | 37% |

**Implicazione:** solo il 19% supporta nativamente Entra ID su entrambi i piani. Per l'81% servono **compensazioni via PAM** (credential vaulting + session proxy).

---

<!-- Slide 3: Architettura a 4 Pilastri -->

# Architettura a 4 Pilastri Integrati

```
         IMAC (Governance)          Standard:
             │ SCIM                  · SAML 2.0, OIDC, OAuth2
             ▼                       · SCIM 2.0
      ENTRA ID (IdP)                · Syslog JSON-CIM
         │        │                 · REST API, X.509
    SAML │        │ Token           · TLS 1.2+, AES-256
         ▼        ▼
    SAFEGUARD   DATABASE
      (PAM)     (43 tech)
         │        │
    Syslog       Audit log
         ▼        ▼
        SPLUNK (SIEM)
```

| Pilastro | Ruolo primario | Perimetro |
|---|---|---|
| **Entra ID** | Autenticazione, SSO, MFA, Token | Tutte le app aziendali |
| **IMAC** | Governance, provisioning, attestazione | Tutte le applicazioni |
| **Safeguard** | Vault, session proxy, credential injection | Tutta l'infrastruttura |
| **Splunk** | Correlazione log, threat detection, compliance | Intera organizzazione |

---

<!-- Slide 4: Copertura Requisiti & DBeaver -->

# 17 Requisiti: Nessun Prodotto Li Copre da Solo

| Area | Primario | Requisiti coperti |
|---|---|---|
| **Autenticazione & Token** | Entra ID | #1, #2, #16 |
| **Governance & Lifecycle** | IMAC | #6, #7, #8, #11 |
| **Privileged Access** | Safeguard | #5, #13, #14, #15, #17 |
| **Audit & Compliance** | Splunk | #9, #10 |
| **Multi-pilastro** | Tutti cooperano | #3, #4, #12 |

### DBeaver Team Edition — Verdetto

| Domanda | Risposta |
|---|---|
| Sostituisce i 4 pilastri? | **❌ No** — copre 1/17 requisiti pienamente |
| Client standard per utenze interattive? | **✅ Sì** — come complemento nello stack |

---

<!-- Slide 5: Raccomandazioni -->

# Raccomandazioni

### ✅ Da fare
1. **Mantenere l'architettura a 4 pilastri** (Entra ID + IMAC + Safeguard + Splunk)
2. **Attivare modern auth (token)** per gli 8 DB con supporto Entra nativo
3. **Estendere Safeguard** come compensazione per i 35 DB senza Entra nativo
4. **Garantire audit end-to-end** su Splunk (Entra → Safeguard → DB → IMAC)
5. **Adottare DBeaver TE** come client unificato, integrato con SSO e proxy PAM

### ❌ Da non fare
- Cercare un'unica tecnologia sostitutiva: ogni piattaforma copre funzionalità **ben oltre i database**
- Adottare un approccio monolitico: creerebbe single point of failure e vendor lock-in

> **Gartner e Forrester confermano:** la convergenza non è completa per nessun vendor nel 2025-2026.
