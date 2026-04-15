-- ============================================================================
-- Dune Analytics: Stablecoin Net Flows CEX/DEX/Bridge (21 Chains)
-- ============================================================================
-- Analysiert Netto-Flows zu/von CEX, DEX und Bridges.
-- Alle 19 EVM-Chains unterstuetzt.
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
        ('USDT', 'base',        0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6),
        ('USDT', 'avalanche_c', 0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7, 6),
        ('USDT', 'scroll',      0xf55bec9cafdbe8730f096aa55dad6d22d44099df, 6),
        ('USDT', 'mantle',      0x201eba5cc46d216ce6dc03f6a759e8e766e956ae, 6),
        ('USDT', 'zkevm',       0x1e4a5963abfd975d8c9021ce480b42188849d41d, 6),
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('USDC', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'scroll',      0x06efdbff2a14a7c8e15944d1f4a48f9f95f663a4, 6),
        ('USDC', 'mantle',      0x09bc4e0d10e52d8da8127c33f8e2be0ee0064622, 6),
        ('USDC', 'zksync',      0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6),
        ('USDC', 'linea',       0x176211869ca2b568f2a7d4ee941e073a821ee1ff, 6),
        ('USDC', 'blast',       0x4300000000000000000000000000000000000004, 18),
        ('USDC', 'mode',        0xd988097fb8612cc24eec14542bc03424c656005f, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('USDB', 'blast',       0x4300000000000000000000000000000000000003, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

labeled_addresses AS (
    SELECT blockchain, address, name, category
    FROM labels.addresses
    WHERE category IN ('cex', 'dex', 'bridge', 'defi')
        AND blockchain IN (
            'ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base',
            'avalanche_c', 'gnosis', 'fantom', 'celo', 'zksync', 'linea',
            'scroll', 'mantle', 'blast', 'mode', 'zkevm'
        )
),

transfers_labeled AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain, s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        COALESCE(ls.category, 'unknown') AS sender_category,
        COALESCE(lr.category, 'unknown') AS receiver_category
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain AND t.contract_address = s.contract_address
    LEFT JOIN labeled_addresses ls
        ON t.blockchain = ls.blockchain AND t."from" = ls.address
    LEFT JOIN labeled_addresses lr
        ON t.blockchain = lr.blockchain AND t.to = lr.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
),

cex_flows AS (
    SELECT
        day, blockchain, symbol,
        SUM(CASE WHEN receiver_category = 'cex' AND sender_category != 'cex'
            THEN amount ELSE 0 END) AS cex_inflow,
        SUM(CASE WHEN sender_category = 'cex' AND receiver_category != 'cex'
            THEN amount ELSE 0 END) AS cex_outflow,
        SUM(CASE WHEN sender_category = 'cex' AND receiver_category = 'cex'
            THEN amount ELSE 0 END) AS cex_internal
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
),

dex_flows AS (
    SELECT
        day, blockchain, symbol,
        SUM(CASE WHEN receiver_category = 'dex' THEN amount ELSE 0 END) AS dex_inflow,
        SUM(CASE WHEN sender_category = 'dex' THEN amount ELSE 0 END)   AS dex_outflow
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
),

bridge_flows AS (
    SELECT
        day, blockchain, symbol,
        SUM(CASE WHEN receiver_category = 'bridge' THEN amount ELSE 0 END) AS bridge_inflow,
        SUM(CASE WHEN sender_category = 'bridge' THEN amount ELSE 0 END)   AS bridge_outflow
    FROM transfers_labeled
    GROUP BY day, blockchain, symbol
)

SELECT
    c.day, c.blockchain, c.symbol,
    c.cex_inflow, c.cex_outflow,
    c.cex_inflow - c.cex_outflow AS cex_net_flow,
    c.cex_internal,
    d.dex_inflow, d.dex_outflow,
    d.dex_inflow - d.dex_outflow AS dex_net_flow,
    b.bridge_inflow, b.bridge_outflow,
    b.bridge_inflow - b.bridge_outflow AS bridge_net_flow,
    CASE
        WHEN c.cex_inflow - c.cex_outflow > 0 THEN 'net_inflow_to_cex'
        WHEN c.cex_inflow - c.cex_outflow < 0 THEN 'net_outflow_from_cex'
        ELSE 'neutral'
    END AS cex_flow_signal,
    SUM(c.cex_inflow - c.cex_outflow) OVER (
        PARTITION BY c.blockchain, c.symbol ORDER BY c.day
    ) AS cumulative_cex_net_flow
FROM cex_flows c
LEFT JOIN dex_flows d
    ON c.day = d.day AND c.blockchain = d.blockchain AND c.symbol = d.symbol
LEFT JOIN bridge_flows b
    ON c.day = b.day AND c.blockchain = b.blockchain AND c.symbol = b.symbol
ORDER BY c.day DESC, c.blockchain, c.symbol
