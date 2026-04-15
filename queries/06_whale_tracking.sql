-- ============================================================================
-- Dune Analytics: Stablecoin Whale Transfer Monitoring
-- ============================================================================
-- Ueberwacht grosse Stablecoin-Transfers (>= 1M USD) ueber alle Chains.
-- Identifiziert Whale-Bewegungen, deren Ziele und moegliche Markt-Signale.
--
-- Parameter (Dune UI):
--   {{period}}          - Zeitraum, z.B. '7 days'
--   {{whale_threshold}} - Mindestbetrag fuer Whale-Transfers (Standard: 1000000)
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
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'base',        0x50c5725949a6f0c72e6c4a641f24049a917db0cb, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('FRAX', 'ethereum',    0x853d955acef822db058eb8505911ed77f175b99e, 18),
        ('FRAX', 'arbitrum',    0x17fc002b466eec40dae837fc4be5c67993ddbd6f, 18),
        ('FRAX', 'optimism',    0x2e3d870790dc77a83dd1d18184acc7439a53f475, 18),
        ('GHO',  'ethereum',    0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18),
        ('crvUSD','ethereum',   0xf939e0a03fb07f59a73314e73794be0e57ac1b4e, 18),
        ('PYUSD','ethereum',    0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6),
        ('USDe', 'ethereum',    0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18),
        ('FDUSD','ethereum',    0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('FDUSD','bnb',         0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('LUSD', 'ethereum',    0x5f98805a4e8be255a32880fdec7f6728c6568ba0, 18),
        ('TUSD', 'ethereum',    0x0000000000085d4780b73119b644ae5ecd22b376, 18),
        ('TUSD', 'bnb',         0x40af3827f39d0eacbf4a168f8d4ee67c121d11c9, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

-- Labels fuer Sender/Empfaenger
-- Dedupliziert per ROW_NUMBER um Row-Duplikation bei JOINs zu vermeiden
addr_labels AS (
    SELECT
        blockchain, address, name, category
    FROM (
        SELECT
            blockchain, address, name, category,
            ROW_NUMBER() OVER (PARTITION BY blockchain, address ORDER BY category) AS rn
        FROM labels.addresses
        WHERE blockchain IN ('ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base', 'avalanche_c')
    )
    WHERE rn = 1
),

-- Alle Whale-Transfers
whale_transfers AS (
    SELECT
        t.block_time,
        t.blockchain,
        s.symbol,
        t.tx_hash,
        t."from"                                              AS sender,
        t.to                                                  AS receiver,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)  AS amount,
        COALESCE(ls.name, CAST(t."from" AS VARCHAR))          AS sender_name,
        COALESCE(ls.category, 'unknown')                      AS sender_category,
        COALESCE(lr.name, CAST(t.to AS VARCHAR))              AS receiver_name,
        COALESCE(lr.category, 'unknown')                      AS receiver_category,
        CASE
            WHEN t."from" = 0x0000000000000000000000000000000000000000 THEN 'mint'
            WHEN t.to = 0x0000000000000000000000000000000000000000
                OR t.to = 0x000000000000000000000000000000000000dead THEN 'burn'
            WHEN ls.category = 'cex' AND lr.category = 'cex' THEN 'cex_to_cex'
            WHEN ls.category = 'cex' THEN 'cex_withdrawal'
            WHEN lr.category = 'cex' THEN 'cex_deposit'
            WHEN lr.category = 'bridge' OR ls.category = 'bridge' THEN 'bridge'
            WHEN lr.category = 'dex' OR ls.category = 'dex' THEN 'dex_related'
            ELSE 'wallet_to_wallet'
        END AS transfer_category
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    LEFT JOIN addr_labels ls
        ON t.blockchain = ls.blockchain AND t."from" = ls.address
    LEFT JOIN addr_labels lr
        ON t.blockchain = lr.blockchain AND t.to = lr.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) >= CAST('{{whale_threshold}}' AS DOUBLE)
),

-- Whale-Aktivitaet Zusammenfassung
whale_summary AS (
    SELECT
        DATE_TRUNC('day', block_time) AS day,
        blockchain,
        symbol,
        transfer_category,
        COUNT(*) AS whale_tx_count,
        SUM(amount) AS whale_volume,
        AVG(amount) AS avg_whale_size,
        MAX(amount) AS max_whale_transfer
    FROM whale_transfers
    GROUP BY
        DATE_TRUNC('day', block_time),
        blockchain,
        symbol,
        transfer_category
)

-- Detaillierte Whale-Transfers (fuer Alert-Tabelle)
SELECT
    block_time,
    blockchain,
    symbol,
    amount,
    transfer_category,
    sender_name,
    sender_category,
    receiver_name,
    receiver_category,
    tx_hash,
    -- Ranking nach Groesse
    ROW_NUMBER() OVER (
        PARTITION BY DATE_TRUNC('day', block_time), blockchain
        ORDER BY amount DESC
    ) AS daily_rank
FROM whale_transfers
ORDER BY block_time DESC, amount DESC
