-- ============================================================================
-- Dune Analytics: Stablecoin Reference Table
-- ============================================================================
-- Zentrale Referenztabelle mit allen getrackten Stablecoins und ihren
-- Contract-Adressen auf verschiedenen Chains.
-- Verwendung: Als CTE in anderen Queries oder als eigenstaendige Dune-Query
-- gespeichert und per query_id referenziert.
-- ============================================================================

WITH stablecoin_reference AS (
    SELECT * FROM (VALUES
        -- ===== USDT (Tether) =====
        ('USDT', 'Tether',          'ethereum',     0xdac17f958d2ee523a2206206994597c13d831ec7, 6,  'centralized'),
        ('USDT', 'Tether',          'bnb',          0x55d398326f99059ff775485246999027b3197955, 18, 'centralized'),
        ('USDT', 'Tether',          'polygon',      0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 6,  'centralized'),
        ('USDT', 'Tether',          'arbitrum',     0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9, 6,  'centralized'),
        ('USDT', 'Tether',          'optimism',     0x94b008aa00579c1307b0ef2c499ad98a8ce58e58, 6,  'centralized'),
        ('USDT', 'Tether',          'avalanche_c',  0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7, 6,  'centralized'),
        ('USDT', 'Tether',          'base',         0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6,  'centralized'),

        -- ===== USDC (Circle) =====
        ('USDC', 'Circle',          'ethereum',     0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6,  'centralized'),
        ('USDC', 'Circle',          'bnb',          0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18, 'centralized'),
        ('USDC', 'Circle',          'polygon',      0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6,  'centralized'),
        ('USDC', 'Circle',          'arbitrum',     0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6,  'centralized'),
        ('USDC', 'Circle',          'optimism',     0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6,  'centralized'),
        ('USDC', 'Circle',          'avalanche_c',  0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6,  'centralized'),
        ('USDC', 'Circle',          'base',         0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6,  'centralized'),

        -- ===== DAI / USDS (MakerDAO / Sky) =====
        ('DAI',  'MakerDAO',        'ethereum',     0x6b175474e89094c44da98b954eedeac495271d0f, 18, 'decentralized'),
        ('DAI',  'MakerDAO',        'polygon',      0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18, 'decentralized'),
        ('DAI',  'MakerDAO',        'arbitrum',     0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18, 'decentralized'),
        ('DAI',  'MakerDAO',        'optimism',     0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18, 'decentralized'),
        ('DAI',  'MakerDAO',        'base',         0x50c5725949a6f0c72e6c4a641f24049a917db0cb, 18, 'decentralized'),
        ('USDS', 'Sky',             'ethereum',     0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18, 'decentralized'),

        -- ===== FRAX =====
        ('FRAX', 'Frax Finance',    'ethereum',     0x853d955acef822db058eb8505911ed77f175b99e, 18, 'hybrid'),
        ('FRAX', 'Frax Finance',    'arbitrum',     0x17fc002b466eec40dae837fc4be5c67993ddbd6f, 18, 'hybrid'),
        ('FRAX', 'Frax Finance',    'optimism',     0x2e3d870790dc77a83dd1d18184acc7439a53f475, 18, 'hybrid'),

        -- ===== GHO (Aave) =====
        ('GHO',  'Aave',            'ethereum',     0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18, 'decentralized'),

        -- ===== crvUSD (Curve) =====
        ('crvUSD', 'Curve',         'ethereum',     0xf939e0a03fb07f59a73314e73794be0e57ac1b4e, 18, 'decentralized'),

        -- ===== PYUSD (PayPal) =====
        ('PYUSD', 'PayPal',         'ethereum',     0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6,  'centralized'),

        -- ===== TUSD =====
        ('TUSD', 'TrueUSD',         'ethereum',     0x0000000000085d4780b73119b644ae5ecd22b376, 18, 'centralized'),
        ('TUSD', 'TrueUSD',         'bnb',          0x40af3827f39d0eacbf4a168f8d4ee67c121d11c9, 18, 'centralized'),

        -- ===== LUSD (Liquity) =====
        ('LUSD', 'Liquity',         'ethereum',     0x5f98805a4e8be255a32880fdec7f6728c6568ba0, 18, 'decentralized'),

        -- ===== FDUSD (First Digital) =====
        ('FDUSD', 'First Digital',  'ethereum',     0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18, 'centralized'),
        ('FDUSD', 'First Digital',  'bnb',          0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18, 'centralized'),

        -- ===== USDe (Ethena) =====
        ('USDe', 'Ethena',          'ethereum',     0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18, 'hybrid')

    ) AS t(symbol, issuer, blockchain, contract_address, decimals, category)
)

SELECT
    symbol,
    issuer,
    blockchain,
    contract_address,
    decimals,
    category
FROM stablecoin_reference
ORDER BY symbol, blockchain
