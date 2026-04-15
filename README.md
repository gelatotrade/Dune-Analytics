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

## Verwendung auf Dune

1. **Query erstellen:** Jede `.sql`-Datei als neue Query auf [dune.com](https://dune.com) anlegen
2. **Parameter setzen:** Die `{{parameter}}` Platzhalter werden automatisch als UI-Inputs in Dune dargestellt
3. **Dashboard bauen:** Queries zu einem Dashboard zusammenfuegen mit:
   - Counter-Widgets fuer globale KPIs (Query 07)
   - Line Charts fuer taegliches Volumen (Query 02)
   - Bar Charts fuer CEX Net Flows (Query 03)
   - Area Charts fuer Supply (Query 04)
   - Tables fuer Whale Alerts (Query 06)

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
