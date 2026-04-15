-- ============================================================================
-- Dune Analytics: Enhanced Cross-Chain Bridge Flow Tracking (21 Chains)
-- ============================================================================
-- Erweiterte Bridge-Analyse mit 15+ benannten Bridge-Protokollen.
-- Inkl. Scroll Bridge, Mantle Bridge, Blast Bridge, Mode Bridge.
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
        ('USDT', 'scroll',      0xf55bec9cafdbe8730f096aa55dad6d22d44099df, 6),
        ('USDT', 'mantle',      0x201eba5cc46d216ce6dc03f6a759e8e766e956ae, 6),
        ('USDT', 'zkevm',       0x1e4a5963abfd975d8c9021ce480b42188849d41d, 6),
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
        ('USDC', 'scroll',      0x06efdbff2a14a7c8e15944d1f4a48f9f95f663a4, 6),
        ('USDC', 'mantle',      0x09bc4e0d10e52d8da8127c33f8e2be0ee0064622, 6),
        ('USDC', 'blast',       0x4300000000000000000000000000000000000004, 18),
        ('USDC', 'mode',        0xd988097fb8612cc24eec14542bc03424c656005f, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'gnosis',      0x44fa8e6f47987339850636f88629646662444217, 18),
        ('USDB', 'blast',       0x4300000000000000000000000000000000000003, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

-- =====================================================================
-- Bekannte Bridge-Adressen (manuell + labels.addresses)
-- =====================================================================
known_bridges AS (
    SELECT * FROM (VALUES
        -- Stargate / LayerZero
        ('ethereum',    0x8731d54e9d02c286767d56ac03e8037c07e01e98, 'Stargate Router',        'Stargate'),
        ('ethereum',    0xdf0770df86a8034b3efef0a1bb3c889b8332ff56, 'Stargate USDC Pool',     'Stargate'),
        ('ethereum',    0x38ea452219524bb87e18de1c24d3bb59510bd783, 'Stargate USDT Pool',     'Stargate'),
        ('arbitrum',    0x53bf833a5d6c4dda888f69c22c88c9f356a41614, 'Stargate USDC Pool',     'Stargate'),
        ('optimism',    0xdecc0c09c3b5f6e92ef4184125d5648a66e35298, 'Stargate USDC Pool',     'Stargate'),
        ('polygon',     0x1205f31718499dbf1fca446663b532ef87481fe1, 'Stargate USDC Pool',     'Stargate'),
        ('avalanche_c', 0x1205f31718499dbf1fca446663b532ef87481fe1, 'Stargate USDC Pool',     'Stargate'),
        ('base',        0x4c80e24119cfb836cdf0a6b53dc23f04f7e652ca, 'Stargate USDC Pool',     'Stargate'),
        ('bnb',         0x98a5737749490856b401db5dc27f522fc314a4e7, 'Stargate USDT Pool',     'Stargate'),
        ('scroll',      0x3fc69cf04cfb316e54e18dbed6e3985a22412898, 'Stargate Pool',          'Stargate'),
        ('mantle',      0x2b4ba65168f81a2ef3a2b78e684139a0e1a72420, 'Stargate Pool',          'Stargate'),

        -- Across Protocol
        ('ethereum',    0x5c7bcd6e7de5423a257d81b442095a1a6ced35c5, 'Across SpokePool',       'Across'),
        ('arbitrum',    0xe35e9842fceaca96570b734083f4a58e8f7c5f2a, 'Across SpokePool',       'Across'),
        ('optimism',    0x6f26bf09b1c792e3228e5467807a900a503c0281, 'Across SpokePool',       'Across'),
        ('polygon',     0x9295ee1d8c5b022be115a2ad3c30c72e34e7f096, 'Across SpokePool',       'Across'),
        ('base',        0x09aea4b2242abc8bb4bb78d537a67a245a7bec64, 'Across SpokePool',       'Across'),
        ('linea',       0x7e63a5f1a8f0b4d0934b2f2327daed3f6bb2ee75, 'Across SpokePool',       'Across'),
        ('scroll',      0x3bad7ad0728f9917d1bf08af5782dcbd516cdd96, 'Across SpokePool',       'Across'),
        ('blast',       0x2d509190ed0172ba588407d4c2df918f3f9e1f60, 'Across SpokePool',       'Across'),
        ('mode',        0x3bad7ad0728f9917d1bf08af5782dcbd516cdd96, 'Across SpokePool',       'Across'),

        -- Hop Protocol
        ('ethereum',    0x3666f603cc164936c1b87e207f36beba4ac5f18a, 'Hop USDC Bridge',        'Hop'),
        ('ethereum',    0x3e4a3a4796d16c0cd582c382691998f7c06420b6, 'Hop USDT Bridge',        'Hop'),
        ('ethereum',    0xb8901acb165ed027e32754e0ffe830802919727f, 'Hop DAI Bridge',         'Hop'),
        ('arbitrum',    0xe22d2bedb3eca35e6397e0c6d62857094aa26f52, 'Hop USDC Bridge',        'Hop'),
        ('optimism',    0xa11bd36801d8fa4448f0ac4ea7a62e3634ce8c7c, 'Hop USDC Bridge',        'Hop'),
        ('polygon',     0x25d8039bb044dc227f741a9e381ca4ceae2e6ae8, 'Hop USDC Bridge',        'Hop'),

        -- Wormhole (Portal)
        ('ethereum',    0x3ee18b2214aff97000d974cf647e7c347e8fa585, 'Wormhole Token Bridge',  'Wormhole'),

        -- Synapse Protocol
        ('ethereum',    0x2796317b0ff8538f253012862c06787adfb8ceb6, 'Synapse Bridge',         'Synapse'),
        ('arbitrum',    0x6f4e8eba4d337f874ab57478acc2cb5bacdc19c9, 'Synapse Bridge',         'Synapse'),
        ('optimism',    0xaf41a65f786339e7911f4acdad6bd49426f2dc36, 'Synapse Bridge',         'Synapse'),
        ('polygon',     0x8f5bbb2585968f64c461f987d1f5ad6cec013b0f, 'Synapse Bridge',         'Synapse'),
        ('avalanche_c', 0xc05e61d0e7a63d27546389b7ad62fdff5a91aace, 'Synapse Bridge',         'Synapse'),
        ('bnb',         0xd123f70ae324d34a9e76b67a27bf77593ba8749f, 'Synapse Bridge',         'Synapse'),
        ('base',        0xf07d1c752fab503e47fef309bf14fbdd3e867089, 'Synapse Bridge',         'Synapse'),
        ('fantom',      0xaf41a65f786339e7911f4acdad6bd49426f2dc36, 'Synapse Bridge',         'Synapse'),
        ('blast',       0x55769baf6ec39b3bf4aae948eb890ea33307ef3c, 'Synapse Bridge',         'Synapse'),
        ('scroll',      0x55769baf6ec39b3bf4aae948eb890ea33307ef3c, 'Synapse Bridge',         'Synapse'),

        -- Celer cBridge
        ('ethereum',    0x5427fefa711eff984124bfbb1ab6fbf5e3da1820, 'Celer cBridge',          'Celer'),
        ('arbitrum',    0x1619de6b6b20ed217a58d00f37b9d47c7663feca, 'Celer cBridge',          'Celer'),
        ('optimism',    0x9d39fc627a6d9d9f8c831c16995b209548cc3401, 'Celer cBridge',          'Celer'),
        ('polygon',     0x88dcdc47d2f83a99cf0000fdf667a468bb958a78, 'Celer cBridge',          'Celer'),
        ('bnb',         0xdd90e5e87a2081dcf0391920868ebc2ffb81a1af, 'Celer cBridge',          'Celer'),
        ('avalanche_c', 0xef3c714c9425a8f3697a9c969dc1af30ba82e5d4, 'Celer cBridge',          'Celer'),
        ('scroll',      0x9b36f165bab9ebe611d491180418d8de4b8f3a1f, 'Celer cBridge',          'Celer'),
        ('mantle',      0x9b36f165bab9ebe611d491180418d8de4b8f3a1f, 'Celer cBridge',          'Celer'),

        -- Canonical L1<->L2 Bridges
        ('ethereum',    0x99c9fc46f92e8a1c0dec1b1747d010903e884be1, 'Optimism Gateway',       'Optimism Bridge'),
        ('ethereum',    0x8315177ab297ba92a06054ce80a67ed4dbd7ed3a, 'Arbitrum Bridge',        'Arbitrum Bridge'),
        ('ethereum',    0xa0c68c638235ee32657e8f720a23cec1bfc6c9a8, 'Polygon Bridge',         'Polygon Bridge'),
        ('ethereum',    0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf, 'Polygon ERC20 Bridge',   'Polygon Bridge'),
        ('ethereum',    0x3154cf16ccdb4c6d922629664174b904d80f2c35, 'Base Bridge',            'Base Bridge'),
        ('ethereum',    0x32400084c286cf3e17e7b677ea9583e60a000324, 'zkSync Bridge',          'zkSync Bridge'),
        ('ethereum',    0xd19d4b5d358258f05d7b411e21a1460d11b0876f, 'Linea Bridge',           'Linea Bridge'),
        ('ethereum',    0x2a3dd3eb832af982ec71669e178424b10dca2ede, 'Polygon zkEVM Bridge',   'Polygon zkEVM Bridge'),
        ('ethereum',    0xd8a791fe2be73eb6e6cf1eb0cb3f36adc9b3f8f9, 'Scroll Bridge',          'Scroll Bridge'),
        ('ethereum',    0x95fc37a27a2f68e3a647cdc081f0a89bb47c3012, 'Mantle Bridge',          'Mantle Bridge'),
        ('ethereum',    0x3a05e5d33d7ab3864d53aaec93c8301c1fa49115, 'Blast Bridge',           'Blast Bridge'),
        ('ethereum',    0x735adb48095ff90ba4141afed9de7e862ff9a68c, 'Mode Bridge',            'Mode Bridge'),

        -- Orbiter Finance
        ('ethereum',    0x80c67432656d59144ceff962e8faf8926599bcf8, 'Orbiter Bridge',         'Orbiter'),
        ('ethereum',    0xe4edb277e41dc89ab076a1f049f4a3efa700bce8, 'Orbiter Maker',          'Orbiter')

    ) AS t(blockchain, address, name, bridge_protocol)

    UNION ALL

    -- Dynamische Labels aus Dune
    SELECT
        blockchain, address, name,
        COALESCE(
            CASE
                WHEN LOWER(name) LIKE '%stargate%'  THEN 'Stargate'
                WHEN LOWER(name) LIKE '%across%'    THEN 'Across'
                WHEN LOWER(name) LIKE '%hop%'       THEN 'Hop'
                WHEN LOWER(name) LIKE '%wormhole%'  THEN 'Wormhole'
                WHEN LOWER(name) LIKE '%synapse%'   THEN 'Synapse'
                WHEN LOWER(name) LIKE '%celer%'     THEN 'Celer'
                WHEN LOWER(name) LIKE '%orbiter%'   THEN 'Orbiter'
                WHEN LOWER(name) LIKE '%multichain%' OR LOWER(name) LIKE '%anyswap%' THEN 'Multichain'
                WHEN LOWER(name) LIKE '%scroll%bridge%' THEN 'Scroll Bridge'
                WHEN LOWER(name) LIKE '%mantle%bridge%' THEN 'Mantle Bridge'
                WHEN LOWER(name) LIKE '%blast%bridge%' THEN 'Blast Bridge'
                WHEN LOWER(name) LIKE '%mode%bridge%' THEN 'Mode Bridge'
                WHEN LOWER(name) LIKE '%polygon%bridge%' THEN 'Polygon Bridge'
                WHEN LOWER(name) LIKE '%arbitrum%bridge%' THEN 'Arbitrum Bridge'
                WHEN LOWER(name) LIKE '%optimism%' OR LOWER(name) LIKE '%op bridge%' THEN 'Optimism Bridge'
                WHEN LOWER(name) LIKE '%base%bridge%' THEN 'Base Bridge'
                WHEN LOWER(name) LIKE '%zksync%'    THEN 'zkSync Bridge'
                WHEN LOWER(name) LIKE '%linea%'     THEN 'Linea Bridge'
                ELSE 'Other'
            END, 'Other'
        ) AS bridge_protocol
    FROM labels.addresses
    WHERE category = 'bridge'
        AND blockchain IN (
            'ethereum', 'bnb', 'polygon', 'arbitrum', 'optimism', 'base',
            'avalanche_c', 'gnosis', 'fantom', 'celo', 'zksync', 'linea',
            'scroll', 'mantle', 'blast', 'mode', 'zkevm'
        )
),

bridge_addresses AS (
    SELECT DISTINCT blockchain, address, name, bridge_protocol
    FROM known_bridges
),

bridge_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain, s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        t.tx_hash,
        CASE
            WHEN ba_to.address IS NOT NULL AND ba_from.address IS NULL THEN 'to_bridge'
            WHEN ba_from.address IS NOT NULL AND ba_to.address IS NULL THEN 'from_bridge'
            WHEN ba_from.address IS NOT NULL AND ba_to.address IS NOT NULL THEN 'bridge_internal'
        END AS direction,
        COALESCE(ba_to.bridge_protocol, ba_from.bridge_protocol) AS bridge_protocol
    FROM tokens.transfers t
    INNER JOIN stablecoins s
        ON t.blockchain = s.blockchain AND t.contract_address = s.contract_address
    LEFT JOIN bridge_addresses ba_to
        ON t.blockchain = ba_to.blockchain AND t.to = ba_to.address
    LEFT JOIN bridge_addresses ba_from
        ON t.blockchain = ba_from.blockchain AND t."from" = ba_from.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
        AND (ba_to.address IS NOT NULL OR ba_from.address IS NOT NULL)
),

daily_bridge AS (
    SELECT
        day, blockchain, symbol, bridge_protocol,
        SUM(CASE WHEN direction = 'to_bridge' THEN amount ELSE 0 END)   AS outgoing_volume,
        COUNT(CASE WHEN direction = 'to_bridge' THEN 1 END)             AS outgoing_txs,
        SUM(CASE WHEN direction = 'from_bridge' THEN amount ELSE 0 END) AS incoming_volume,
        COUNT(CASE WHEN direction = 'from_bridge' THEN 1 END)           AS incoming_txs
    FROM bridge_transfers
    WHERE direction != 'bridge_internal'
    GROUP BY day, blockchain, symbol, bridge_protocol
)

SELECT
    day, blockchain, symbol, bridge_protocol,
    outgoing_volume, incoming_volume,
    incoming_volume - outgoing_volume AS net_flow,
    outgoing_txs, incoming_txs,
    SUM(incoming_volume - outgoing_volume) OVER (
        PARTITION BY blockchain, symbol, bridge_protocol ORDER BY day
    ) AS cumulative_net_flow,
    SUM(incoming_volume - outgoing_volume) OVER (
        PARTITION BY blockchain, symbol, bridge_protocol ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS net_flow_7d,
    (outgoing_volume + incoming_volume) / NULLIF(
        SUM(outgoing_volume + incoming_volume) OVER (PARTITION BY day, blockchain), 0
    ) * 100 AS bridge_market_share_pct,
    CASE
        WHEN incoming_volume - outgoing_volume > 0 THEN 'net_inflow'
        WHEN incoming_volume - outgoing_volume < 0 THEN 'net_outflow'
        ELSE 'neutral'
    END AS flow_signal
FROM daily_bridge
ORDER BY day DESC, ABS(incoming_volume - outgoing_volume) DESC
