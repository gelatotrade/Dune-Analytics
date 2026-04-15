-- ============================================================================
-- Dune Analytics: Cross-Chain Bridge Flow Tracking
-- ============================================================================
-- Trackt Stablecoin-Bewegungen ueber Bridges zwischen Chains.
-- Identifiziert Kapitalfluesse zwischen L1 und L2s sowie zwischen
-- verschiedenen L2s. Nutzt bekannte Bridge-Adressen aus Dune Labels.
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '30 days'
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
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

-- Bekannte Bridge-Adressen aus Dune Labels
bridge_addresses AS (
    SELECT
        blockchain,
        address,
        name
    FROM labels.addresses
    WHERE category = 'bridge'
        AND blockchain IN ('ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base', 'avalanche_c')
),

-- Transfers an/von Bridge-Adressen
bridge_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        t.tx_hash,
        -- Richtung bestimmen
        CASE
            WHEN ba_to.address IS NOT NULL THEN 'to_bridge'
            WHEN ba_from.address IS NOT NULL THEN 'from_bridge'
        END AS direction,
        -- Bridge-Name
        COALESCE(ba_to.name, ba_from.name) AS bridge_name,
        t."from" AS sender,
        t.to AS receiver
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    LEFT JOIN bridge_addresses ba_to
        ON t.blockchain = ba_to.blockchain
        AND t.to = ba_to.address
    LEFT JOIN bridge_addresses ba_from
        ON t.blockchain = ba_from.blockchain
        AND t."from" = ba_from.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
        AND (ba_to.address IS NOT NULL OR ba_from.address IS NOT NULL)
),

-- Taegliche Bridge-Aggregation
daily_bridge_flows AS (
    SELECT
        day,
        blockchain,
        symbol,
        bridge_name,
        -- Outgoing: Tokens gehen an Bridge (verlassen die Chain)
        SUM(CASE WHEN direction = 'to_bridge' THEN amount ELSE 0 END) AS outgoing_volume,
        COUNT(CASE WHEN direction = 'to_bridge' THEN 1 END) AS outgoing_tx_count,
        -- Incoming: Tokens kommen von Bridge (betreten die Chain)
        SUM(CASE WHEN direction = 'from_bridge' THEN amount ELSE 0 END) AS incoming_volume,
        COUNT(CASE WHEN direction = 'from_bridge' THEN 1 END) AS incoming_tx_count
    FROM bridge_transfers
    GROUP BY day, blockchain, symbol, bridge_name
),

-- Chain-Level Aggregation
chain_bridge_summary AS (
    SELECT
        day,
        blockchain,
        symbol,
        SUM(outgoing_volume) AS total_outgoing,
        SUM(incoming_volume) AS total_incoming,
        SUM(incoming_volume) - SUM(outgoing_volume) AS net_bridge_flow,
        SUM(outgoing_tx_count) AS total_outgoing_txs,
        SUM(incoming_tx_count) AS total_incoming_txs
    FROM daily_bridge_flows
    GROUP BY day, blockchain, symbol
)

SELECT
    day,
    blockchain,
    symbol,
    total_outgoing,
    total_incoming,
    net_bridge_flow,
    total_outgoing_txs,
    total_incoming_txs,
    -- Kumulativer Net Bridge Flow
    SUM(net_bridge_flow) OVER (
        PARTITION BY blockchain, symbol
        ORDER BY day
    ) AS cumulative_net_bridge_flow,
    -- 7-Tage Net Bridge Flow
    SUM(net_bridge_flow) OVER (
        PARTITION BY blockchain, symbol
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS net_bridge_flow_7d,
    -- Signal: Kapital fliesst zur Chain oder weg
    CASE
        WHEN net_bridge_flow > 0 THEN 'net_inflow'
        WHEN net_bridge_flow < 0 THEN 'net_outflow'
        ELSE 'neutral'
    END AS flow_direction
FROM chain_bridge_summary
ORDER BY day DESC, ABS(net_bridge_flow) DESC
