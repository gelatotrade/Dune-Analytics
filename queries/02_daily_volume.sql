-- ============================================================================
-- Dune Analytics: Daily Stablecoin Volume per Chain (21 Chains)
-- ============================================================================
-- Aggregiert taegliches Transfer-Volumen, Transaktionen und Adressen
-- pro Stablecoin und Chain. Inkl. 7d/30d gleitende Durchschnitte.
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
        ('USDT', 'fantom',      0x049d68029688eabf473097a2fc38ef61633a3c7a, 6),
        ('USDT', 'celo',        0x48065fbbe25f71c9282ddf5e1cd6d6a887483d5e, 6),
        ('USDT', 'scroll',      0xf55bec9cafdbe8730f096aa55dad6d22d44099df, 6),
        ('USDT', 'mantle',      0x201eba5cc46d216ce6dc03f6a759e8e766e956ae, 6),
        ('USDT', 'mode',        0xf0f161fda2712db8b566946122a5af183995e2ed, 18),
        ('USDT', 'zkevm',       0x1e4a5963abfd975d8c9021ce480b42188849d41d, 6),
        ('USDC', 'ethereum',    0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6),
        ('USDC', 'bnb',         0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18),
        ('USDC', 'polygon',     0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6),
        ('USDC', 'arbitrum',    0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6),
        ('USDC', 'optimism',    0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6),
        ('USDC', 'avalanche_c', 0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6),
        ('USDC', 'base',        0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6),
        ('USDC', 'gnosis',      0xddafbb505ad214d7b80b1f830fccc89b60fb7a83, 6),
        ('USDC', 'celo',        0xceba9300f2b948710d2653dd7b07f33a8b32118c, 6),
        ('USDC', 'fantom',      0x04068da6c83afcfa0e13ba15a6696662335d5b75, 6),
        ('USDC', 'zksync',      0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6),
        ('USDC', 'linea',       0x176211869ca2b568f2a7d4ee941e073a821ee1ff, 6),
        ('USDC', 'scroll',      0x06efdbff2a14a7c8e15944d1f4a48f9f95f663a4, 6),
        ('USDC', 'mantle',      0x09bc4e0d10e52d8da8127c33f8e2be0ee0064622, 6),
        ('USDC', 'mode',        0xd988097fb8612cc24eec14542bc03424c656005f, 6),
        ('USDC', 'zkevm',       0xa8ce8aee21bc2a48a5ef670afcc9274c7bbbc035, 6),
        ('USDC', 'blast',       0x4300000000000000000000000000000000000004, 18),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('DAI',  'polygon',     0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18),
        ('DAI',  'arbitrum',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'optimism',    0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18),
        ('DAI',  'gnosis',      0x44fa8e6f47987339850636f88629646662444217, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('FRAX', 'ethereum',    0x853d955acef822db058eb8505911ed77f175b99e, 18),
        ('GHO',  'ethereum',    0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18),
        ('crvUSD','ethereum',   0xf939e0a03fb07f59a73314e73794be0e57ac1b4e, 18),
        ('PYUSD','ethereum',    0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6),
        ('USDe', 'ethereum',    0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18),
        ('USDe', 'blast',       0x4fee793d435c6944b88e45ed9160f5153495bbf3, 18),
        ('FDUSD','bnb',         0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18),
        ('LUSD', 'ethereum',    0x5f98805a4e8be255a32880fdec7f6728c6568ba0, 18),
        ('BUSD', 'bnb',         0xe9e7cea3dedca5984780bafc599bd69add087d56, 18),
        ('USDB', 'blast',       0x4300000000000000000000000000000000000003, 18),
        ('USDY', 'ethereum',    0x96f6ef951840721adbf46ac996b59e0235cb985c, 18),
        ('USDY', 'mantle',      0x5be26527e817998a7206475496fde1e68957c5a6, 18),
        ('USDC.e','arbitrum',   0xff970a61a04b1ca14834a43f5de4533ebddb5cc8, 6),
        ('USDC.e','optimism',   0x7f5c764cbc14f9669b88837ca1490cca17c31607, 6),
        ('USDC.e','polygon',    0x2791bca1f2de4661ed88a30c99a7a9449aa84174, 6),
        ('USDC.e','avalanche_c',0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664, 6),
        ('USDbC','base',        0xd9aaec86b65d86f6a7b5b1b0c42ffa531710b6ca, 6)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

daily_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        t.blockchain,
        s.symbol,
        CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS amount,
        t."from" AS sender,
        t.to     AS receiver,
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
        day, blockchain, symbol,
        SUM(amount)                        AS daily_volume,
        COUNT(DISTINCT tx_hash)            AS tx_count,
        COUNT(*)                           AS transfer_count,
        COUNT(DISTINCT sender)             AS unique_senders,
        COUNT(DISTINCT receiver)           AS unique_receivers,
        AVG(amount)                        AS avg_transfer_size,
        APPROX_PERCENTILE(amount, 0.5)     AS median_transfer_size,
        MAX(amount)                        AS max_transfer_size
    FROM daily_transfers
    GROUP BY day, blockchain, symbol
)

SELECT
    day, blockchain, symbol,
    daily_volume, tx_count, transfer_count,
    unique_senders, unique_receivers,
    avg_transfer_size, median_transfer_size, max_transfer_size,
    AVG(daily_volume) OVER (
        PARTITION BY blockchain, symbol ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma,
    AVG(daily_volume) OVER (
        PARTITION BY blockchain, symbol ORDER BY day
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS volume_30d_ma,
    daily_volume / NULLIF(
        LAG(daily_volume) OVER (PARTITION BY blockchain, symbol ORDER BY day), 0
    ) - 1 AS daily_change_pct
FROM daily_agg
ORDER BY day DESC, daily_volume DESC
