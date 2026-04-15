# Dune Analytics: Stablecoin Flow Pipeline

Multi-Chain Stablecoin-Tracking-Pipeline fuer [Dune Analytics](https://dune.com). Trackt Transfers, Volumen, Supply, Bridge-Flows und Whale-Aktivitaet der wichtigsten Stablecoins ueber 7+ EVM-Chains.

## Unterstuetzte Stablecoins

| Symbol | Issuer | Typ | Chains |
|--------|--------|-----|--------|
| USDT | Tether | Centralized | Ethereum, BNB, Polygon, Arbitrum, Optimism, Avalanche, Base |
| USDC | Circle | Centralized | Ethereum, BNB, Polygon, Arbitrum, Optimism, Avalanche, Base |
| DAI | MakerDAO | Decentralized | Ethereum, Polygon, Arbitrum, Optimism, Base |
| USDS | Sky | Decentralized | Ethereum |
| FRAX | Frax Finance | Hybrid | Ethereum, Arbitrum, Optimism |
| GHO | Aave | Decentralized | Ethereum |
| crvUSD | Curve | Decentralized | Ethereum |
| PYUSD | PayPal | Centralized | Ethereum |
| USDe | Ethena | Hybrid | Ethereum |
| FDUSD | First Digital | Centralized | Ethereum, BNB |
| LUSD | Liquity | Decentralized | Ethereum |
| TUSD | TrueUSD | Centralized | Ethereum, BNB |

## Pipeline-Uebersicht

```
queries/
├── 00_stablecoin_reference.sql   # Referenztabelle: Adressen, Decimals, Kategorien
├── 01_stablecoin_transfers.sql   # Basis-Transfers aller Stablecoins (multi-chain)
├── 02_daily_volume.sql           # Taegliches Volumen mit gleitenden Durchschnitten
├── 03_net_flows.sql              # Net Flows zu/von CEX, DEX, Bridges
├── 04_supply_metrics.sql         # Mint/Burn-Tracking und Supply-Entwicklung
├── 05_bridge_flows.sql           # Cross-Chain Bridge Flow Analyse
├── 06_whale_tracking.sql         # Whale-Transfer Monitoring (>= 1M)
└── 07_dashboard_summary.sql      # Dashboard KPIs und Marktanteile
```

## Architektur: Daten-Pipeline Flow

Das folgende Diagramm zeigt, wie die Queries aufeinander aufbauen und welche Dune-Datenquellen genutzt werden:

```mermaid
flowchart TB
    subgraph Dune_Spells["Dune Datenquellen"]
        TT["tokens.transfers\n(ERC20 Transfers)"]
        LA["labels.addresses\n(CEX/DEX/Bridge Labels)"]
    end

    subgraph Reference["Konfiguration"]
        Q00["00 - Stablecoin Reference\nAdressen, Decimals, Kategorien\n(12 Stablecoins x 7 Chains)"]
    end

    subgraph Basis["Basis-Layer"]
        Q01["01 - Stablecoin Transfers\nAlle ERC20-Transfers\nKlassifizierung: micro → mega_whale\nTyp: mint / burn / transfer"]
    end

    subgraph Analyse["Analyse-Layer"]
        Q02["02 - Daily Volume\nTaegliches Volumen\n7d/30d Moving Averages\nUnique Addresses"]
        Q03["03 - Net Flows\nCEX / DEX / Bridge Flows\nKumulativer CEX Net Flow\nMarkt-Signal"]
        Q04["04 - Supply Metrics\nMint/Burn Tracking\nNet Supply Change\nMint/Burn Ratio"]
        Q05["05 - Bridge Flows\nCross-Chain Analyse\nIncoming/Outgoing\nNet Bridge Flow"]
        Q06["06 - Whale Tracking\nTransfers >= 1M USD\nKategorisierung\nSender/Empfaenger Labels"]
    end

    subgraph Dashboard["Dashboard-Layer"]
        Q07["07 - Dashboard Summary\nKPIs pro Stablecoin/Chain\nMarktanteile\nGlobale Metriken"]
    end

    Q00 -->|Contract Addresses| Q01
    TT -->|Transfer-Daten| Q01
    Q01 -->|Basis-Transfers| Q02
    Q01 -->|Basis-Transfers| Q03
    Q01 -->|Mint/Burn Events| Q04
    Q01 -->|Bridge Transfers| Q05
    Q01 -->|Grosse Transfers| Q06
    LA -->|Adress-Labels| Q03
    LA -->|Adress-Labels| Q05
    LA -->|Adress-Labels| Q06
    Q02 -->|Volumen-KPIs| Q07
    Q04 -->|Supply-KPIs| Q07

    style Dune_Spells fill:#1a1a2e,stroke:#e94560,color:#fff
    style Reference fill:#16213e,stroke:#0f3460,color:#fff
    style Basis fill:#0f3460,stroke:#533483,color:#fff
    style Analyse fill:#533483,stroke:#e94560,color:#fff
    style Dashboard fill:#e94560,stroke:#fff,color:#fff
```

## Dashboard-Layout: So sieht es auf Dune aus

Wenn die Queries live auf Dune laufen, wird das Dashboard wie folgt aufgebaut:

```mermaid
block-beta
    columns 4

    block:header:4
        title["STABLECOIN FLOW DASHBOARD"]
    end

    block:kpis:4
        kpi1["Counter\nTotal Volume\n24h: $12.4B"]
        kpi2["Counter\nTransactions\n24h: 847K"]
        kpi3["Counter\nUnique Addresses\n24h: 234K"]
        kpi4["Counter\nNet Supply Change\n+$142M"]
    end

    block:charts1:4
        vol["Line Chart\nDaily Volume\n(Query 02)\n7d/30d MA"]
        vol:2
        cex["Bar Chart\nCEX Net Flows\n(Query 03)\nSell Pressure Signal"]
        cex:2
    end

    block:charts2:4
        supply["Area Chart\nSupply Evolution\n(Query 04)\nMint/Burn Ratio"]
        supply:2
        bridge["Sankey/Bar Chart\nBridge Flows\n(Query 05)\nCross-Chain"]
        bridge:2
    end

    block:tables:4
        whale["Table: Whale Alerts (Query 06)\nDatum | Stablecoin | Betrag | Von → Nach | Kategorie"]
        whale:3
        share["Pie Chart\nMarktanteile\n(Query 07)"]
    end

    style header fill:#1a1a2e,stroke:#e94560,color:#fff
    style kpis fill:#16213e,stroke:#0f3460,color:#fff
    style charts1 fill:#0f3460,stroke:#533483,color:#fff
    style charts2 fill:#0f3460,stroke:#533483,color:#fff
    style tables fill:#533483,stroke:#e94560,color:#fff
```

## Visualisierungs-Zuordnung

Jede Query erzeugt spezifische Visualisierungen auf dem Dune Dashboard:

```mermaid
flowchart LR
    subgraph Queries["SQL Queries"]
        Q02["02 Daily Volume"]
        Q03["03 Net Flows"]
        Q04["04 Supply Metrics"]
        Q05["05 Bridge Flows"]
        Q06["06 Whale Tracking"]
        Q07["07 Dashboard Summary"]
    end

    subgraph Widgets["Dune Dashboard Widgets"]
        W1["Line Chart\nVolumen-Trend\nueber Zeit"]
        W2["Bar Chart\nCEX Net Flow\npro Tag"]
        W3["Area Chart\nKumulativer\nSupply Change"]
        W4["Stacked Bar\nBridge In/Out\npro Chain"]
        W5["Table\nWhale Alerts\nmit Labels"]
        W6a["Counter\nGlobal KPIs"]
        W6b["Pie Chart\nMarktanteile"]
        W6c["Bar Chart\nVolumen-Ranking"]
    end

    Q02 --> W1
    Q03 --> W2
    Q04 --> W3
    Q05 --> W4
    Q06 --> W5
    Q07 --> W6a
    Q07 --> W6b
    Q07 --> W6c

    style Queries fill:#1a1a2e,stroke:#e94560,color:#fff
    style Widgets fill:#533483,stroke:#e94560,color:#fff
```

## Datenfluss: Von Blockchain zu Dashboard

```mermaid
flowchart LR
    subgraph Blockchain["On-Chain Daten"]
        ETH["Ethereum"]
        BNB["BNB Chain"]
        POLY["Polygon"]
        ARB["Arbitrum"]
        OP["Optimism"]
        AVAX["Avalanche"]
        BASE["Base"]
    end

    subgraph Dune_Decode["Dune Decoding"]
        SPELL["Dune Spells\ntokens.transfers\nlabels.addresses"]
    end

    subgraph Pipeline["Stablecoin Pipeline"]
        REF["Reference\nTable"]
        TRANS["Transfer\nCollection"]
        AGG["Analyse &\nAggregation"]
    end

    subgraph Output["Live Dashboard"]
        DASH["Dune Dashboard\nCharts, Tables,\nCounters, Alerts"]
    end

    ETH --> SPELL
    BNB --> SPELL
    POLY --> SPELL
    ARB --> SPELL
    OP --> SPELL
    AVAX --> SPELL
    BASE --> SPELL
    SPELL --> REF
    REF --> TRANS
    TRANS --> AGG
    AGG --> DASH

    style Blockchain fill:#1a1a2e,stroke:#e94560,color:#fff
    style Dune_Decode fill:#16213e,stroke:#0f3460,color:#fff
    style Pipeline fill:#533483,stroke:#e94560,color:#fff
    style Output fill:#e94560,stroke:#fff,color:#fff
```

## Query-Beschreibungen

### 00 - Stablecoin Reference
Zentrale Konfigurationstabelle mit allen Contract-Adressen, Decimals und Kategorisierungen. Kann als eigenstaendige Query gespeichert und via `query_<id>` referenziert werden.

### 01 - Stablecoin Transfers
Basis-Query die alle ERC20-Transfers der getrackten Stablecoins sammelt. Nutzt `tokens.transfers` (Dune Spell). Klassifiziert Transfers nach Groesse (micro bis mega_whale) und Typ (mint/burn/transfer).

**Parameter:** `{{period}}`, `{{min_amount}}`

### 02 - Daily Volume
Taegliche Aggregation mit:
- Transfer-Volumen pro Chain/Stablecoin
- Transaktionszahlen und eindeutige Adressen
- 7-Tage und 30-Tage gleitende Durchschnitte
- Taegliche Veraenderungsrate

**Parameter:** `{{period}}`

### 03 - Net Flows
Analysiert Kapitalfluesse zu/von:
- **CEX** (Centralized Exchanges) - Sell-Pressure-Indikator
- **DEX** (Decentralized Exchanges) - DeFi-Aktivitaet
- **Bridges** - Cross-Chain Kapitalverschiebungen

Nutzt `labels.addresses` fuer die Adress-Kategorisierung. Kumulativer CEX Net Flow als Markt-Signal.

**Parameter:** `{{period}}`

### 04 - Supply Metrics
Trackt Mint- und Burn-Events:
- Taegliche Mints/Burns und Net Supply Change
- Kumulativer Supply Change
- 7-Tage Rolling Mint/Burn-Raten
- Mint/Burn Ratio (>1 = expansiv, <1 = kontraktiv)

**Parameter:** `{{period}}`

### 05 - Bridge Flows
Cross-Chain Bridge Analyse:
- Incoming/Outgoing Volumen pro Chain
- Net Bridge Flow (positiv = Kapitalzufluss)
- Kumulativer und 7-Tage Net Bridge Flow
- Bridge-spezifische Aufschluesselung

**Parameter:** `{{period}}`

### 06 - Whale Tracking
Grosse Transfers (>= konfigurierbarer Schwellenwert):
- Kategorisierung: CEX Deposit/Withdrawal, Bridge, DEX, Wallet-to-Wallet
- Sender/Empfaenger-Labels via `labels.addresses`
- Taegliches Ranking nach Groesse

**Parameter:** `{{period}}`, `{{whale_threshold}}`

### 07 - Dashboard Summary
Aggregierte Uebersicht:
- KPIs pro Stablecoin (Volumen, TXs, Unique Addresses, Active Chains)
- Marktanteile nach Volumen und Transaktionen
- Net Supply Change (Mints - Burns)
- Rankings

**Parameter:** `{{period}}`

## Anleitung: Auf Dune live schalten (Step-by-Step)

### Schritt 1: Dune Account erstellen

1. Gehe zu [dune.com](https://dune.com) und erstelle einen kostenlosen Account
2. Du brauchst mindestens den **Free Plan** - fuer mehr Query-Ausfuehrungen empfiehlt sich ein Plus/Premium Plan

### Schritt 2: Queries anlegen

Jede SQL-Datei wird als einzelne Query auf Dune angelegt. **Reihenfolge ist wichtig:**

```mermaid
flowchart TD
    S1["1. Neue Query erstellen\ndune.com → New Query"]
    S2["2. SQL Code einfuegen\nInhalt der .sql Datei kopieren"]
    S3["3. Query Engine: DuneSQL\nOben links sicherstellen"]
    S4["4. Run ausfuehren\nBlauer 'Run' Button"]
    S5["5. Ergebnisse pruefen\nTabelle unten kontrollieren"]
    S6["6. Query speichern\nNamen vergeben + Save"]
    S7["7. Query-ID notieren\nURL: dune.com/queries/XXXXXX"]

    S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7

    style S1 fill:#1a1a2e,stroke:#e94560,color:#fff
    style S4 fill:#e94560,stroke:#fff,color:#fff
    style S7 fill:#533483,stroke:#e94560,color:#fff
```

**Reihenfolge der Queries:**

| # | Datei | Dune Query Name (Vorschlag) | Hinweis |
|---|-------|-----------------------------|---------|
| 1 | `00_stablecoin_reference.sql` | Stablecoin Reference Table | Zuerst anlegen, Query-ID notieren |
| 2 | `01_stablecoin_transfers.sql` | Stablecoin Transfers (Multi-Chain) | Basis fuer alle anderen |
| 3 | `02_daily_volume.sql` | Stablecoin Daily Volume | Volumen-Analyse |
| 4 | `03_net_flows.sql` | Stablecoin CEX/DEX/Bridge Net Flows | Flow-Analyse |
| 5 | `04_supply_metrics.sql` | Stablecoin Supply (Mint/Burn) | Supply-Tracking |
| 6 | `05_bridge_flows.sql` | Stablecoin Bridge Flows | Cross-Chain |
| 7 | `06_whale_tracking.sql` | Stablecoin Whale Alerts | Whale-Monitor |
| 8 | `07_dashboard_summary.sql` | Stablecoin Dashboard KPIs | Dashboard-Metriken |

### Schritt 3: Parameter konfigurieren

Nach dem Einfuegen des SQL-Codes erkennt Dune automatisch die `{{parameter}}` Platzhalter und zeigt sie als Eingabefelder an:

| Parameter | Typ | Empfohlener Wert | Beschreibung |
|-----------|-----|-------------------|-------------|
| `{{period}}` | Text/Dropdown | `7 days` | Zeitraum: `1 day`, `7 days`, `30 days`, `90 days` |
| `{{min_amount}}` | Number | `100` | Minimaler Transfer-Betrag in USD |
| `{{whale_threshold}}` | Number | `1000000` | Schwellenwert fuer Whale-Transfers |

### Schritt 4: Dashboard erstellen

```mermaid
flowchart TD
    D1["1. Neues Dashboard\ndune.com → New Dashboard"]
    D2["2. Titel setzen\n'Stablecoin Flow Monitor'"]
    D3["3. Widget hinzufuegen\n'Add visualization'"]
    D4["4. Query auswaehlen\nGespeicherte Query suchen"]
    D5["5. Visualisierungs-Typ\nChart/Table/Counter waehlen"]
    D6["6. Widget konfigurieren\nAchsen, Farben, Filter"]
    D7["7. Layout anpassen\nWidgets per Drag & Drop"]
    D8["8. Dashboard speichern\nSave → Publish"]

    D1 --> D2 --> D3 --> D4 --> D5 --> D6 --> D7 --> D8
    D7 -->|Weitere Widgets| D3

    style D1 fill:#1a1a2e,stroke:#e94560,color:#fff
    style D5 fill:#533483,stroke:#e94560,color:#fff
    style D8 fill:#e94560,stroke:#fff,color:#fff
```

### Schritt 5: Visualisierungen konfigurieren

Fuer jede Query die passende Visualisierung einrichten:

**Query 07 → Counter Widgets (KPIs oben im Dashboard)**
- Widget-Typ: **Counter**
- 4 separate Counter erstellen: Total Volume, Transactions, Unique Addresses, Net Supply Change
- Ergebnis filtern auf `metric_type = 'global'`

**Query 02 → Line Chart (Volumen-Trend)**
- Widget-Typ: **Line Chart**
- X-Achse: `day`
- Y-Achse: `daily_volume`
- Group by: `symbol` oder `blockchain`
- Zusaetzlich: `ma_7d` und `ma_30d` als gestrichelte Linien

**Query 03 → Bar Chart (CEX Net Flows)**
- Widget-Typ: **Bar Chart**
- X-Achse: `day`
- Y-Achse: `net_cex_flow`
- Farbe: Gruen (positiv/Outflow) / Rot (negativ/Inflow)
- Interpretation: Negative Werte = Sell Pressure

**Query 04 → Area Chart (Supply)**
- Widget-Typ: **Area Chart**
- X-Achse: `day`
- Y-Achse: `cumulative_supply_change`
- Group by: `symbol`

**Query 05 → Stacked Bar Chart (Bridge Flows)**
- Widget-Typ: **Stacked Bar Chart**
- X-Achse: `blockchain`
- Y-Achse: `net_bridge_flow`
- Zeigt Kapitalfluss zwischen Chains

**Query 06 → Table (Whale Alerts)**
- Widget-Typ: **Table**
- Spalten: block_time, symbol, amount_usd, sender_label, receiver_label, transfer_category
- Sortierung: amount_usd DESC

**Query 07 → Pie Chart (Marktanteile)**
- Widget-Typ: **Pie Chart**
- Werte: `volume_market_share_pct`
- Labels: `symbol`
- Ergebnis filtern auf `metric_type = 'per_stablecoin'`

### Schritt 6: Dashboard veroeffentlichen

1. **Save** - Dashboard speichern
2. **Publish** - Oeffentlich zugaenglich machen (optional)
3. **Share** - Link teilen oder in Webseiten einbetten
4. **Schedule** (Premium) - Automatische Refresh-Intervalle festlegen

```mermaid
flowchart LR
    SAVE["Save\nEntwurf speichern"]
    PUB["Publish\nOeffentlich machen"]
    SHARE["Share\nLink / Embed"]
    SCHED["Schedule\nAuto-Refresh"]

    SAVE --> PUB --> SHARE
    PUB --> SCHED

    style SAVE fill:#16213e,stroke:#0f3460,color:#fff
    style PUB fill:#533483,stroke:#e94560,color:#fff
    style SHARE fill:#e94560,stroke:#fff,color:#fff
    style SCHED fill:#e94560,stroke:#fff,color:#fff
```

### Tipps fuer den Live-Betrieb

- **Query Refresh:** Dune cached Ergebnisse. Klicke auf "Run" um aktuelle Daten zu laden
- **Scheduled Refreshes:** Mit Premium-Plan koennen Queries automatisch alle X Stunden/Tage aktualisiert werden
- **Materialized Views:** Fuer Query 00 (Reference Table) kann man `Materialized View` aktivieren - spart Rechenzeit
- **Forking:** Andere Nutzer koennen dein Dashboard forken und anpassen
- **API Access:** Query-Ergebnisse koennen ueber die Dune API (v3) als JSON abgerufen werden fuer externe Dashboards

## Dune-spezifische Tabellen

Die Pipeline nutzt folgende Dune Spells/Tabellen:

| Tabelle | Beschreibung |
|---------|-------------|
| `tokens.transfers` | Vereinheitlichte ERC20-Transfers ueber alle Chains |
| `labels.addresses` | Community-gepflegte Adress-Labels (CEX, DEX, Bridge, etc.) |
| `prices.usd` | Token-Preise (optional, nicht direkt genutzt da Stablecoins ~$1) |

## Chains

- Ethereum
- BNB Chain (bnb)
- Polygon
- Arbitrum
- Optimism
- Avalanche C-Chain (avalanche_c)
- Base
