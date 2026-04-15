-- ============================================================================
-- Dune Analytics: Cosmos-Adjacent & EVM-Compatible Chain Stablecoins
-- ============================================================================
-- Chains mit Cosmos/IBC Verbindung die EVM-kompatibel sind und auf
-- Dune verfuegbar sein koennen. Fuer reine Cosmos-Chains (Injective,
-- Celestia, ATOM Hub) siehe 11_cosmos_ibc_tracking.sql.
--
-- Unterstuetzte Chains hier:
--   - Sei (Cosmos+EVM dual, parallelisiert)
--   - Kava (Cosmos+EVM, grosser USDT Markt)
--   - Canto (Cosmos+EVM, hat eigenen Stablecoin NOTE)
--
-- HINWEIS: Verfuegbarkeit dieser Chains auf Dune kann variieren.
-- Pruefe auf dune.com ob die jeweilige Chain unterstuetzt wird.
--
-- Parameter: {{period}}
-- ============================================================================

-- =====================================================================
-- SEI Network (EVM-kompatibel)
-- Sei hat parallele EVM + Cosmos Execution
-- =====================================================================
WITH sei_stablecoins AS (
    SELECT * FROM (VALUES
        ('USDC', 'sei', 0x3894085ef7ff0f0aedf52e2a2704928d1ec074f1, 6),
        ('USDT', 'sei', 0xb75d0b03c06a926e488e2659df1a861f860bd3d1, 6)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

sei_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        'sei' AS blockchain,
        s.symbol,
        SUM(CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)) AS daily_volume,
        COUNT(DISTINCT t.tx_hash) AS tx_count,
        COUNT(DISTINCT t."from") AS unique_senders,
        COUNT(DISTINCT t.to) AS unique_receivers
    FROM tokens.transfers t
    INNER JOIN sei_stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
    GROUP BY DATE_TRUNC('day', t.block_time), s.symbol
),

-- =====================================================================
-- KAVA Network (EVM-kompatibel, grosser USDT Markt)
-- =====================================================================
kava_stablecoins AS (
    SELECT * FROM (VALUES
        ('USDT', 'kava', 0x919c1c267bc06a7039e03fad2b0f3564f4461427, 6)
    ) AS t(symbol, blockchain, contract_address, decimals)
),

kava_transfers AS (
    SELECT
        DATE_TRUNC('day', t.block_time) AS day,
        'kava' AS blockchain,
        s.symbol,
        SUM(CAST(t.amount_raw AS DOUBLE) / POWER(10, s.decimals)) AS daily_volume,
        COUNT(DISTINCT t.tx_hash) AS tx_count,
        COUNT(DISTINCT t."from") AS unique_senders,
        COUNT(DISTINCT t.to) AS unique_receivers
    FROM tokens.transfers t
    INNER JOIN kava_stablecoins s
        ON t.blockchain = s.blockchain
        AND t.contract_address = s.contract_address
    WHERE t.block_time >= NOW() - INTERVAL '{{period}}'
        AND t.amount_raw > 0
    GROUP BY DATE_TRUNC('day', t.block_time), s.symbol
),

-- Kombinierte Ergebnisse
combined AS (
    SELECT * FROM sei_transfers
    UNION ALL
    SELECT * FROM kava_transfers
)

SELECT
    day,
    blockchain,
    'cosmos-evm' AS ecosystem,
    symbol,
    daily_volume,
    tx_count,
    unique_senders,
    unique_receivers,
    AVG(daily_volume) OVER (
        PARTITION BY blockchain, symbol ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma
FROM combined
ORDER BY day DESC, daily_volume DESC
