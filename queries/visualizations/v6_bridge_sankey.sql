-- ============================================================================
-- DASHBOARD WIDGET: Bridge Flow Sankey / Bar Chart
-- ============================================================================
-- Dune Widget-Typ: Bar Chart (grouped) oder als Daten fuer Sankey
-- Zeigt Stablecoin-Fluesse zwischen Chains via verschiedene Bridges.
--
-- Zwei Ansichten:
--   1. Pro Bridge-Protokoll: Welche Bridge bewegt am meisten?
--   2. Pro Chain-Paar: Wohin fliesst das Kapital?
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
        ('USDT', 'gnosis',      0x4ecaba5870353805a9f068101a40e0f32ed605c6, 6),
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('USDC', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'zksync',      0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

-- Bridge-Adressen (vereinfacht, Hauptprotkolle)
bridge_addrs AS (
    SELECT * FROM (VALUES
        ('ethereum',    0x8731d54e9d02c286767d56ac03e8037c07e01e98, 'Stargate'),
        ('ethereum',    0xdf0770df86a8034b3efef0a1bb3c889b8332ff56, 'Stargate'),
        ('ethereum',    0x38ea452219524bb87e18de1c24d3bb59510bd783, 'Stargate'),
        ('arbitrum',    0x53bf833a5d6c4dda888f69c22c88c9f356a41614, 'Stargate'),
        ('optimism',    0xdecc0c09c3b5f6e92ef4184125d5648a66e35298, 'Stargate'),
        ('polygon',     0x1205f31718499dbf1fca446663b532ef87481fe1, 'Stargate'),
        ('base',        0x4c80e24119cfb836cdf0a6b53dc23f04f7e652ca, 'Stargate'),
        ('ethereum',    0x5c7bcd6e7de5423a257d81b442095a1a6ced35c5, 'Across'),
        ('arbitrum',    0xe35e9842fceaca96570b734083f4a58e8f7c5f2a, 'Across'),
        ('optimism',    0x6f26bf09b1c792e3228e5467807a900a503c0281, 'Across'),
        ('polygon',     0x9295ee1d8c5b022be115a2ad3c30c72e34e7f096, 'Across'),
        ('base',        0x09aea4b2242abc8bb4bb78d537a67a245a7bec64, 'Across'),
        ('ethereum',    0x3666f603cc164936c1b87e207f36beba4ac5f18a, 'Hop'),
        ('ethereum',    0x3e4a3a4796d16c0cd582c382691998f7c06420b6, 'Hop'),
        ('ethereum',    0x2796317b0ff8538f253012862c06787adfb8ceb6, 'Synapse'),
        ('arbitrum',    0x6f4e8eba4d337f874ab57478acc2cb5bacdc19c9, 'Synapse'),
        ('ethereum',    0x5427fefa711eff984124bfbb1ab6fbf5e3da1820, 'Celer'),
        ('ethereum',    0x3ee18b2214aff97000d974cf647e7c347e8fa585, 'Wormhole'),
        ('ethereum',    0x99c9fc46f92e8a1c0dec1b1747d010903e884be1, 'Optimism Bridge'),
        ('ethereum',    0x8315177ab297ba92a06054ce80a67ed4dbd7ed3a, 'Arbitrum Bridge'),
        ('ethereum',    0xa0c68c638235ee32657e8f720a23cec1bfc6c9a8, 'Polygon Bridge'),
        ('ethereum',    0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf, 'Polygon Bridge'),
        ('ethereum',    0x3154cf16ccdb4c6d922629664174b904d80f2c35, 'Base Bridge'),
        ('ethereum',    0x32400084c286cf3e17e7b677ea9583e60a000324, 'zkSync Bridge'),
        ('ethereum',    0x80c67432656d59144ceff962e8faf8926599bcf8, 'Orbiter')
    ) AS t(blockchain, address, bridge_protocol)
),

bridge_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        COALESCE(ba_to.bridge_protocol, ba_from.bridge_protocol) AS bridge_protocol,
        CASE
            WHEN ba_to.address IS NOT NULL AND ba_from.address IS NULL THEN 'outgoing'
            WHEN ba_from.address IS NOT NULL AND ba_to.address IS NULL THEN 'incoming'
        END AS direction
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    LEFT JOIN bridge_addrs ba_to
        ON t.blockchain = ba_to.blockchain AND t.to = ba_to.address
    LEFT JOIN bridge_addrs ba_from
        ON t.blockchain = ba_from.blockchain AND t."from" = ba_from.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
        AND (ba_to.address IS NOT NULL OR ba_from.address IS NOT NULL)
),

-- =====================================================================
-- Ansicht 1: Bridge-Protokoll Ranking
-- BAR CHART: X=bridge_protocol, Y=total_volume
-- =====================================================================
bridge_ranking AS (
    SELECT
        bridge_protocol,
        SUM(amount) AS total_volume,
        SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS outgoing,
        SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END) AS incoming,
        SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END)
        - SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS net_flow,
        COUNT(*) AS tx_count
    FROM bridge_transfers
    WHERE direction IS NOT NULL
    GROUP BY bridge_protocol
),

-- =====================================================================
-- Ansicht 2: Chain Net Flows via Bridges
-- BAR CHART (horizontal): X=blockchain, Y=net_flow (positiv/negativ)
-- =====================================================================
chain_flows AS (
    SELECT
        blockchain,
        bridge_protocol,
        SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END) AS bridge_incoming,
        SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS bridge_outgoing,
        SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END)
        - SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS net_flow
    FROM bridge_transfers
    WHERE direction IS NOT NULL
    GROUP BY blockchain, bridge_protocol
)

-- Kombinierte Ausgabe
SELECT
    'bridge_ranking' AS view_type,
    bridge_protocol AS label,
    '' AS sub_label,
    total_volume,
    outgoing,
    incoming,
    net_flow,
    tx_count
FROM bridge_ranking

UNION ALL

SELECT
    'chain_bridge_flow' AS view_type,
    blockchain AS label,
    bridge_protocol AS sub_label,
    bridge_incoming + bridge_outgoing AS total_volume,
    bridge_outgoing AS outgoing,
    bridge_incoming AS incoming,
    net_flow,
    0 AS tx_count
FROM chain_flows

ORDER BY view_type, total_volume DESC
