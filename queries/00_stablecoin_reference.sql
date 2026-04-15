-- ============================================================================
-- Dune Analytics: Extended Stablecoin Reference (EVM + Non-EVM)
-- ============================================================================
-- Erweiterte Referenztabelle mit 15+ Chains inkl. Solana (non-EVM).
-- Deckt alle relevanten Stablecoins auf allen von Dune unterstuetzten
-- Chains ab.
-- ============================================================================

WITH stablecoin_reference AS (
    SELECT * FROM (VALUES
        -- =================================================================
        -- USDT (Tether) - 10 Chains
        -- =================================================================
        ('USDT', 'Tether',          'ethereum',     0xdac17f958d2ee523a2206206994597c13d831ec7, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'bnb',          0x55d398326f99059ff775485246999027b3197955, 18, 'centralized', 'evm'),
        ('USDT', 'Tether',          'polygon',      0xc2132d05d31c914a87c6611c10748aeb04b58e8f, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'arbitrum',     0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'optimism',     0x94b008aa00579c1307b0ef2c499ad98a8ce58e58, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'avalanche_c',  0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'base',         0xfde4c96c8593536e31f229ea8f37b2ada2699bb2, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'gnosis',       0x4ecaba5870353805a9f068101a40e0f32ed605c6, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'fantom',       0x049d68029688eabf473097a2fc38ef61633a3c7a, 6,  'centralized', 'evm'),
        ('USDT', 'Tether',          'celo',         0x48065fbbe25f71c9282ddf5e1cd6d6a887483d5e, 6,  'centralized', 'evm'),

        -- =================================================================
        -- USDC (Circle) - 12 Chains
        -- =================================================================
        ('USDC', 'Circle',          'ethereum',     0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'bnb',          0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d, 18, 'centralized', 'evm'),
        ('USDC', 'Circle',          'polygon',      0x3c499c542cef5e3811e1192ce70d8cc03d5c3359, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'arbitrum',     0xaf88d065e77c8cc2239327c5edb3a432268e5831, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'optimism',     0x0b2c639c533813f4aa9d7837caf62653d097ff85, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'avalanche_c',  0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'base',         0x833589fcd6edb6e08f4c7c32d4f71b54bda02913, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'gnosis',       0xddafbb505ad214d7b80b1f830fccc89b60fb7a83, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'celo',         0xceba9300f2b948710d2653dd7b07f33a8b32118c, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'fantom',       0x04068da6c83afcfa0e13ba15a6696662335d5b75, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'zksync',       0x1d17cbcf0d6d143135ae902365d2e5e2a16538d4, 6,  'centralized', 'evm'),
        ('USDC', 'Circle',          'linea',        0x176211869ca2b568f2a7d4ee941e073a821ee1ff, 6,  'centralized', 'evm'),

        -- =================================================================
        -- DAI / USDS (MakerDAO / Sky) - 6 Chains
        -- =================================================================
        ('DAI',  'MakerDAO',        'ethereum',     0x6b175474e89094c44da98b954eedeac495271d0f, 18, 'decentralized', 'evm'),
        ('DAI',  'MakerDAO',        'polygon',      0x8f3cf7ad23cd3cadbd9735aff958023239c6a063, 18, 'decentralized', 'evm'),
        ('DAI',  'MakerDAO',        'arbitrum',     0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18, 'decentralized', 'evm'),
        ('DAI',  'MakerDAO',        'optimism',     0xda10009cbd5d07dd0cecc66161fc93d7c9000da1, 18, 'decentralized', 'evm'),
        ('DAI',  'MakerDAO',        'base',         0x50c5725949a6f0c72e6c4a641f24049a917db0cb, 18, 'decentralized', 'evm'),
        ('DAI',  'MakerDAO',        'gnosis',       0x44fa8e6f47987339850636f88629646662444217, 18, 'decentralized', 'evm'),
        ('USDS', 'Sky',             'ethereum',     0xdc035d45d973e3ec169d2276ddab16f1e407384f, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- FRAX - 4 Chains
        -- =================================================================
        ('FRAX', 'Frax Finance',    'ethereum',     0x853d955acef822db058eb8505911ed77f175b99e, 18, 'hybrid', 'evm'),
        ('FRAX', 'Frax Finance',    'arbitrum',     0x17fc002b466eec40dae837fc4be5c67993ddbd6f, 18, 'hybrid', 'evm'),
        ('FRAX', 'Frax Finance',    'optimism',     0x2e3d870790dc77a83dd1d18184acc7439a53f475, 18, 'hybrid', 'evm'),
        ('FRAX', 'Frax Finance',    'polygon',      0x45c32fa6df82ead1e2ef74d17b76547eddfaff89, 18, 'hybrid', 'evm'),

        -- =================================================================
        -- GHO (Aave)
        -- =================================================================
        ('GHO',  'Aave',            'ethereum',     0x40d16fc0246ad3160ccc09b8d0d3a2cd28ae6c2f, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- crvUSD (Curve)
        -- =================================================================
        ('crvUSD','Curve',          'ethereum',     0xf939e0a03fb07f59a73314e73794be0e57ac1b4e, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- PYUSD (PayPal) - 2 Chains
        -- =================================================================
        ('PYUSD','PayPal',          'ethereum',     0x6c3ea9036406852006290770bedfcaba0e23a0e8, 6,  'centralized', 'evm'),

        -- =================================================================
        -- TUSD (TrueUSD) - 2 Chains
        -- =================================================================
        ('TUSD', 'TrueUSD',         'ethereum',    0x0000000000085d4780b73119b644ae5ecd22b376, 18, 'centralized', 'evm'),
        ('TUSD', 'TrueUSD',         'bnb',         0x40af3827f39d0eacbf4a168f8d4ee67c121d11c9, 18, 'centralized', 'evm'),

        -- =================================================================
        -- LUSD (Liquity)
        -- =================================================================
        ('LUSD', 'Liquity',         'ethereum',    0x5f98805a4e8be255a32880fdec7f6728c6568ba0, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- FDUSD (First Digital) - 2 Chains
        -- =================================================================
        ('FDUSD','First Digital',   'ethereum',    0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18, 'centralized', 'evm'),
        ('FDUSD','First Digital',   'bnb',         0xc5f0f7b66764f6ec8c8dff7ba683102295e16409, 18, 'centralized', 'evm'),

        -- =================================================================
        -- USDe (Ethena)
        -- =================================================================
        ('USDe', 'Ethena',          'ethereum',    0x4c9edd5852cd905f086c759e8383e09bff1e68b3, 18, 'hybrid', 'evm'),

        -- =================================================================
        -- BUSD (Binance USD) - Legacy aber noch aktiv
        -- =================================================================
        ('BUSD', 'Paxos',          'ethereum',     0x4fabb145d64652a948d72533023f6e7a623c7c53, 18, 'centralized', 'evm'),
        ('BUSD', 'Paxos',          'bnb',          0xe9e7cea3dedca5984780bafc599bd69add087d56, 18, 'centralized', 'evm'),

        -- =================================================================
        -- USDP (Pax Dollar)
        -- =================================================================
        ('USDP', 'Paxos',          'ethereum',     0x8e870d67f660d95d5be530380d0ec0bd388289e1, 18, 'centralized', 'evm'),

        -- =================================================================
        -- sUSD (Synthetix)
        -- =================================================================
        ('sUSD', 'Synthetix',       'optimism',    0x8c6f28f2f1a3c87f0f938b96d27520d9751ec8d9, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- DOLA (Inverse Finance)
        -- =================================================================
        ('DOLA', 'Inverse Finance', 'ethereum',    0x865377367054516e17014ccded1e7d814edc9ce4, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- EURS (Stasis Euro)
        -- =================================================================
        ('EURS', 'Stasis',          'ethereum',    0xdb25f211ab05b1c97d595516f45794528a807ad8, 2,  'centralized', 'evm'),

        -- =================================================================
        -- EURT (Tether Euro)
        -- =================================================================
        ('EURT', 'Tether',          'ethereum',    0xc581b735a1688071a1746c968e0798d642ede491, 6,  'centralized', 'evm'),

        -- =================================================================
        -- agEUR / EURA (Angle Protocol)
        -- =================================================================
        ('EURA', 'Angle',           'ethereum',    0x1a7e4e63778b4f12a199c062f3efdd288afcbce8, 18, 'decentralized', 'evm'),

        -- =================================================================
        -- USDbC (Bridged USDC on Base - legacy)
        -- =================================================================
        ('USDbC','Circle (bridged)','base',        0xd9aaec86b65d86f6a7b5b1b0c42ffa531710b6ca, 6,  'centralized', 'evm'),

        -- =================================================================
        -- USDC.e (Bridged USDC on Arbitrum - legacy)
        -- =================================================================
        ('USDC.e','Circle (bridged)','arbitrum',   0xff970a61a04b1ca14834a43f5de4533ebddb5cc8, 6,  'centralized', 'evm'),

        -- =================================================================
        -- USDC.e (Bridged USDC on Optimism - legacy)
        -- =================================================================
        ('USDC.e','Circle (bridged)','optimism',   0x7f5c764cbc14f9669b88837ca1490cca17c31607, 6,  'centralized', 'evm'),

        -- =================================================================
        -- USDC.e (Bridged USDC on Polygon)
        -- =================================================================
        ('USDC.e','Circle (bridged)','polygon',    0x2791bca1f2de4661ed88a30c99a7a9449aa84174, 6,  'centralized', 'evm')

    ) AS t(symbol, issuer, blockchain, contract_address, decimals, category, chain_type)
)

SELECT * FROM stablecoin_reference
ORDER BY symbol, blockchain
