# Dune Analytics: Stablecoin Flow Pipeline

Multi-Chain Stablecoin-Tracking-Pipeline fuer [Dune Analytics](https://dune.com). Trackt Transfers, Volumen, Supply, Bridge-Flows und Whale-Aktivitaet der wichtigsten Stablecoins ueber **25+ Chains** (EVM + Solana + Tron + Cosmos).

---

## Dashboard Preview - So sieht es live auf Dune aus

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STABLECOIN FLOW TRACKER - LIVE DASHBOARD                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  $142.3B │  │  4.2M    │  │  892K    │  │   21     │  │  +$2.1B  │    │
│  │  Volume  │  │  TXs     │  │  Users   │  │  Chains  │  │  Supply  │    │
│  │  (30d)   │  │  (30d)   │  │  (30d)   │  │  Active  │  │  Change  │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
│                                                                             │
├─────────────────────────────────────┬───────────────────────────────────────┤
│  Volume ueber Zeit (Stacked Area)   │  Marktanteile (Pie Chart)            │
│                                     │                                       │
│  $B                                 │         ┌─────┐                       │
│  12│    ╭──╮                        │        /  USDT \                      │
│  10│   ╭╯  ╰─╮  ╭──╮              │       /   47%   \                     │
│   8│──╯      ╰──╯  ╰─╮            │      │           │                    │
│   6│ ░░░░░░░░░░░░░░░░░╰──          │  USDC│   USDC    │DAI                 │
│   4│ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒          │  31% │           │ 8%                 │
│   2│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓          │       \  Other  /                    │
│   0└─────────────────────           │        \ 14%  /                      │
│    Jan  Feb  Mar  Apr  May          │         └─────┘                       │
│                                     │                                       │
│  ░ USDT  ▒ USDC  ▓ DAI/Other       │  USDT: 47% | USDC: 31% | DAI: 8%    │
├─────────────────────────────────────┼───────────────────────────────────────┤
│  Bridge Protocol Ranking (Bar)      │  Chain x Stablecoin Heatmap          │
│                                     │                                       │
│  Stargate    ████████████░ $8.2B    │  Chain     │ USDT  │ USDC  │ DAI    │
│  Across      █████████░░░░ $6.1B    │  ──────────┼───────┼───────┼──────  │
│  Arb Bridge  ████████░░░░░ $5.4B    │  ethereum  │ ██████│ █████ │ ████   │
│  OP Bridge   ██████░░░░░░░ $4.2B    │  bnb       │ █████ │ ███   │        │
│  Hop         █████░░░░░░░░ $3.8B    │  arbitrum  │ ████  │ ████  │ ██     │
│  Base Bridge ████░░░░░░░░░ $3.1B    │  polygon   │ ███   │ ████  │ ██     │
│  Wormhole    ███░░░░░░░░░░ $2.4B    │  base      │ ██    │ █████ │        │
│  Synapse     ██░░░░░░░░░░░ $1.9B    │  optimism  │ ██    │ ███   │ █      │
│  Scroll Br.  █░░░░░░░░░░░░ $0.8B    │  scroll    │ █     │ ██    │        │
│  Celer       █░░░░░░░░░░░░ $0.6B    │  blast     │       │ ██    │        │
│                                     │  mantle    │ █     │ █     │        │
├─────────────────────────────────────┴───────────────────────────────────────┤
│  CEX Net Flow (Bar Chart - positiv/negativ)                                 │
│                                                                             │
│  +$2B │              ██                                                     │
│  +$1B │    ██   ██   ██        ██                                          │
│     0 ├────────────────────────────────────────────────────────             │
│  -$1B │         ██        ██   ██   ██                                     │
│  -$2B │                             ██                                     │
│       └─────────────────────────────────                                    │
│        Mon  Tue  Wed  Thu  Fri  Sat  Sun                                   │
│                                                                             │
│  ██ = Net CEX Flow | Positiv = Sell Pressure | Negativ = Accumulation      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Supply Tracker (Area Chart)                                                │
│                                                                             │
│  $B │                              ╭────────────────                        │
│  160│         ╭───────────────────╯                                        │
│  140│────────╯                                                             │
│  120│                                     USDT: Expansiv (+2.1B)           │
│     └──────────────────────────────────   USDC: Stabil (+0.3B)            │
│      Jan    Feb    Mar    Apr    May      DAI:  Kontraktiv (-0.1B)         │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Cross-Chain Bridge Flows (Sankey-Style)                                    │
│                                                                             │
│  Ethereum ═══════╤══════════════> Arbitrum    ($4.2B via Arb Bridge)       │
│           ═══════╪══════════> Optimism       ($3.1B via OP Bridge)         │
│           ═══════╪═══════> Base              ($2.8B via Base Bridge)       │
│           ═══════╪═════> Polygon             ($2.1B via Polygon Bridge)   │
│           ═══════╪═══> Scroll                ($0.9B via Scroll Bridge)    │
│           ═══════╪══> Blast                  ($0.7B via Blast Bridge)     │
│           ═══════╧═> Mantle                  ($0.5B via Mantle Bridge)    │
│                                                                             │
│  Arbitrum ───────────> Optimism              ($1.2B via Stargate)          │
│  Polygon  ───────────> BNB                   ($0.8B via Stargate)          │
│  Base     ───────────> Arbitrum              ($0.6B via Across)            │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Whale Alert Table (Top Transfers)                                          │
│                                                                             │
│  Time       │ Chain    │ Token │ Amount      │ Category       │ From → To  │
│  ───────────┼──────────┼───────┼─────────────┼────────────────┼────────────│
│  2h ago     │ ethereum │ USDT  │ $250,000,000│ CEX Withdrawal │ Binance→?  │
│  4h ago     │ ethereum │ USDC  │ $180,000,000│ Mint           │ Circle     │
│  5h ago     │ tron     │ USDT  │ $150,000,000│ Transfer       │ Whale→Whale│
│  6h ago     │ arbitrum │ USDC  │ $89,000,000 │ Bridge         │ →Stargate  │
│  8h ago     │ base     │ USDC  │ $72,000,000 │ CEX Deposit    │ ?→Coinbase │
│  9h ago     │ bnb      │ USDT  │ $65,000,000 │ CEX Deposit    │ ?→Binance  │
│  11h ago    │ ethereum │ DAI   │ $45,000,000 │ DeFi           │ ?→MakerDAO │
│  12h ago    │ blast    │ USDB  │ $38,000,000 │ Mint           │ Blast      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Solana & Tron Volume (Non-EVM)                                             │
│                                                                             │
│  Tron USDT │████████████████████████████████████████│ $52.1B (30d)         │
│  Sol USDC  │████████████████████░░░░░░░░░░░░░░░░░░░│ $28.4B (30d)         │
│  Sol USDT  │██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ $12.1B (30d)         │
│  Tron USDC │█████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  $5.8B (30d)         │
│  Tron USDD │██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  $2.1B (30d)         │
│  Sol PYUSD │█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│  $0.9B (30d)         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Daten-Pipeline Flow (Wie die Queries zusammenhaengen)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATENQUELLEN (Dune Tabellen)                     │
├────────────────────┬────────────────────┬───────────────────────────────┤
│ tokens.transfers   │ tokens_solana.     │ tron.logs                     │
│ (alle EVM Chains)  │ transfers (Solana) │ (Tron TRC20)                  │
└────────┬───────────┴─────────┬──────────┴──────────────┬────────────────┘
         │                     │                          │
         ▼                     ▼                          ▼
┌────────────────┐  ┌─────────────────┐  ┌───────────────────────┐
│ 00_reference   │  │ 08_solana       │  │ 09_tron               │
│ (Adressen &    │  │ (SPL Transfers) │  │ (TRC20 Events)        │
│  Konfiguration)│  └────────┬────────┘  └───────────┬───────────┘
└───────┬────────┘           │                        │
        │                    │                        │
        ▼                    ▼                        ▼
┌───────────────────────────────────────────────────────────────┐
│                    01_stablecoin_transfers                      │
│              (Alle Transfers, klassifiziert)                    │
└──────┬──────────────┬──────────────┬──────────────┬───────────┘
       │              │              │              │
       ▼              ▼              ▼              ▼
┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐
│ 02_daily   │ │ 03_net     │ │ 04_supply  │ │ 05_bridge  │
│ _volume    │ │ _flows     │ │ _metrics   │ │ _flows     │
│            │ │ (CEX/DEX/  │ │ (Mint/Burn)│ │ (17        │
│ (7d/30d MA)│ │  Bridge)   │ │            │ │  Bridges)  │
└─────┬──────┘ └──────┬─────┘ └──────┬─────┘ └──────┬─────┘
      │               │              │               │
      │               ▼              │               │
      │        ┌────────────┐        │               │
      │        │ 06_whale   │        │               │
      │        │ _tracking  │        │               │
      │        │ (>=1M USD) │        │               │
      │        └──────┬─────┘        │               │
      │               │              │               │
      ▼               ▼              ▼               ▼
┌───────────────────────────────────────────────────────────────┐
│                    07_dashboard_summary                         │
│              (Aggregierte KPIs + Rankings)                      │
└──────────────────────────────┬────────────────────────────────┘
                               │
                               ▼
┌───────────────────────────────────────────────────────────────┐
│                 VISUALIZATIONS (Dashboard Widgets)              │
├────────────┬────────────┬────────────┬────────────┬───────────┤
│ v1_counter │ v2_pie     │ v3_area    │ v4_heatmap │ v5_table  │
│ _kpis      │ _chart     │ _chart     │            │ v6_bridge │
└────────────┴────────────┴────────────┴────────────┴───────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   DUNE DASHBOARD    │
                    │   (Public / Live)   │
                    └─────────────────────┘
```

---

## Live-Schaltung auf Dune: Schritt-fuer-Schritt

### Phase 1: Account & Queries erstellen (10 Min)

```
┌─────────────────────────────────────────────────────────────┐
│  1. Gehe zu https://dune.com und erstelle einen Account     │
│     (Free Tier reicht fuer alles!)                          │
│                                                             │
│  2. Klicke oben rechts: [+ New Query]                       │
│                                                             │
│  3. Fuer JEDE .sql Datei:                                   │
│     a) Oeffne die Datei aus diesem Repo                     │
│     b) Kopiere den gesamten SQL-Code                        │
│     c) Fuege ihn in den Dune Query Editor ein               │
│     d) Klicke [▶ Run] zum Testen                           │
│     e) Klicke [Save] → Name z.B. "Stablecoin: Volume"     │
│                                                             │
│  4. Die {{parameter}} werden automatisch als                │
│     Eingabefelder im UI angezeigt!                          │
└─────────────────────────────────────────────────────────────┘
```

**Empfohlene Reihenfolge:**

| # | Query-Datei | Dune-Name (Vorschlag) | Wichtigkeit |
|---|-------------|----------------------|-------------|
| 1 | `v1_counter_kpis.sql` | "Stablecoin KPIs" | Muss |
| 2 | `v3_volume_over_time.sql` | "Stablecoin Volume Timeline" | Muss |
| 3 | `v2_market_share_pie.sql` | "Stablecoin Market Share" | Muss |
| 4 | `v6_bridge_sankey.sql` | "Bridge Protocol Ranking" | Muss |
| 5 | `v4_chain_heatmap.sql` | "Chain Heatmap" | Muss |
| 6 | `03_net_flows.sql` | "CEX Net Flows" | Muss |
| 7 | `04_supply_metrics.sql` | "Supply Tracker" | Muss |
| 8 | `v5_top_flows_table.sql` | "Top Flows Table" | Muss |
| 9 | `06_whale_tracking.sql` | "Whale Alerts" | Empfohlen |
| 10 | `05_bridge_flows.sql` | "Bridge Flow Detail" | Empfohlen |
| 11 | `08_solana_stablecoins.sql` | "Solana Stablecoins" | Empfohlen |
| 12 | `09_tron_stablecoins.sql` | "Tron Stablecoins" | Empfohlen |

### Phase 2: Dashboard zusammenbauen (15 Min)

```
┌─────────────────────────────────────────────────────────────┐
│  1. Klicke im Menue: [+ New Dashboard]                      │
│                                                             │
│  2. Gib einen Titel: "Stablecoin Flow Tracker"              │
│                                                             │
│  3. Du bist jetzt im EDIT MODE (blauer Rahmen)              │
│                                                             │
│  4. Klicke [Add Widget] → waehle "Visualization"            │
│                                                             │
│  5. Suche deine gespeicherte Query (z.B. "Stablecoin KPIs") │
│                                                             │
│  6. Waehle den Widget-Typ:                                  │
│     ┌─────────────────────────────────────────────┐         │
│     │  Query: "Stablecoin KPIs"                   │         │
│     │                                             │         │
│     │  Widget Type:  ○ Table                      │         │
│     │                ● Counter  ← waehlen!        │         │
│     │                ○ Bar Chart                   │         │
│     │                ○ Area Chart                  │         │
│     │                ○ Pie Chart                   │         │
│     │                ○ Line Chart                  │         │
│     │                                             │         │
│     │  Counter Column: [Total Volume ($)]         │         │
│     │  Title: "Total Volume"                      │         │
│     │  Prefix: "$"                                │         │
│     │                                             │         │
│     │  [Add to Dashboard]                         │         │
│     └─────────────────────────────────────────────┘         │
│                                                             │
│  7. Wiederhole fuer jedes Widget (siehe Tabelle unten)       │
│                                                             │
│  8. Ziehe Widgets per Drag & Drop in Position               │
│                                                             │
│  9. Klicke [Done Editing] wenn fertig                       │
└─────────────────────────────────────────────────────────────┘
```

**Widget-Konfiguration im Detail:**

| Widget | Query | Typ | Konfiguration |
|--------|-------|-----|---------------|
| Total Volume | v1_counter_kpis | **Counter** | Column: "Total Volume ($)", Prefix: "$" |
| Total TXs | v1_counter_kpis | **Counter** | Column: "Total Transactions" |
| Net Supply | v1_counter_kpis | **Counter** | Column: "Net Supply Change ($)", Prefix: "$" |
| Whale Count | v1_counter_kpis | **Counter** | Column: "Whale Transactions" |
| Volume Chart | v3_volume_over_time | **Stacked Area** | X: day, Y: daily_volume, Group: group_label, Filter: chart_type = "by_stablecoin" |
| Chain Volume | v3_volume_over_time | **Stacked Area** | X: day, Y: daily_volume, Group: group_label, Filter: chart_type = "by_chain" |
| Market Share | v2_market_share_pie | **Pie** | X: symbol, Y: volume_share_pct |
| Bridge Ranking | v6_bridge_sankey | **Bar (horizontal)** | X: label, Y: total_volume, Sort: DESC |
| Chain Heatmap | v4_chain_heatmap | **Table** | Conditional formatting on "volume" column |
| CEX Flows | 03_net_flows | **Bar** | X: day, Y: cex_net_flow, Group: symbol |
| Supply | 04_supply_metrics | **Area** | X: day, Y: cumulative_net_supply_change, Group: symbol |
| Top Flows | v5_top_flows_table | **Table** | Sort by "Amount ($)" DESC |
| Whale Alerts | 06_whale_tracking | **Table** | Sort by "amount" DESC |

### Phase 3: Parameter & Filter konfigurieren (5 Min)

```
┌─────────────────────────────────────────────────────────────┐
│  Im Edit-Mode des Dashboards:                               │
│                                                             │
│  1. Klicke [Add Parameter] oben                             │
│                                                             │
│  2. Erstelle einen Dashboard-Parameter:                     │
│     ┌─────────────────────────────────────┐                 │
│     │  Name: period                       │                 │
│     │  Type: Text                         │                 │
│     │  Default: 30 days                   │                 │
│     │                                     │                 │
│     │  [Create]                           │                 │
│     └─────────────────────────────────────┘                 │
│                                                             │
│  3. Verbinde den Parameter mit allen Queries:               │
│     Klicke auf jedes Widget → Settings → Parameter          │
│     → Mappe "period" auf {{period}} der Query               │
│                                                             │
│  4. Jetzt erscheint ein Dropdown oben im Dashboard:         │
│     ┌────────────────────────────────────────────┐          │
│     │  Period: [7 days ▼] [30 days] [90 days]   │          │
│     │                                            │          │
│     │  Alle Widgets aktualisieren sich sofort!   │          │
│     └────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Phase 4: LIVE SCHALTEN (2 Min)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ╔═══════════════════════════════════════════════════════╗   │
│  ║          DASHBOARD LIVE SCHALTEN                      ║   │
│  ╚═══════════════════════════════════════════════════════╝   │
│                                                             │
│  1. Oeffne dein fertiges Dashboard                          │
│                                                             │
│  2. Klicke rechts oben:  [Share]                            │
│     ┌─────────────────────────────────────┐                 │
│     │  Visibility:                        │                 │
│     │                                     │                 │
│     │  ○ Private (nur du)                 │                 │
│     │  ● Public  (jeder mit Link) ← DAS! │                 │
│     │                                     │                 │
│     │  Link: dune.com/username/stablecoin │                 │
│     │        -flow-tracker                │                 │
│     │                                     │                 │
│     │  [Copy Link]  [Save]               │                 │
│     └─────────────────────────────────────┘                 │
│                                                             │
│  3. Auto-Refresh einrichten:                                │
│     Dashboard Settings → Refresh Schedule                   │
│     ┌─────────────────────────────────────┐                 │
│     │  Auto-refresh: [Every 6 hours ▼]    │                 │
│     │                                     │                 │
│     │  Optionen:                          │                 │
│     │  • Every 1 hour  (Pro Plan)         │                 │
│     │  • Every 6 hours (Free!)            │                 │
│     │  • Every 12 hours                   │                 │
│     │  • Every 24 hours                   │                 │
│     │                                     │                 │
│     │  [Save Schedule]                    │                 │
│     └─────────────────────────────────────┘                 │
│                                                             │
│  4. FERTIG! Dein Dashboard ist jetzt:                       │
│     ✓ Oeffentlich sichtbar                                 │
│     ✓ Per Link teilbar                                     │
│     ✓ Aktualisiert sich automatisch                        │
│     ✓ Einbettbar (Embed-Code verfuegbar)                   │
│     ✓ Forkbar (andere koennen es kopieren)                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase 5: Teilen & Einbetten (Optional)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  EINBETTEN in eigene Website:                               │
│  ─────────────────────────────                              │
│  Dashboard → Share → Embed                                  │
│                                                             │
│  <iframe                                                    │
│    src="https://dune.com/embeds/12345/dashboard"            │
│    width="100%" height="800"                                │
│    frameborder="0">                                         │
│  </iframe>                                                  │
│                                                             │
│                                                             │
│  TWITTER/X SHARING:                                         │
│  ─────────────────                                          │
│  Dune generiert automatisch Preview-Bilder (OG Images)      │
│  Einfach den Dashboard-Link posten → Preview erscheint     │
│                                                             │
│                                                             │
│  API ACCESS (Pro Plan):                                     │
│  ─────────────────────                                      │
│  curl -H "X-Dune-API-Key: YOUR_KEY" \                      │
│    "https://api.dune.com/api/v1/query/QUERY_ID/results"    │
│                                                             │
│  → JSON-Daten direkt in eigene Apps integrieren             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Architektur-Diagramm: Datenfluss End-to-End

```
    ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
    │Ethereum │     │ Solana  │     │  Tron   │     │ Cosmos  │
    │Arbitrum │     │  (SVM)  │     │  (TVM)  │     │  (IBC)  │
    │Optimism │     │         │     │         │     │Injective│
    │  Base   │     │         │     │         │     │Celestia │
    │ Scroll  │     │         │     │         │     │   Sei   │
    │ Mantle  │     │         │     │         │     │  Kava   │
    │  Blast  │     │         │     │         │     │         │
    │  +12    │     │         │     │         │     │         │
    └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
         │               │               │               │
         ▼               ▼               ▼               ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    DUNE DATA LAKE                         │
    │  tokens.transfers │ tokens_solana │ tron.logs │ labels  │
    └───────────────────────────┬─────────────────────────────┘
                                │
                                ▼
    ┌─────────────────────────────────────────────────────────┐
    │              SQL PIPELINE (dieses Repo)                   │
    │                                                          │
    │  ┌────────────────────────────────────────────────────┐  │
    │  │ Layer 1: Raw Transfers (01, 08, 09, 10)            │  │
    │  └────────────────────────┬───────────────────────────┘  │
    │                           │                              │
    │  ┌────────────────────────▼───────────────────────────┐  │
    │  │ Layer 2: Analytics (02, 03, 04, 05, 06)            │  │
    │  └────────────────────────┬───────────────────────────┘  │
    │                           │                              │
    │  ┌────────────────────────▼───────────────────────────┐  │
    │  │ Layer 3: Dashboard (07, v1-v6)                     │  │
    │  └────────────────────────────────────────────────────┘  │
    └───────────────────────────┬──────────────────────────────┘
                                │
                                ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    DUNE DASHBOARD                         │
    │                                                          │
    │   [Counter] [Counter] [Counter] [Counter] [Counter]      │
    │   [════════ Area Chart ════════] [═══ Pie Chart ═══]     │
    │   [════ Bar Chart ════] [══════ Heatmap Table ═════]     │
    │   [══════════════ CEX Flow Bar Chart ══════════════]      │
    │   [══════════════ Supply Area Chart ═══════════════]      │
    │   [══════════════ Whale Alert Table ═══════════════]      │
    │                                                          │
    └───────────────────────────┬──────────────────────────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
              ┌──────────┐ ┌────────┐ ┌─────────┐
              │  Public  │ │ Embed  │ │   API   │
              │   Link   │ │ iframe │ │  (JSON) │
              └──────────┘ └────────┘ └─────────┘
```

---

## Query-Abhaengigkeiten (welche zuerst laufen muessen)

```
                          UNABHAENGIG
                    (alle parallel ausfuehrbar)
                              │
        ┌─────────┬───────────┼───────────┬──────────┐
        ▼         ▼           ▼           ▼          ▼
    ┌───────┐ ┌───────┐ ┌─────────┐ ┌────────┐ ┌────────┐
    │ 01    │ │ 08    │ │ 09      │ │ 10     │ │ 11     │
    │ EVM   │ │Solana │ │ Tron    │ │Cosmos  │ │IBC Ref │
    │Transf.│ │       │ │         │ │EVM     │ │        │
    └───┬───┘ └───┬───┘ └────┬────┘ └────┬───┘ └────────┘
        │         │          │           │
        │    ┌────┴──────────┴───────────┘
        │    │
        ▼    ▼
    ┌──────────────────────────────────────────────────┐
    │  02, 03, 04, 05, 06  (alle nutzen 01 als Basis)  │
    │  Koennen parallel laufen                          │
    └──────────────────────┬───────────────────────────┘
                           │
                           ▼
    ┌──────────────────────────────────────────────────┐
    │  07_dashboard_summary (aggregiert alles)          │
    │  v1-v6 (Dashboard-Widgets, parallel)             │
    └──────────────────────────────────────────────────┘
```

> **Wichtig:** Auf Dune gibt es keine echten Abhaengigkeiten - jede Query laeuft eigenstaendig mit eigener CTE. Die Queries sind aber logisch so aufgebaut.

---

## Unterstuetzte Stablecoins (20+ Coins)

| Symbol | Issuer | Typ | Chains |
|--------|--------|-----|--------|
| USDT | Tether | Centralized | Ethereum, BNB, Polygon, Arbitrum, Optimism, Avalanche, Base, Gnosis, Fantom, Celo, Scroll, Mantle, Mode, zkEVM, **Solana**, **Tron** |
| USDC | Circle | Centralized | Ethereum, BNB, Polygon, Arbitrum, Optimism, Avalanche, Base, Gnosis, Celo, Fantom, zkSync, Linea, Scroll, Mantle, Mode, zkEVM, Blast, **Solana** |
| DAI | MakerDAO | Decentralized | Ethereum, Polygon, Arbitrum, Optimism, Base, Gnosis, **Solana** |
| USDS | Sky | Decentralized | Ethereum, **Solana** |
| FRAX | Frax Finance | Hybrid | Ethereum, Arbitrum, Optimism, Polygon |
| GHO | Aave | Decentralized | Ethereum |
| crvUSD | Curve | Decentralized | Ethereum |
| PYUSD | PayPal | Centralized | Ethereum, **Solana** |
| USDe | Ethena | Hybrid | Ethereum, Blast |
| FDUSD | First Digital | Centralized | Ethereum, BNB |
| LUSD | Liquity | Decentralized | Ethereum |
| TUSD | TrueUSD | Centralized | Ethereum, BNB |
| BUSD | Paxos | Centralized | Ethereum, BNB |
| USDP | Paxos | Centralized | Ethereum |
| sUSD | Synthetix | Decentralized | Optimism |
| DOLA | Inverse Finance | Decentralized | Ethereum |
| USDB | Blast | Decentralized | Blast (native) |
| USDY | Ondo Finance | Centralized | Ethereum, Mantle |
| USDD | Tron DAO | Decentralized | **Tron** |
| EURS / EURT / EURA | Stasis / Tether / Angle | Various | Ethereum |
| USDC.e / USDbC | Circle (bridged) | Centralized | Arbitrum, Optimism, Polygon, Avalanche, Base |

## Unterstuetzte Chains (25+)

### EVM Chains (17)
| Chain | Dune-ID | Typ | Status |
|-------|---------|-----|--------|
| Ethereum | `ethereum` | L1 | Live |
| BNB Chain | `bnb` | L1 | Live |
| Polygon | `polygon` | Sidechain | Live |
| Arbitrum | `arbitrum` | L2 Optimistic | Live |
| Optimism | `optimism` | L2 Optimistic | Live |
| Avalanche | `avalanche_c` | L1 | Live |
| Base | `base` | L2 Optimistic | Live |
| Gnosis | `gnosis` | Sidechain | Live |
| Fantom | `fantom` | L1 | Live |
| Celo | `celo` | L1 | Live |
| zkSync Era | `zksync` | L2 ZK-Rollup | Live |
| Linea | `linea` | L2 ZK-Rollup | Live |
| Scroll | `scroll` | L2 ZK-Rollup | Live |
| Mantle | `mantle` | L2 Optimistic | Live |
| Blast | `blast` | L2 Optimistic | Live |
| Mode | `mode` | L2 Optimistic | Live |
| Polygon zkEVM | `zkevm` | L2 ZK-Rollup | Live |

### Non-EVM Chains (2)
| Chain | Dune-Tabelle | Typ | Status |
|-------|-------------|-----|--------|
| **Solana** | `tokens_solana.transfers` | L1 (SVM) | Live |
| **Tron** | `tron.logs` | L1 (TVM) | Live |

### Cosmos Ecosystem (4)
| Chain | Typ | Status |
|-------|-----|--------|
| Sei | Cosmos+EVM | Live (EVM-Seite) |
| Kava | Cosmos+EVM | Live (EVM-Seite) |
| Injective / Celestia / ATOM | Pure Cosmos | Referenz (nicht auf Dune) |

## Bridge-Protokolle (17)

| Bridge | Chains | Typ |
|--------|--------|-----|
| Stargate (LayerZero) | 9 Chains | Liquidity Pool |
| Across Protocol | 9 Chains | Intent-based |
| Synapse Protocol | 10 Chains | AMM Bridge |
| Celer cBridge | 8 Chains | Liquidity Pool |
| Hop Protocol | 4 Chains | AMM Bridge |
| Wormhole | Multi-chain | Lock & Mint |
| Orbiter Finance | Ethereum + L2s | Maker System |
| Optimism Bridge | Eth <-> OP | Canonical |
| Arbitrum Bridge | Eth <-> Arb | Canonical |
| Polygon Bridge | Eth <-> Poly | Canonical |
| Base Bridge | Eth <-> Base | Canonical |
| zkSync Bridge | Eth <-> zkSync | Canonical |
| Linea Bridge | Eth <-> Linea | Canonical |
| Scroll Bridge | Eth <-> Scroll | Canonical |
| Mantle Bridge | Eth <-> Mantle | Canonical |
| Blast Bridge | Eth <-> Blast | Canonical |
| Mode Bridge | Eth <-> Mode | Canonical |

## Pipeline-Struktur

```
queries/
├── 00_stablecoin_reference.sql       # Referenztabelle: 70+ Adressen, 25+ Chains
├── 01_stablecoin_transfers.sql       # Basis-Transfers (EVM, multi-chain)
├── 02_daily_volume.sql               # Taegliches Volumen + gleitende Durchschnitte
├── 03_net_flows.sql                  # CEX/DEX/Bridge Net Flows
├── 04_supply_metrics.sql             # Mint/Burn-Tracking, Supply-Entwicklung
├── 05_bridge_flows.sql               # Cross-Chain Bridge Flows (17 Bridges)
├── 06_whale_tracking.sql             # Whale-Transfer Monitoring
├── 07_dashboard_summary.sql          # Dashboard KPIs und Marktanteile
├── 08_solana_stablecoins.sql         # Solana SPL Token Transfers (non-EVM)
├── 09_tron_stablecoins.sql           # Tron TRC20 Transfers (non-EVM, groesster USDT)
├── 10_cosmos_evm_stablecoins.sql     # Sei + Kava (Cosmos+EVM hybrid)
├── 11_cosmos_ibc_tracking.sql        # Cosmos IBC Referenz (Injective, ATOM, Celestia)
│
└── visualizations/                   # Dashboard-optimierte Queries
    ├── v1_counter_kpis.sql           # Counter-Widgets (Headline KPIs)
    ├── v2_market_share_pie.sql       # Pie Chart: Marktanteile
    ├── v3_volume_over_time.sql       # Stacked Area: Volumen ueber Zeit
    ├── v4_chain_heatmap.sql          # Heatmap: Chain x Stablecoin Matrix
    ├── v5_top_flows_table.sql        # Tabelle: Groesste Transfers
    └── v6_bridge_sankey.sql          # Bar Chart: Bridge-Protokoll Flows
```

## Parameter

| Parameter | Standard | Optionen | Beschreibung |
|-----------|----------|----------|-------------|
| `{{period}}` | `30 days` | 7 days, 30 days, 90 days, 365 days | Zeitfenster |
| `{{min_amount}}` | `0` | 0, 1000, 10000, 100000, 1000000 | Mindestbetrag |
| `{{whale_threshold}}` | `1000000` | 500000, 1000000, 5000000, 10000000 | Whale-Schwelle |

## FAQ

**Kostet das etwas?**
Nein! Der Dune Free Plan reicht fuer alles. Du bekommst unbegrenzte Public Dashboards und Queries.

**Wie oft aktualisieren sich die Daten?**
Dune indexiert Blockchain-Daten mit ~5 Min Verzoegerung. Dein Dashboard zeigt immer near-realtime Daten wenn du es manuell refreshst. Auto-Refresh laeuft alle 6h (Free) oder 1h (Pro).

**Kann ich das Dashboard forken?**
Ja! Jeder kann ein Public Dashboard forken und anpassen. Das ist ein Feature von Dune.

**Kann ich die Daten per API abrufen?**
Ja, mit dem Dune Pro Plan ($350/Monat) bekommst du API-Zugang. Damit kannst du die Daten in eigene Apps, Bots oder Dashboards integrieren.

**Welche Chain hat das meiste Stablecoin-Volumen?**
Tron (USDT) > Ethereum > BNB > Solana > Arbitrum > Base > Polygon (typische Reihenfolge)

## Technische Hinweise

- **DuneSQL (Trino)**: Alle Queries nutzen DuneSQL-Syntax
- **Adressen**: EVM = `0x...` Hex, Solana = Base58, Tron = `T...` Base58 (intern als Hex)
- **Decimals**: Pro Token/Chain korrekt (6/8/18)
- **Labels**: `labels.addresses` = Community-gepflegte Adress-Labels
- **Performance**: Zeitraeume >90 Tage dauern laenger, Free Plan hat Execution-Limits
