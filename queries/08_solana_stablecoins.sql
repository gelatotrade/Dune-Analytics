-- ============================================================================
-- Dune Analytics: Solana Stablecoin Transfer Tracking
-- ============================================================================
-- Separater Query fuer Solana (non-EVM). Nutzt die Solana-spezifischen
-- Tabellen auf Dune (spl_token / tokens_solana).
--
-- Solana hat eine andere Datenstruktur als EVM-Chains:
--   - SPL Token Transfers statt ERC20
--   - Base58-Adressen statt hex
--   - Token Accounts statt direkte Wallet-Adressen
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '7 days', '30 days'
-- ============================================================================

WITH solana_stablecoins AS (
    SELECT * FROM (VALUES
        -- Token Mint Addresses auf Solana (Base58)
        ('USDC', 'Circle',       'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',  6,  'centralized'),
        ('USDT', 'Tether',       'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',   6,  'centralized'),
        ('PYUSD','PayPal',       '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',  6,  'centralized'),
        ('USDS', 'Sky',          'USDSwr9ApdHk5bvJKMjVo5ibcMV3sMRQ7FShFDRkTXr',    6,  'decentralized'),
        ('DAI',  'MakerDAO',     'EjmyN6qEC1Tf1JxiG1ae7UTJhUxSwk1TCWNWqxWV4J6o',  8,  'decentralized')
    ) AS t(symbol, issuer, token_mint_address, decimals, category)
),

-- Solana SPL Token Transfers via tokens_solana.transfers
solana_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time)   AS day,
        t.block_time,
        t.tx_id,
        s.symbol,
        s.issuer,
        s.category,
        t.from_owner                       AS sender,
        t.to_owner                         AS receiver,
        t.amount                           AS amount,
        CASE
            WHEN t.from_owner = '11111111111111111111111111111111' THEN 'mint'
            WHEN t.to_owner = '11111111111111111111111111111111'   THEN 'burn'
            ELSE 'transfer'
        END AS transfer_type
    FROM tokens_solana.transfers t
    INNER JOIN solana_stablecoins s
        ON t.token_mint_address = s.token_mint_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount > 0
),

-- Taegliche Aggregation
daily_solana AS (
    SELECT
        day,
        symbol,
        transfer_type,
        SUM(amount)                   AS daily_volume,
        COUNT(DISTINCT tx_id)         AS tx_count,
        COUNT(*)                      AS transfer_count,
        COUNT(DISTINCT sender)        AS unique_senders,
        COUNT(DISTINCT receiver)      AS unique_receivers,
        AVG(amount)                   AS avg_transfer_size,
        MAX(amount)                   AS max_transfer_size
    FROM solana_transfers
    GROUP BY day, symbol, transfer_type
)

SELECT
    day,
    'solana' AS blockchain,
    'non-evm' AS chain_type,
    symbol,
    transfer_type,
    daily_volume,
    tx_count,
    transfer_count,
    unique_senders,
    unique_receivers,
    avg_transfer_size,
    max_transfer_size,
    -- 7-Tage gleitender Durchschnitt
    AVG(daily_volume) OVER (
        PARTITION BY symbol, transfer_type
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma
FROM daily_solana
ORDER BY day DESC, daily_volume DESC
