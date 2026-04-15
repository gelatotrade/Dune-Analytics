-- ============================================================================
-- Dune Analytics: Tron Stablecoin Transfer Tracking
-- ============================================================================
-- Separater Query fuer Tron (non-EVM). Tron ist der groesste USDT-Markt
-- weltweit mit >50% aller USDT-Transfers.
--
-- Tron hat eine andere Datenstruktur als EVM:
--   - TRC20 Token Transfers statt ERC20
--   - Base58-Adressen (T...) statt 0x hex
--   - Eigene Tabellen auf Dune: tron.transactions, tron.logs
--
-- Parameter (Dune UI):
--   {{period}} - Zeitraum, z.B. '7 days', '30 days'
-- ============================================================================

WITH tron_stablecoins AS (
    SELECT * FROM (VALUES
        -- Tron Contract Addresses (Base58 / Hex)
        ('USDT', 'Tether',    0xa614f803b6fd780986a42c78ec9c7f77e6ded13c, 6,  'centralized'),  -- TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t
        ('USDC', 'Circle',    0x3487b63d30b5b2c87fb7ffa8bcfade38eaac1abe, 6,  'centralized'),  -- TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8
        ('USDD', 'Tron DAO',  0x94f24e992ca04b49c6f2a2753076ef8938ed4daa, 18, 'decentralized'), -- TPYmHEhy5n8TCEfYGqW2rPxsghSfzghPDn
        ('TUSD', 'TrueUSD',   0xcee5c050055cc2809e651d68fbd8f52f90c78f56, 18, 'centralized')   -- TUpMhErZL2fhh4sVNULAbNKLokS4GjC1F4
    ) AS t(symbol, issuer, contract_address, decimals, category)
),

-- Tron TRC20 Transfer Events (Topic0 = Transfer)
-- Dune Tron Tabelle: tron.logs fuer Event Logs
tron_transfers AS (
    SELECT
        DATE_TRUNC('day', l.block_time) AS day,
        l.block_time,
        l.tx_hash,
        s.symbol,
        s.issuer,
        s.category,
        BYTEARRAY_SUBSTRING(l.topic1, 13, 20) AS sender,
        BYTEARRAY_SUBSTRING(l.topic2, 13, 20) AS receiver,
        CAST(BYTEARRAY_TO_UINT256(l.data) AS DOUBLE) / POWER(10, s.decimals) AS amount,
        CASE
            WHEN l.topic1 = 0x0000000000000000000000000000000000000000000000000000000000000000
                THEN 'mint'
            WHEN l.topic2 = 0x0000000000000000000000000000000000000000000000000000000000000000
                THEN 'burn'
            ELSE 'transfer'
        END AS transfer_type
    FROM tron.logs l
    INNER JOIN tron_stablecoins s
        ON l.contract_address = s.contract_address
    WHERE l.block_time >= NOW() - INTERVAL '{{period}}'
        -- Transfer(address,address,uint256) event signature
        AND l.topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
        AND BYTEARRAY_TO_UINT256(l.data) > 0
),

-- Taegliche Aggregation
daily_tron AS (
    SELECT
        day,
        symbol,
        transfer_type,
        SUM(amount)                   AS daily_volume,
        COUNT(DISTINCT tx_hash)       AS tx_count,
        COUNT(*)                      AS transfer_count,
        COUNT(DISTINCT sender)        AS unique_senders,
        COUNT(DISTINCT receiver)      AS unique_receivers,
        AVG(amount)                   AS avg_transfer_size,
        MAX(amount)                   AS max_transfer_size,
        APPROX_PERCENTILE(amount, 0.5) AS median_transfer_size
    FROM tron_transfers
    GROUP BY day, symbol, transfer_type
)

SELECT
    day,
    'tron' AS blockchain,
    'non-evm' AS chain_type,
    symbol,
    transfer_type,
    daily_volume,
    tx_count,
    transfer_count,
    unique_senders,
    unique_receivers,
    avg_transfer_size,
    median_transfer_size,
    max_transfer_size,
    -- 7-Tage gleitender Durchschnitt
    AVG(daily_volume) OVER (
        PARTITION BY symbol, transfer_type
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS volume_7d_ma,
    -- Anteil am Gesamtvolumen
    daily_volume / NULLIF(
        SUM(daily_volume) OVER (PARTITION BY day),
        0
    ) * 100 AS market_share_pct
FROM daily_tron
ORDER BY day DESC, daily_volume DESC
