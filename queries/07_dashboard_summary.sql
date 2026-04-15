-- ============================================================================
-- Dune Analytics: Stablecoin Dashboard Summary
-- ============================================================================
-- Zusammenfassende Uebersicht fuer ein Dune-Dashboard. Aggregiert die
-- wichtigsten KPIs aller Stablecoins ueber alle Chains in einer
-- kompakten Ansicht.
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '30 days'
-- ============================================================================

WITH stablecoins AS (
    SELECT * FROM (VALUES
        ('USDT', 'Tether',       'centralized', 'ethereum',    0xdac17f958d2ee523a2206206994597c13d831ec7, 6),
        ('USDT', 'Tether',       'centralized', 'bnb',         0x55d398326f99059ff775485246999027b3197955, 18),
        ('USDT', 'Tether',       'centralized', 'polygon',     0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 6),
        ('USDT', 'Tether',       'centralized', 'arbitrum',    0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9, 6),
        ('USDT', 'Tether',       'centralized', 'optimism',    0x94b008aa00579c1307b0ef2c499ad98a8ce58e58, 6),
        ('USDT', 'Tether',       'centralized', 'avalanche_c', 0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7, 6),
        ('USDT', 'Tether',       'centralized', 'base',        0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6),
        ('USDC', 'Circle',       'centralized', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'Circle',       'centralized', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'Circle',       'centralized', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'Circle',       'centralized', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'Circle',       'centralized', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'Circle',       'centralized', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'Circle',       'centralized', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('DAI',  'MakerDAO',     'decentralized','ethereum',   0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'MakerDAO',     'decentralized','polygon',    0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'MakerDAO',     'decentralized','arbitrum',   0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'MakerDAO',     'decentralized','optimism',   0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('USDS', 'Sky',          'decentralized','ethereum',   0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('FRAX', 'Frax Finance', 'hybrid',       'ethereum',   0x853d955acef822db058eb8505911ed77f175b99e, 18),
        ('GHO',  'Aave',         'decentralized','ethereum',   0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18),
        ('crvUSD','Curve',       'decentralized','ethereum',   0xf939e0a03fb07f59a73314e73794be0e57ac1b4e, 18),
        ('PYUSD','PayPal',       'centralized',  'ethereum',   0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6),
        ('USDe', 'Ethena',       'hybrid',       'ethereum',   0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18),
        ('FDUSD','First Digital','centralized',  'ethereum',   0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('FDUSD','First Digital','centralized',  'bnb',        0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('LUSD', 'Liquity',      'decentralized','ethereum',   0x5f98805a4e8be255a32880fdec7f6728c6568ba0, 18)
    ) AS t(symbol, issuer, category, blockchain, contract_address, decimals)
),

-- =====================================================================
-- TEIL 1: KPIs pro Stablecoin (alle Chains zusammengefasst)
-- =====================================================================
per_stablecoin AS (
    SELECT
        s.symbol,
        s.issuer,
        s.category,
        SUM(CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)) AS total_volume,
        COUNT(DISTINCT t.tx_hash) AS total_txs,
        COUNT(DISTINCT t."from") AS unique_senders,
        COUNT(DISTINCT t.to) AS unique_receivers,
        COUNT(DISTINCT t.blockchain) AS active_chains,
        SUM(CASE
            WHEN t."from" = 0x0000000000000000000000000000000000000000
            THEN CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)
            ELSE 0
        END) AS total_minted,
        SUM(CASE
            WHEN t.to = 0x0000000000000000000000000000000000000000
                OR t.to = 0x000000000000000000000000000000000000dead
            THEN CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)
            ELSE 0
        END) AS total_burned
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
    GROUP BY s.symbol, s.issuer, s.category
),

-- =====================================================================
-- TEIL 2: KPIs pro Chain (alle Stablecoins zusammengefasst)
-- =====================================================================
per_chain AS (
    SELECT
        t.blockchain,
        SUM(CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)) AS chain_volume,
        COUNT(DISTINCT t.tx_hash) AS chain_txs,
        COUNT(DISTINCT s.symbol) AS stablecoins_active,
        COUNT(DISTINCT t."from") + COUNT(DISTINCT t.to) AS unique_addresses
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
    GROUP BY t.blockchain
),

-- =====================================================================
-- TEIL 3: Globale KPIs
-- =====================================================================
global_kpis AS (
    SELECT
        SUM(total_volume) AS global_volume,
        SUM(total_txs) AS global_txs,
        SUM(total_minted) AS global_minted,
        SUM(total_burned) AS global_burned,
        SUM(total_minted) - SUM(total_burned) AS global_net_supply_change
    FROM per_stablecoin
)

-- =====================================================================
-- Ergebnis: Stablecoin-Ranking mit Marktanteilen
-- =====================================================================
SELECT
    ps.symbol,
    ps.issuer,
    ps.category,
    ps.total_volume,
    ps.total_txs,
    ps.unique_senders,
    ps.unique_receivers,
    ps.active_chains,
    ps.total_minted,
    ps.total_burned,
    ps.total_minted - ps.total_burned AS net_supply_change,
    -- Marktanteil nach Volumen
    ps.total_volume / NULLIF(g.global_volume, 0) * 100 AS volume_market_share_pct,
    -- Marktanteil nach Transaktionen
    CAST(ps.total_txs AS DOUBLE) / NULLIF(g.global_txs, 0) * 100 AS tx_market_share_pct,
    -- Rang
    ROW_NUMBER() OVER (ORDER BY ps.total_volume DESC) AS volume_rank,
    ROW_NUMBER() OVER (ORDER BY ps.total_txs DESC) AS tx_rank
FROM per_stablecoin ps
CROSS JOIN global_kpis g
ORDER BY ps.total_volume DESC
