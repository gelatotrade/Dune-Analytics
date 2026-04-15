-- ============================================================================
-- Dune Analytics: Daily Stablecoin Volume per Chain
-- ============================================================================
-- Aggregiert taegliches Transfer-Volumen, Anzahl Transaktionen und
-- eindeutige Adressen pro Stablecoin und Chain.
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '30 days', '90 days', '365 days'
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

daily_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time)                       AS day,
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)  AS amount,
        t."from"                                               AS sender,
        t.to                                                   AS receiver,
        t.tx_hash
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
),

daily_agg AS (
    SELECT
        day,
        blockchain,
        symbol,
        -- Volumen
        SUM(amount)                                  AS daily_volume,
        COUNT(DISTINCT tx_hash)                      AS tx_count,
        COUNT(*)                                     AS transfer_count,
        -- Eindeutige Adressen
        COUNT(DISTINCT sender)                       AS unique_senders,
        COUNT(DISTINCT receiver)                     AS unique_receivers,
        -- Durchschnittliche Transfer-Groesse
        AVG(amount)                                  AS avg_transfer_size,
        APPROX_PERCENTILE(amount, 0.5)               AS median_transfer_size,
        MAX(amount)                                  AS max_transfer_size
    FROM daily_transfers
    GROUP BY day, blockchain, symbol
)

SELECT
    day,
    blockchain,
    symbol,
    daily_volume,
    tx_count,
    transfer_count,
    unique_senders,
    unique_receivers,
    avg_transfer_size,
    median_transfer_size,
    max_transfer_size,
    -- 7-Tage gleitender Durchschnitt
    AVG(daily_volume) OVER (
        PARTITION BY blockchain, symbol
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma,
    -- 30-Tage gleitender Durchschnitt
    AVG(daily_volume) OVER (
        PARTITION BY blockchain, symbol
        ORDER BY day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS volume_30d_ma,
    -- Taegl. Veraenderung in %
    daily_volume / NULLIF(
        LAG(daily_volume) OVER (PARTITION BY blockchain, symbol ORDER BY day),
        0
    ) - 1 AS daily_change_pct
FROM daily_agg
ORDER BY day DESC, daily_volume DESC
