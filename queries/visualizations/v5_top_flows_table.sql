-- ============================================================================
-- DASHBOARD WIDGET: Top Flows Table - 21 Chains
-- ============================================================================
-- Dune Widget-Typ: Table | Parameter: {{period}}, {{min_amount}}
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
        ('USDC', 'linea',       0x176211869ca2b568f2a7d4ee941e073a821ee1ff, 6),
        ('DAI',  'ethereum',    0x6b175474e89094c44da98b954eedeac495271d0f, 18),
        ('USDS', 'ethereum',    0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18),
        ('GHO',  'ethereum',    0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18),
        ('USDe', 'ethereum',    0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18),
        ('USDB', 'blast',       0x4300000000000000000000000000000000000003, 18),
        ('USDY', 'mantle',      0x5be26527e817998a7206475496fde1e68957c5a6, 18),
        ('FDUSD','bnb',         0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

labeled AS (
    SELECT blockchain, address, name, category
    FROM labels.addresses
    WHERE blockchain IN (
        'ethereum','bnb','polygon','arbitrum','optimism','base','avalanche_c',
        'gnosis','fantom','celo','zksync','linea','scroll','mantle','blast','mode','zkevm'
    )
)

SELECT
    t.block_time AS "Time", t.blockchain AS "Chain", s.symbol AS "Token",
    CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) AS "Amount ($)",
    CASE
        WHEN t."from" = 0x0000000000000000000000000000000000000000 THEN 'Mint'
        WHEN t.to IN (0x0000000000000000000000000000000000000000, 0x000000000000000000000000000000000000dead) THEN 'Burn'
        WHEN lr.category = 'cex' THEN 'CEX Deposit'
        WHEN ls.category = 'cex' THEN 'CEX Withdrawal'
        WHEN lr.category = 'bridge' OR ls.category = 'bridge' THEN 'Bridge'
        WHEN lr.category = 'dex' OR ls.category = 'dex' THEN 'DEX'
        ELSE 'Transfer'
    END AS "Category",
    COALESCE(ls.name, 'Unknown') AS "From",
    COALESCE(lr.name, 'Unknown') AS "To",
    t.tx_hash AS "Tx Hash",
    CASE
        WHEN CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) >= 50000000 THEN 'MEGA'
        WHEN CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) >= 10000000 THEN 'WHALE'
        WHEN CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) >= 1000000  THEN 'LARGE'
        ELSE 'MEDIUM'
    END AS "Size"
FROM tokens.transfers t
INNER JOIN stablecoins s ON t.blockchain = s.blockchain AND t.contract_address = s.contract_address
LEFT JOIN labeled ls ON t.blockchain = ls.blockchain AND t."from" = ls.address
LEFT JOIN labeled lr ON t.blockchain = lr.blockchain AND t.to = lr.address
WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
    AND CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals) >= CAST('{{min_amount}}' AS DOUBLE)
ORDER BY "Amount ($)" DESC
LIMIT 500
