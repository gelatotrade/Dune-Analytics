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
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

-- Dune's labels.addresses Spell fuer Adress-Kategorisierung
labeled_addresses AS (
    SELECT
        blockchain,
        address,
        name,
        category
    FROM labels.addresses
    WHERE category IN ('cex', 'dex', 'bridge', 'defi')
        AND blockchain IN ('ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base', 'avalanche_c')
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
