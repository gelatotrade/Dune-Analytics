-- ============================================================================
-- Dune Analytics: Stablecoin Supply Metrics
-- ============================================================================
-- Trackt die Supply-Entwicklung (Mints/Burns) aller Stablecoins ueber
-- die Zeit. Zeigt Gesamtangebot, Mint/Burn-Raten und Dominanz-Anteile.
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '90 days', '365 days'
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

-- Mint- und Burn-Events extrahieren
mint_burn_events AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain,
        s.symbol,
        CASE
            WHEN t."from" = 0x0000000000000000000000000000000000000000
                THEN 'mint'
            WHEN t.to = 0x0000000000000000000000000000000000000000
                OR t.to = 0x000000000000000000000000000000000000dead
                THEN 'burn'
        END AS event_type,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
        AND (
            t."from" = 0x0000000000000000000000000000000000000000
            OR t.to = 0x0000000000000000000000000000000000000000
            OR t.to = 0x000000000000000000000000000000000000dead
        )
),

-- Taegliche Mint/Burn Aggregation
daily_supply_changes AS (
    SELECT
        day,
        blockchain,
        symbol,
        SUM(CASE WHEN event_type = 'mint' THEN amount ELSE 0 END)  AS daily_minted,
        SUM(CASE WHEN event_type = 'burn' THEN amount ELSE 0 END)  AS daily_burned,
        SUM(CASE WHEN event_type = 'mint' THEN amount ELSE 0 END)
        - SUM(CASE WHEN event_type = 'burn' THEN amount ELSE 0 END) AS daily_net_supply_change,
        COUNT(CASE WHEN event_type = 'mint' THEN 1 END) AS mint_count,
        COUNT(CASE WHEN event_type = 'burn' THEN 1 END) AS burn_count
    FROM mint_burn_events
    GROUP BY day, blockchain, symbol
),

-- Kumulative Supply-Veraenderung
cumulative_supply AS (
    SELECT
        day,
        blockchain,
        symbol,
        daily_minted,
        daily_burned,
        daily_net_supply_change,
        mint_count,
        burn_count,
        -- Kumulativer Net Supply Change seit Start des Zeitraums
        SUM(daily_net_supply_change) OVER (
            PARTITION BY blockchain, symbol
            ORDER BY day
        ) AS cumulative_net_supply_change,
        -- 7-Tage Mint-Rate
        SUM(daily_minted) OVER (
            PARTITION BY blockchain, symbol
            ORDER BY day
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS minted_7d,
        -- 7-Tage Burn-Rate
        SUM(daily_burned) OVER (
            PARTITION BY blockchain, symbol
            ORDER BY day
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS burned_7d
    FROM daily_supply_changes
)

SELECT
    day,
    blockchain,
    symbol,
    daily_minted,
    daily_burned,
    daily_net_supply_change,
    mint_count,
    burn_count,
    cumulative_net_supply_change,
    minted_7d,
    burned_7d,
    minted_7d - burned_7d AS net_supply_change_7d,
    -- Mint/Burn Ratio (>1 = expansiv, <1 = kontraktiv)
    daily_minted / NULLIF(daily_burned, 0) AS mint_burn_ratio
FROM cumulative_supply
ORDER BY day DESC, symbol, blockchain
