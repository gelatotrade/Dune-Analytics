# Dune Analytics: Stablecoin Flow Pipeline

Multi-chain stablecoin tracking pipeline for [Dune Analytics](https://dune.com). Tracks transfers, volume, supply, bridge flows, and whale activity for major stablecoins across 7+ EVM chains.

## Supported Stablecoins

| Symbol | Issuer | Type | Chains |
|--------|--------|------|--------|
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

## Pipeline Overview

```
queries/
├── 00_stablecoin_reference.sql   # Reference table: addresses, decimals, categories
├── 01_stablecoin_transfers.sql   # Base transfers for all stablecoins (multi-chain)
├── 02_daily_volume.sql           # Daily volume with moving averages
├── 03_net_flows.sql              # Net flows to/from CEX, DEX, bridges
├── 04_supply_metrics.sql         # Mint/burn tracking and supply evolution
├── 05_bridge_flows.sql           # Cross-chain bridge flow analysis
├── 06_whale_tracking.sql         # Whale transfer monitoring (>= 1M)
└── 07_dashboard_summary.sql      # Dashboard KPIs and market shares
```

## Architecture: Data Pipeline Flow

The following diagram shows how the queries build on each other and which Dune data sources are used:

```mermaid
flowchart TB
    subgraph Dune_Spells["Dune Data Sources"]
        TT["tokens.transfers\n(ERC20 Transfers)"]
        LA["labels.addresses\n(CEX/DEX/Bridge Labels)"]
    end

    subgraph Reference["Configuration"]
        Q00["00 - Stablecoin Reference\nAddresses, Decimals, Categories\n(12 Stablecoins x 7 Chains)"]
    end

    subgraph Basis["Base Layer"]
        Q01["01 - Stablecoin Transfers\nAll ERC20 Transfers\nClassification: micro → mega_whale\nType: mint / burn / transfer"]
    end

    subgraph Analyse["Analysis Layer"]
        Q02["02 - Daily Volume\nDaily Volume\n7d/30d Moving Averages\nUnique Addresses"]
        Q03["03 - Net Flows\nCEX / DEX / Bridge Flows\nCumulative CEX Net Flow\nMarket Signal"]
        Q04["04 - Supply Metrics\nMint/Burn Tracking\nNet Supply Change\nMint/Burn Ratio"]
        Q05["05 - Bridge Flows\nCross-Chain Analysis\nIncoming/Outgoing\nNet Bridge Flow"]
        Q06["06 - Whale Tracking\nTransfers >= 1M USD\nCategorization\nSender/Receiver Labels"]
    end

    subgraph Dashboard["Dashboard Layer"]
        Q07["07 - Dashboard Summary\nKPIs per Stablecoin/Chain\nMarket Shares\nGlobal Metrics"]
    end

    Q00 -->|Contract Addresses| Q01
    TT -->|Transfer Data| Q01
    Q01 -->|Base Transfers| Q02
    Q01 -->|Base Transfers| Q03
    Q01 -->|Mint/Burn Events| Q04
    Q01 -->|Bridge Transfers| Q05
    Q01 -->|Large Transfers| Q06
    LA -->|Address Labels| Q03
    LA -->|Address Labels| Q05
    LA -->|Address Labels| Q06
    Q02 -->|Volume KPIs| Q07
    Q04 -->|Supply KPIs| Q07

    style Dune_Spells fill:#1a1a2e,stroke:#e94560,color:#fff
    style Reference fill:#16213e,stroke:#0f3460,color:#fff
    style Basis fill:#0f3460,stroke:#533483,color:#fff
    style Analyse fill:#533483,stroke:#e94560,color:#fff
    style Dashboard fill:#e94560,stroke:#fff,color:#fff
```

## Dashboard Layout: How It Looks on Dune

When the queries are live on Dune, the dashboard is structured as follows:

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
        whale["Table: Whale Alerts (Query 06)\nDate | Stablecoin | Amount | From → To | Category"]
        whale:3
        share["Pie Chart\nMarket Shares\n(Query 07)"]
    end

    style header fill:#1a1a2e,stroke:#e94560,color:#fff
    style kpis fill:#16213e,stroke:#0f3460,color:#fff
    style charts1 fill:#0f3460,stroke:#533483,color:#fff
    style charts2 fill:#0f3460,stroke:#533483,color:#fff
    style tables fill:#533483,stroke:#e94560,color:#fff
```

## Visualization Mapping

Each query produces specific visualizations on the Dune dashboard:

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
        W1["Line Chart\nVolume Trend\nOver Time"]
        W2["Bar Chart\nCEX Net Flow\nPer Day"]
        W3["Area Chart\nCumulative\nSupply Change"]
        W4["Stacked Bar\nBridge In/Out\nPer Chain"]
        W5["Table\nWhale Alerts\nWith Labels"]
        W6a["Counter\nGlobal KPIs"]
        W6b["Pie Chart\nMarket Shares"]
        W6c["Bar Chart\nVolume Ranking"]
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

## Data Flow: From Blockchain to Dashboard

```mermaid
flowchart LR
    subgraph Blockchain["On-Chain Data"]
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
        AGG["Analysis &\nAggregation"]
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

## Query Descriptions

### 00 - Stablecoin Reference
Central configuration table with all contract addresses, decimals, and categorizations. Can be saved as a standalone query and referenced via `query_<id>`.

### 01 - Stablecoin Transfers
Base query that collects all ERC20 transfers of tracked stablecoins. Uses `tokens.transfers` (Dune Spell). Classifies transfers by size (micro to mega_whale) and type (mint/burn/transfer).

**Parameters:** `{{period}}`, `{{min_amount}}`

### 02 - Daily Volume
Daily aggregation with:
- Transfer volume per chain/stablecoin
- Transaction counts and unique addresses
- 7-day and 30-day moving averages
- Daily change rate

**Parameters:** `{{period}}`

### 03 - Net Flows
Analyzes capital flows to/from:
- **CEX** (Centralized Exchanges) - Sell pressure indicator
- **DEX** (Decentralized Exchanges) - DeFi activity
- **Bridges** - Cross-chain capital movements

Uses `labels.addresses` for address categorization. Cumulative CEX net flow as market signal.

**Parameters:** `{{period}}`

### 04 - Supply Metrics
Tracks mint and burn events:
- Daily mints/burns and net supply change
- Cumulative supply change
- 7-day rolling mint/burn rates
- Mint/burn ratio (>1 = expansionary, <1 = contractionary)

**Parameters:** `{{period}}`

### 05 - Bridge Flows
Cross-chain bridge analysis:
- Incoming/outgoing volume per chain
- Net bridge flow (positive = capital inflow)
- Cumulative and 7-day net bridge flow
- Bridge-specific breakdown

**Parameters:** `{{period}}`

### 06 - Whale Tracking
Large transfers (>= configurable threshold):
- Categorization: CEX deposit/withdrawal, bridge, DEX, wallet-to-wallet
- Sender/receiver labels via `labels.addresses`
- Daily ranking by size

**Parameters:** `{{period}}`, `{{whale_threshold}}`

### 07 - Dashboard Summary
Aggregated overview:
- KPIs per stablecoin (volume, TXs, unique addresses, active chains)
- Market shares by volume and transactions
- Net supply change (mints - burns)
- Rankings

**Parameters:** `{{period}}`

## Guide: Going Live on Dune (Step-by-Step)

### Step 1: Create a Dune Account

1. Go to [dune.com](https://dune.com) and create a free account
2. You need at least the **Free Plan** - for more query executions, a Plus/Premium plan is recommended

### Step 2: Create Queries

Each SQL file is created as an individual query on Dune. **Order matters:**

```mermaid
flowchart TD
    S1["1. Create New Query\ndune.com → New Query"]
    S2["2. Paste SQL Code\nCopy contents of .sql file"]
    S3["3. Query Engine: DuneSQL\nEnsure selected in top left"]
    S4["4. Execute Run\nBlue 'Run' Button"]
    S5["5. Verify Results\nCheck table below"]
    S6["6. Save Query\nAssign name + Save"]
    S7["7. Note Query ID\nURL: dune.com/queries/XXXXXX"]

    S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7

    style S1 fill:#1a1a2e,stroke:#e94560,color:#fff
    style S4 fill:#e94560,stroke:#fff,color:#fff
    style S7 fill:#533483,stroke:#e94560,color:#fff
```

**Query Order:**

| # | File | Suggested Dune Query Name | Notes |
|---|------|---------------------------|-------|
| 1 | `00_stablecoin_reference.sql` | Stablecoin Reference Table | Create first, note query ID |
| 2 | `01_stablecoin_transfers.sql` | Stablecoin Transfers (Multi-Chain) | Base for all others |
| 3 | `02_daily_volume.sql` | Stablecoin Daily Volume | Volume analysis |
| 4 | `03_net_flows.sql` | Stablecoin CEX/DEX/Bridge Net Flows | Flow analysis |
| 5 | `04_supply_metrics.sql` | Stablecoin Supply (Mint/Burn) | Supply tracking |
| 6 | `05_bridge_flows.sql` | Stablecoin Bridge Flows | Cross-chain |
| 7 | `06_whale_tracking.sql` | Stablecoin Whale Alerts | Whale monitor |
| 8 | `07_dashboard_summary.sql` | Stablecoin Dashboard KPIs | Dashboard metrics |

### Step 3: Configure Parameters

After pasting the SQL code, Dune automatically detects `{{parameter}}` placeholders and displays them as input fields:

| Parameter | Type | Recommended Value | Description |
|-----------|------|-------------------|-------------|
| `{{period}}` | Text/Dropdown | `7 days` | Time range: `1 day`, `7 days`, `30 days`, `90 days` |
| `{{min_amount}}` | Number | `100` | Minimum transfer amount in USD |
| `{{whale_threshold}}` | Number | `1000000` | Threshold for whale transfers |

### Step 4: Create Dashboard

```mermaid
flowchart TD
    D1["1. New Dashboard\ndune.com → New Dashboard"]
    D2["2. Set Title\n'Stablecoin Flow Monitor'"]
    D3["3. Add Widget\n'Add visualization'"]
    D4["4. Select Query\nSearch for saved query"]
    D5["5. Visualization Type\nChoose Chart/Table/Counter"]
    D6["6. Configure Widget\nAxes, colors, filters"]
    D7["7. Adjust Layout\nDrag & drop widgets"]
    D8["8. Save Dashboard\nSave → Publish"]

    D1 --> D2 --> D3 --> D4 --> D5 --> D6 --> D7 --> D8
    D7 -->|More widgets| D3

    style D1 fill:#1a1a2e,stroke:#e94560,color:#fff
    style D5 fill:#533483,stroke:#e94560,color:#fff
    style D8 fill:#e94560,stroke:#fff,color:#fff
```

### Step 5: Configure Visualizations

Set up the appropriate visualization for each query:

**Query 07 → Counter Widgets (KPIs at top of dashboard)**
- Widget type: **Counter**
- Create 4 separate counters: Total Volume, Transactions, Unique Addresses, Net Supply Change
- Filter results on `metric_type = 'global'`

**Query 02 → Line Chart (Volume Trend)**
- Widget type: **Line Chart**
- X-axis: `day`
- Y-axis: `daily_volume`
- Group by: `symbol` or `blockchain`
- Additionally: `ma_7d` and `ma_30d` as dashed lines

**Query 03 → Bar Chart (CEX Net Flows)**
- Widget type: **Bar Chart**
- X-axis: `day`
- Y-axis: `net_cex_flow`
- Color: Green (positive/outflow) / Red (negative/inflow)
- Interpretation: Negative values = sell pressure

**Query 04 → Area Chart (Supply)**
- Widget type: **Area Chart**
- X-axis: `day`
- Y-axis: `cumulative_supply_change`
- Group by: `symbol`

**Query 05 → Stacked Bar Chart (Bridge Flows)**
- Widget type: **Stacked Bar Chart**
- X-axis: `blockchain`
- Y-axis: `net_bridge_flow`
- Shows capital flow between chains

**Query 06 → Table (Whale Alerts)**
- Widget type: **Table**
- Columns: block_time, symbol, amount_usd, sender_label, receiver_label, transfer_category
- Sort: amount_usd DESC

**Query 07 → Pie Chart (Market Shares)**
- Widget type: **Pie Chart**
- Values: `volume_market_share_pct`
- Labels: `symbol`
- Filter results on `metric_type = 'per_stablecoin'`

### Step 6: Publish Dashboard

1. **Save** - Save draft
2. **Publish** - Make publicly accessible (optional)
3. **Share** - Share link or embed in websites
4. **Schedule** (Premium) - Set automatic refresh intervals

```mermaid
flowchart LR
    SAVE["Save\nSave Draft"]
    PUB["Publish\nMake Public"]
    SHARE["Share\nLink / Embed"]
    SCHED["Schedule\nAuto-Refresh"]

    SAVE --> PUB --> SHARE
    PUB --> SCHED

    style SAVE fill:#16213e,stroke:#0f3460,color:#fff
    style PUB fill:#533483,stroke:#e94560,color:#fff
    style SHARE fill:#e94560,stroke:#fff,color:#fff
    style SCHED fill:#e94560,stroke:#fff,color:#fff
```

### Tips for Live Operation

- **Query Refresh:** Dune caches results. Click "Run" to load current data
- **Scheduled Refreshes:** With a Premium plan, queries can be automatically refreshed every X hours/days
- **Materialized Views:** For Query 00 (Reference Table), you can enable `Materialized View` - saves compute time
- **Forking:** Other users can fork your dashboard and customize it
- **API Access:** Query results can be retrieved via the Dune API (v3) as JSON for external dashboards

## Code Quality & Bug Fixes

The pipeline went through multiple debugging rounds to ensure data accuracy. Below is a summary of all bugs that were identified and fixed.

### Round 1: Data Consistency & Structural Bugs

| # | Issue | Affected Queries | Fix |
|---|-------|------------------|-----|
| 1 | **Row duplication via `labels.addresses` JOINs** | Q03, Q05, Q06 | Dune labels can have multiple rows per address (different categories/names). LEFT JOINs duplicated transfers and inflated volumes. Fixed with `ROW_NUMBER() OVER (PARTITION BY blockchain, address)` deduplication. |
| 2 | **Inconsistent stablecoin coverage** | Q01-Q07 | Queries had different subsets of the reference table. Missing: TUSD entirely, DAI on Base, FRAX on Arbitrum/Optimism. Q03 had only 12 of 32 entries. Aligned all queries to match Q00 reference. |
| 3 | **Unused `per_chain` CTE in dashboard summary** | Q07 | Chain-level KPIs were computed but never output. Added via `UNION ALL` with `metric_type='per_chain'`. |
| 4 | **`unique_addresses` double-counting** | Q07 | `COUNT(DISTINCT from) + COUNT(DISTINCT to)` counted users who both send and receive twice. Split into separate `unique_senders` and `unique_receivers` columns. |
| 5 | **Missing global KPIs in output** | Q07 | `global_kpis` CTE was only used for market share calculations. Added dedicated `metric_type='global'` row so dashboard counters can filter on them. |
| 6 | **Dead code `address_labels` CTE** | Q01 | CTE was defined but never used. Removed. |

### Round 2: Logic & Calculation Bugs

| # | Issue | Affected Queries | Fix |
|---|-------|------------------|-----|
| 7 | **`daily_change_pct` returned fraction instead of percentage** | Q02 | Formula returned 0.05 but column name suggested 5.0. Multiplied by 100 to match the name. |
| 8 | **DEX/Bridge flows included internal transfers** | Q03 | Unlike CEX flows (which correctly excluded `cex_to_cex`), DEX and Bridge flows counted `dex-to-dex` and `bridge-to-bridge` transfers, inflating volumes. Added matching exclusion logic. |
| 9 | **Bridge-to-bridge transfers only counted as `to_bridge`** | Q05 | `CASE` expression with LEFT JOINs only captured the receiving bridge, missing the sending bridge leg. Refactored to `UNION ALL` with two `INNER JOIN` queries to capture both legs correctly. |
| 10 | **Dead code `whale_summary` CTE + incorrect rank partition** | Q06 | CTE was computed but never selected. Additionally, `daily_rank` partitioned only by `(day, blockchain)`, mixing whales from all stablecoins. Removed dead code and added `symbol` to the partition. |

### Round 3: Final Verification

All queries were re-reviewed end-to-end. No additional bugs found. Verified:

- All 8 queries have **consistent 32-entry stablecoin lists** matching `00_stablecoin_reference.sql`
- **Label deduplication** via `ROW_NUMBER()` in Q03, Q05, Q06
- **UNION ALL bridge logic** correctly captures both legs of bridge-to-bridge transfers
- **Window functions** (moving averages, cumulative sums, rankings) are all correctly partitioned
- **DuneSQL compatibility** verified: hex literals, `INTERVAL` syntax, `APPROX_PERCENTILE`, Dune Spells (`tokens.transfers`, `labels.addresses`)
- **UNION ALL type compatibility** in Q07 (DOUBLE/BIGINT/NULL handled correctly by Trino)
- **Mint/burn detection** (`0x0` and `0xdead` addresses) consistent across Q01, Q04, Q06, Q07

### Code Quality Principles Applied

```mermaid
flowchart LR
    A["Data Consistency\nReference Table\nas Source of Truth"] --> B
    B["Deduplication\nROW_NUMBER on\nlabels.addresses"] --> C
    C["Exclude Internals\ncex-to-cex, dex-to-dex\nbridge-to-bridge"] --> D
    D["No Dead Code\nAll CTEs used\nin output"] --> E
    E["Clear Column Names\nMatch semantics to\nunit/type"]

    style A fill:#1a1a2e,stroke:#e94560,color:#fff
    style B fill:#16213e,stroke:#0f3460,color:#fff
    style C fill:#0f3460,stroke:#533483,color:#fff
    style D fill:#533483,stroke:#e94560,color:#fff
    style E fill:#e94560,stroke:#fff,color:#fff
```

## Dune-Specific Tables

The pipeline uses the following Dune Spells/tables:

| Table | Description |
|-------|-------------|
| `tokens.transfers` | Unified ERC20 transfers across all chains |
| `labels.addresses` | Community-maintained address labels (CEX, DEX, bridge, etc.) |
| `prices.usd` | Token prices (optional, not directly used since stablecoins ~$1) |

## Chains

- Ethereum
- BNB Chain (bnb)
- Polygon
- Arbitrum
- Optimism
- Avalanche C-Chain (avalanche_c)
- Base
