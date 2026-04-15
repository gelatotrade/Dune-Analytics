# Dune Analytics: Stablecoin Flow Pipeline

Multi-Chain Stablecoin-Tracking-Pipeline fuer [Dune Analytics](https://dune.com). Trackt Transfers, Volumen, Supply, Bridge-Flows und Whale-Aktivitaet der wichtigsten Stablecoins ueber **25+ Chains** (EVM + Solana + Tron + Cosmos).

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

### Core EVM Chains (7)
| Chain | Chain-ID (Dune) | Typ |
|-------|----------------|-----|
| Ethereum | `ethereum` | L1 |
| BNB Chain | `bnb` | L1 |
| Polygon | `polygon` | L2 (Sidechain) |
| Arbitrum | `arbitrum` | L2 (Optimistic) |
| Optimism | `optimism` | L2 (Optimistic) |
| Avalanche C-Chain | `avalanche_c` | L1 |
| Base | `base` | L2 (Optimistic) |
| Gnosis | `gnosis` | L1 (Sidechain) |
| Fantom | `fantom` | L1 |
| Celo | `celo` | L1 |
| zkSync Era | `zksync` | L2 (ZK-Rollup) |
| Linea | `linea` | L2 (ZK-Rollup) |

### Neue L2 Chains (5)
| Chain | Chain-ID (Dune) | Typ |
|-------|----------------|-----|
| Scroll | `scroll` | L2 (ZK-Rollup) |
| Mantle | `mantle` | L2 (Optimistic) |
| Blast | `blast` | L2 (Optimistic) |
| Mode | `mode` | L2 (Optimistic) |
| Polygon zkEVM | `zkevm` | L2 (ZK-Rollup) |

### Non-EVM Chains (2)
| Chain | Dune-Tabellen | Typ |
|-------|--------------|-----|
| **Solana** | `tokens_solana.transfers` | L1 (SVM) |
| **Tron** | `tron.logs` | L1 (TVM) - Groesster USDT Markt |

### Cosmos-Adjacent EVM Chains (2)
| Chain | Chain-ID (Dune) | Typ |
|-------|----------------|-----|
| Sei | `sei` | L1 (Cosmos+EVM) |
| Kava | `kava` | L1 (Cosmos+EVM) |

### Cosmos IBC Chains (nicht auf Dune, Referenz)
| Chain | Stablecoins | Hinweis |
|-------|------------|---------|
| Noble | USDC (native) | Offizielle USDC Issuance fuer Cosmos |
| Osmosis | USDC, USDT | Groesster Cosmos DEX |
| Injective | USDT, USDC, USDe | Hohe DeFi-Aktivitaet |
| Cosmos Hub | USDC via IBC | Noble IBC |
| Celestia | USDC via IBC | Geringes Volumen |
| Terra | axlUSDC | Axelar-bridged |

> **Hinweis:** Reine Cosmos/IBC Chains (Injective, Celestia, ATOM) sind nicht direkt auf Dune verfuegbar. Query 11 enthaelt eine Referenz und Template fuer zukuenftige Dune-Unterstuetzung. Alternative Datenquellen: Numia, Flipside, Mintscan.

## Unterstuetzte Bridge-Protokolle (17)

| Bridge | Typ | Chains |
|--------|-----|--------|
| Stargate (LayerZero) | Liquidity Pool | Ethereum, Arbitrum, Optimism, Polygon, Avalanche, Base, BNB, Scroll, Mantle |
| Across Protocol | Intent-based | Ethereum, Arbitrum, Optimism, Polygon, Base, Linea, Scroll, Blast, Mode |
| Hop Protocol | AMM Bridge | Ethereum, Arbitrum, Optimism, Polygon |
| Wormhole (Portal) | Lock & Mint | Multi-chain |
| Synapse Protocol | AMM Bridge | Ethereum, Arbitrum, Optimism, Polygon, Avalanche, BNB, Base, Fantom, Blast, Scroll |
| Celer cBridge | Liquidity Pool | Ethereum, Arbitrum, Optimism, Polygon, BNB, Avalanche, Scroll, Mantle |
| Orbiter Finance | Maker System | Ethereum, L2s |
| Optimism Bridge | Canonical | Ethereum <-> Optimism |
| Arbitrum Bridge | Canonical | Ethereum <-> Arbitrum |
| Polygon Bridge | Canonical | Ethereum <-> Polygon |
| Base Bridge | Canonical | Ethereum <-> Base |
| zkSync Bridge | Canonical | Ethereum <-> zkSync |
| Linea Bridge | Canonical | Ethereum <-> Linea |
| Scroll Bridge | Canonical | Ethereum <-> Scroll |
| Mantle Bridge | Canonical | Ethereum <-> Mantle |
| Blast Bridge | Canonical | Ethereum <-> Blast |
| Mode Bridge | Canonical | Ethereum <-> Mode |
| Polygon zkEVM Bridge | Canonical | Ethereum <-> Polygon zkEVM |

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

## Dashboard Setup-Anleitung

### Schritt 1: Queries auf Dune erstellen

1. Gehe zu [dune.com](https://dune.com) und logge dich ein
2. Klicke "New Query" fuer jede `.sql` Datei
3. Kopiere den SQL-Code und speichere die Query
4. Die `{{parameter}}` Platzhalter werden automatisch als Dropdown/Input im UI

### Schritt 2: Dashboard erstellen

1. Klicke "New Dashboard"
2. Fuge Widgets hinzu ("Add Widget" -> "Query Result")

### Empfohlenes Dashboard-Layout

```
+------------------------------------------------------------------+
| ROW 1: Counter KPIs (v1_counter_kpis.sql)                        |
| [Total Volume] [Total TXs] [Active Chains] [Net Supply Change]   |
+------------------------------------------------------------------+
| ROW 2: Charts                                                     |
| +-----------------------------+ +------------------------------+ |
| | Stacked Area Chart          | | Pie Chart                    | |
| | v3_volume_over_time.sql     | | v2_market_share_pie.sql      | |
| | X=day, Y=daily_volume       | | X=symbol                     | |
| | Group=symbol, Stacked Area  | | Y=volume_share_pct           | |
| +-----------------------------+ +------------------------------+ |
+------------------------------------------------------------------+
| ROW 3: Bridge & Chain Analysis                                    |
| +-----------------------------+ +------------------------------+ |
| | Bar Chart (Bridges)         | | Heatmap Table                | |
| | v6_bridge_sankey.sql        | | v4_chain_heatmap.sql         | |
| | Filter: bridge_ranking     | | Chain x Stablecoin Matrix    | |
| | X=label, Y=total_volume    | | Bedingte Formatierung an     | |
| +-----------------------------+ +------------------------------+ |
+------------------------------------------------------------------+
| ROW 4: CEX Net Flows                                              |
| +--------------------------------------------------------------+ |
| | Bar Chart (pos/neg)                                           | |
| | 03_net_flows.sql                                              | |
| | X=day, Y=cex_net_flow, Group=symbol                          | |
| +--------------------------------------------------------------+ |
+------------------------------------------------------------------+
| ROW 5: Supply & Mint/Burn                                         |
| +--------------------------------------------------------------+ |
| | Area Chart                                                    | |
| | 04_supply_metrics.sql                                         | |
| | X=day, Y=cumulative_net_supply_change, Group=symbol           | |
| +--------------------------------------------------------------+ |
+------------------------------------------------------------------+
| ROW 6: Whale Alerts & Top Flows                                   |
| +--------------------------------------------------------------+ |
| | Table                                                         | |
| | v5_top_flows_table.sql                                        | |
| | Sortiert nach Amount DESC, bedingte Formatierung nach Size    | |
| +--------------------------------------------------------------+ |
+------------------------------------------------------------------+
```

### Schritt 3: Widget-Konfiguration

| Widget | Query | Chart-Typ | X-Achse | Y-Achse | Group By |
|--------|-------|-----------|---------|---------|----------|
| Headline KPIs | v1_counter_kpis | Counter | - | Spalte waehlen | - |
| Volume Timeline | v3_volume_over_time | Stacked Area | day | daily_volume | group_label |
| Market Share | v2_market_share_pie | Pie | symbol | volume_share_pct | - |
| Chain Heatmap | v4_chain_heatmap | Table | - | - | - |
| Bridge Ranking | v6_bridge_sankey | Bar (horizontal) | label | total_volume | - |
| CEX Net Flows | 03_net_flows | Bar (+/-) | day | cex_net_flow | symbol |
| Supply Tracker | 04_supply_metrics | Area | day | cumulative_net_supply_change | symbol |
| Top Flows | v5_top_flows_table | Table | - | - | - |
| Whale Alerts | 06_whale_tracking | Table | - | - | - |
| Bridge Detail | 05_bridge_flows | Line | day | net_flow | bridge_protocol |
| Solana Volume | 08_solana_stablecoins | Bar | day | daily_volume | symbol |

### Schritt 4: Live schalten

1. Oeffne dein Dashboard
2. Klicke rechts oben auf **"Share"**
3. Waehle **"Public"** - jetzt kann jeder mit dem Link das Dashboard sehen
4. Optional: Setze einen **Refresh Schedule** (z.B. alle 6 Stunden)
5. Dein Dashboard ist jetzt live und aktualisiert sich automatisch

### Parameter-Empfehlungen

| Parameter | Standard | Optionen | Beschreibung |
|-----------|----------|----------|-------------|
| `{{period}}` | `30 days` | 7 days, 30 days, 90 days, 365 days | Zeitfenster |
| `{{min_amount}}` | `0` | 0, 1000, 10000, 100000, 1000000 | Mindestbetrag Filter |
| `{{whale_threshold}}` | `1000000` | 500000, 1000000, 5000000, 10000000 | Whale-Schwellenwert |

## Dune-Tabellen Referenz

| Tabelle | Chain | Beschreibung |
|---------|-------|-------------|
| `tokens.transfers` | Alle EVM | Vereinheitlichte ERC20-Transfers |
| `tokens_solana.transfers` | Solana | SPL Token Transfers |
| `labels.addresses` | Alle | Community-Labels (CEX, DEX, Bridge, DeFi) |
| `prices.usd` | Alle | Token-Preise (optional fuer Stablecoins) |

## Technische Hinweise

- **DuneSQL (Trino)**: Alle Queries nutzen DuneSQL-Syntax
- **Adressen**: EVM-Adressen als `0x...` Hex, Solana als Base58 Strings
- **Decimals**: Werden pro Token/Chain korrekt beruecksichtigt (6/8/18)
- **Labels**: `labels.addresses` wird von der Dune Community gepflegt
- **Performance**: Fuer grosse Zeitraeume (>90 Tage) kann die Ausfuehrung laenger dauern
