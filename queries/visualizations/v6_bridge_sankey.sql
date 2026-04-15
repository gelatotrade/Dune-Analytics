-- ============================================================================
-- DASHBOARD WIDGET: Bridge Flow Comparison - 21 Chains, 15 Bridges
-- ============================================================================
-- Dune: Bar Chart | X=label, Y=total_volume | Parameter: {{period}}
-- ============================================================================

WITH stablecoins AS (
    SELECT * FROM (VALUES
        ('USDT', 'ethereum',    0xdac17f958d2ee523a2206206994597c13d831ec7, 6),
        ('USDT', 'bnb',         0x55d398326f99059ff775485246999027b3197955, 18),
        ('USDT', 'polygon',     0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 6),
        ('USDT', 'arbitrum',    0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9, 6),
        ('USDT', 'optimism',    0x94b008aa00579c1307b0ef2c499ad98a8ce58e58, 6),
        ('USDT', 'base',        0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6),
        ('USDT', 'scroll',      0xf55bec9cafdbe8730f096aa55dad6d22d44099df, 6),
        ('USDT', 'mantle',      0x201eba5cc46d216ce6dc03f6a759e8e766e956ae, 6),
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('USDC', 'scroll',      0x06efdbff2a14a7c8e15944d1f4a48f9f95f663a4, 6),
        ('USDC', 'mantle',      0x09bc4e0d10e52d8da8127c33f8e2be0ee0064622, 6),
        ('USDC', 'blast',       0x4300000000000000000000000000000000000004, 18),
        ('USDC', 'zksync',      0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

bridge_addrs AS (
    SELECT * FROM (VALUES
        ('ethereum', 0x8731d54e9d02c286767d56ac03e8037c07e01e98, 'Stargate'),
        ('ethereum', 0xdf0770df86a8034b3efef0a1bb3c889b8332ff56, 'Stargate'),
        ('ethereum', 0x5c7bcd6e7de5423a257d81b442095a1a6ced35c5, 'Across'),
        ('arbitrum', 0xe35e9842fceaca96570b734083f4a58e8f7c5f2a, 'Across'),
        ('optimism', 0x6f26bf09b1c792e3228e5467807a900a503c0281, 'Across'),
        ('base',     0x09aea4b2242abc8bb4bb78d537a67a245a7bec64, 'Across'),
        ('scroll',   0x3bad7ad0728f9917d1bf08af5782dcbd516cdd96, 'Across'),
        ('blast',    0x2d509190ed0172ba588407d4c2df918f3f9e1f60, 'Across'),
        ('ethereum', 0x3666f603cc164936c1b87e207f36beba4ac5f18a, 'Hop'),
        ('ethereum', 0x2796317b0ff8538f253012862c06787adfb8ceb6, 'Synapse'),
        ('ethereum', 0x5427fefa711eff984124bfbb1ab6fbf5e3da1820, 'Celer'),
        ('ethereum', 0x3ee18b2214aff97000d974cf647e7c347e8fa585, 'Wormhole'),
        ('ethereum', 0x99c9fc46f92e8a1c0dec1b1747d010903e884be1, 'Optimism Bridge'),
        ('ethereum', 0x8315177ab297ba92a06054ce80a67ed4dbd7ed3a, 'Arbitrum Bridge'),
        ('ethereum', 0xa0c68c638235ee32657e8f720a23cec1bfc6c9a8, 'Polygon Bridge'),
        ('ethereum', 0x3154cf16ccdb4c6d922629664174b904d80f2c35, 'Base Bridge'),
        ('ethereum', 0x32400084c286cf3e17e7b677ea9583e60a000324, 'zkSync Bridge'),
        ('ethereum', 0xd19d4b5d358258f05d7b411e21a1460d11b0876f, 'Linea Bridge'),
        ('ethereum', 0xd8a791fe2be73eb6e6cf1eb0cb3f36adc9b3f8f9, 'Scroll Bridge'),
        ('ethereum', 0x95fc37a27a2f68e3a647cdc081f0a89bb47c3012, 'Mantle Bridge'),
        ('ethereum', 0x3a05e5d33d7ab3864d53aaec93c8301c1fa49115, 'Blast Bridge'),
        ('ethereum', 0x735adb48095ff90ba4141afed9de7e862ff9a68c, 'Mode Bridge'),
        ('ethereum', 0x2a3dd3eb832af982ec71669e178424b10dca2ede, 'Polygon zkEVM Bridge'),
        ('ethereum', 0x80c67432656d59144ceff962e8faf8926599bcf8, 'Orbiter')
    ) AS t(blockchain, address, bridge_protocol)
),

bridge_transfers AS (
    SELECT
        t.blockchain, s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        COALESCE(ba_to.bridge_protocol, ba_from.bridge_protocol) AS bridge_protocol,
        CASE
            WHEN ba_to.address IS NOT NULL AND ba_from.address IS NULL THEN 'outgoing'
            WHEN ba_from.address IS NOT NULL AND ba_to.address IS NULL THEN 'incoming'
        END AS direction
    FROM tokens.transfers t
    INNER JOIN stablecoins s ON t.blockchain = s.blockchain AND t.contract_address = s.contract_address
    LEFT JOIN bridge_addrs ba_to ON t.blockchain = ba_to.blockchain AND t.to = ba_to.address
    LEFT JOIN bridge_addrs ba_from ON t.blockchain = ba_from.blockchain AND t."from" = ba_from.address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}' AND t.amount_raw > 0
        AND (ba_to.address IS NOT NULL OR ba_from.address IS NOT NULL)
)

SELECT
    bridge_protocol AS label,
    SUM(amount) AS total_volume,
    SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS outgoing,
    SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END) AS incoming,
    SUM(CASE WHEN direction = 'incoming' THEN amount ELSE 0 END)
    - SUM(CASE WHEN direction = 'outgoing' THEN amount ELSE 0 END) AS net_flow,
    COUNT(*) AS tx_count
FROM bridge_transfers
WHERE direction IS NOT NULL
GROUP BY bridge_protocol
ORDER BY total_volume DESC
