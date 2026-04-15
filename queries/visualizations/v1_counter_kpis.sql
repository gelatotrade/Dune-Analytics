-- ============================================================================
-- DASHBOARD WIDGET: Counter KPIs (Headline-Zahlen)
-- ============================================================================
-- Dune Widget-Typ: Counter
-- Zeigt die wichtigsten Kennzahlen als grosse Zahlen oben im Dashboard.
-- Erstelle fuer JEDEN Counter eine eigene Query-Kopie mit dem
-- entsprechenden SELECT am Ende.
--
-- Parameter: {{period}}
-- ============================================================================

WITH stablecoins AS (
    SELECT * FROM (VALUES
        ('USDT', 'ethereum',    0xdac17f958d2ee523a2206206994597c13d831ec7, 6),
        ('USDT', 'bnb',         0x55d398326f99059ff775485246999027b3197955, 18),
        ('USDT', 'polygon',     0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 6),
        ('USDT', 'arbitrum',    0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9, 6),
        ('USDT', 'optimism',    0x94b008aa00579c1307b0ef2c499ad98a8ce58e58, 6),
        ('USDT', 'avalanche_c', 0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7, 6),
        ('USDT', 'base',        0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6),
        ('USDT', 'gnosis',      0x4ecaba5870353805a9f068101a40e0f32ed605c6, 6),
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('USDC', 'gnosis',      0xddafbb505ad214d7b80b1f830fccc89b60fb7a83, 6),
        ('USDC', 'zksync',      0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6),
        ('USDC', 'linea',       0x176211869ca2b568f2a7d4ee941e073a821ee1ff, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'gnosis',      0x44fa8e6f47987339850636f88629646662444217, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('FRAX', 'ethereum',    0x853d955acef822db058eb8505911ed77f175b99e, 18),
        ('GHO',  'ethereum',    0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18),
        ('USDe', 'ethereum',    0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18),
        ('FDUSD','bnb',         0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('PYUSD','ethereum',    0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

base_data AS (
    SELECT
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        t.tx_hash,
        t."from" AS sender,
        t.to AS receiver,
        t.block_time,
        CASE
            WHEN t."from" = 0x0000000000000000000000000000000000000000 THEN 'mint'
            WHEN t.to IN (0x0000000000000000000000000000000000000000,
                          0x000000000000000000000000000000000000dead) THEN 'burn'
            ELSE 'transfer'
        END AS tx_type
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
),

-- Aktuelle Periode
current_period AS (
    SELECT
        SUM(amount)                                          AS total_volume,
        COUNT(DISTINCT tx_hash)                              AS total_txs,
        COUNT(DISTINCT sender)                               AS unique_senders,
        COUNT(DISTINCT receiver)                             AS unique_receivers,
        COUNT(DISTINCT blockchain)                           AS active_chains,
        COUNT(DISTINCT symbol)                               AS active_stablecoins,
        SUM(CASE WHEN tx_type = 'mint' THEN amount ELSE 0 END)  AS total_minted,
        SUM(CASE WHEN tx_type = 'burn' THEN amount ELSE 0 END)  AS total_burned,
        SUM(CASE WHEN amount >= 1000000 THEN amount ELSE 0 END) AS whale_volume,
        COUNT(CASE WHEN amount >= 1000000 THEN 1 END)            AS whale_tx_count,
        AVG(amount)                                              AS avg_transfer_size
    FROM base_data
)

-- ===== COUNTER 1: Gesamtvolumen =====
-- Dune Counter: Titel "Total Stablecoin Volume", Prefix "$", Suffix formatieren
SELECT
    total_volume                                    AS "Total Volume ($)",
    total_txs                                       AS "Total Transactions",
    unique_senders + unique_receivers               AS "Unique Addresses",
    active_chains                                   AS "Active Chains",
    active_stablecoins                              AS "Stablecoins Tracked",
    total_minted                                    AS "Total Minted ($)",
    total_burned                                    AS "Total Burned ($)",
    total_minted - total_burned                     AS "Net Supply Change ($)",
    whale_volume                                    AS "Whale Volume (>1M) ($)",
    whale_tx_count                                  AS "Whale Transactions",
    whale_volume / NULLIF(total_volume, 0) * 100    AS "Whale Volume Share (%)",
    avg_transfer_size                               AS "Avg Transfer Size ($)"
FROM current_period
