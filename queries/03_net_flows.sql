-- ============================================================================
-- Dune Analytics: Stablecoin Net Flows (CEX / DEX / Bridge)
-- ============================================================================
-- Analysiert Netto-Flows von Stablecoins zu/von bekannten Adressen
-- (Exchanges, Bridges, DeFi-Protokolle). Zeigt ob Kapital in/aus
-- zentralen Boersen fliesst - ein wichtiger Marktindikator.
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '7 days', '30 days'
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

-- Dune's labels.addresses Spell fuer Adress-Kategorisierung
-- Dedupliziert per ROW_NUMBER um Row-Duplikation bei JOINs zu vermeiden
labeled_addresses AS (
    SELECT
        blockchain,
        address,
        name,
        category
    FROM (
        SELECT
            blockchain,
            address,
            name,
            category,
            ROW_NUMBER() OVER (PARTITION BY blockchain, address ORDER BY category) AS rn
        FROM labels.addresses
        WHERE category IN ('cex', 'dex', 'bridge', 'defi')
            AND blockchain IN ('ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base', 'avalanche_c')
    )
    WHERE rn = 1
),

transfers_labeled AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        t."from" AS sender,
        t.to AS receiver,
        -- Sender-Kategorie
        COALESCE(ls.category, 'unknown') AS sender_category,
        COALESCE(ls.name, 'unknown')     AS sender_name,
        -- Empfaenger-Kategorie
        COALESCE(lr.category, 'unknown') AS receiver_category,
        COALESCE(lr.name, 'unknown')     AS receiver_name
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    LEFT JOIN labeled_addresses ls
        ON t.blockchain = ls.blockchain
        AND t."from" = ls.address
    LEFT JOIN labeled_addresses lr
        ON t.blockchain = lr.blockchain
        AND t.to = lr.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
),

-- CEX Net Flows: Inflows (an CEX) minus Outflows (von CEX)
cex_flows AS (
    SELECT
        day,
        blockchain,
        symbol,
        -- Inflows zu Exchanges
        SUM(CASE WHEN receiver_category = 'cex' AND sender_category != 'cex'
            THEN amount ELSE 0 END) AS cex_inflow,
        -- Outflows von Exchanges
        SUM(CASE WHEN sender_category = 'cex' AND receiver_category != 'cex'
            THEN amount ELSE 0 END) AS cex_outflow,
        -- Interne Exchange-Transfers
        SUM(CASE WHEN sender_category = 'cex' AND receiver_category = 'cex'
            THEN amount ELSE 0 END) AS cex_internal
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
),

-- DEX Flows
dex_flows AS (
    SELECT
        day,
        blockchain,
        symbol,
        SUM(CASE WHEN receiver_category = 'dex' THEN amount ELSE 0 END) AS dex_inflow,
        SUM(CASE WHEN sender_category = 'dex' THEN amount ELSE 0 END)   AS dex_outflow
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
),

-- Bridge Flows
bridge_flows AS (
    SELECT
        day,
        blockchain,
        symbol,
        SUM(CASE WHEN receiver_category = 'bridge' THEN amount ELSE 0 END) AS bridge_inflow,
        SUM(CASE WHEN sender_category = 'bridge' THEN amount ELSE 0 END)   AS bridge_outflow
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
)

SELECT
    c.day,
    c.blockchain,
    c.symbol,
    -- CEX
    c.cex_inflow,
    c.cex_outflow,
    c.cex_inflow - c.cex_outflow AS cex_net_flow,
    c.cex_internal,
    -- DEX
    d.dex_inflow,
    d.dex_outflow,
    d.dex_inflow - d.dex_outflow AS dex_net_flow,
    -- Bridge
    b.bridge_inflow,
    b.bridge_outflow,
    b.bridge_inflow - b.bridge_outflow AS bridge_net_flow,
    -- Interpretation
    CASE
        WHEN c.cex_inflow - c.cex_outflow > 0 THEN 'net_inflow_to_cex'
        WHEN c.cex_inflow - c.cex_outflow < 0 THEN 'net_outflow_from_cex'
        ELSE 'neutral'
    END AS cex_flow_signal,
    -- Kumulativer CEX Net Flow
    SUM(c.cex_inflow - c.cex_outflow) OVER (
        PARTITION BY c.blockchain, c.symbol
        ORDER BY c.day
    ) AS cumulative_cex_net_flow
FROM cex_flows c
LEFT JOIN dex_flows d
    ON c.day = d.day AND c.blockchain = d.blockchain AND c.symbol = d.symbol
LEFT JOIN bridge_flows b
    ON c.day = b.day AND c.blockchain = b.blockchain AND c.symbol = b.symbol
ORDER BY c.day DESC, c.blockchain, c.symbol
