-- ============================================================================
-- Dune Analytics: Cosmos IBC Stablecoin Flow Template
-- ============================================================================
-- HINWEIS: Reine Cosmos-Chains (Injective, Celestia, Cosmos Hub/ATOM,
-- Osmosis, Noble) sind NICHT direkt auf Dune verfuegbar.
--
-- Diese Datei dient als:
--   1. Dokumentation der wichtigsten Cosmos-Stablecoins
--   2. Template fuer wenn Dune Cosmos-Support hinzufuegt
--   3. Referenz fuer alternative Datenquellen
--
-- ============================================================================
-- COSMOS STABLECOIN REFERENZ
-- ============================================================================
--
-- == Noble Chain (USDC native issuance auf Cosmos) ==
-- USDC auf Noble: Native Circle USDC fuer das Cosmos Ecosystem
-- Noble ist die offizielle USDC Issuance-Chain im Cosmos
-- IBC Denom: ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4
--
-- == Osmosis (groesster Cosmos DEX) ==
-- USDC.axl (Axelar bridged): ibc/D189335C6E4A68B513C10AB227BF1C1D38C746766278BA3EEB4FB14124F1D858
-- USDC (Noble native):        ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4
-- USDT (Kava bridged):        ibc/4ABBEF4C8926DDDB320AE5188CFD63267ABBCEFC0583E4AE05D6E5AA2401DDAB
-- DAI (Axelar bridged):       ibc/0CD3A0285E1341859B5E86B6AB7682F023D03E97607CCC1DC95706411D866DF7
--
-- == Injective ==
-- USDT: peggy0xdAC17F958D2ee523a2206206994597C13D831ec7
-- USDC: peggy0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
-- USDe: factory/inj...
--
-- == Celestia (TIA) ==
-- Keine nativen Stablecoins, aber USDC via IBC von Noble
--
-- == Cosmos Hub (ATOM) ==
-- USDC via Noble IBC: ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4
--
-- == Sei (Cosmos-Seite, nicht EVM) ==
-- USDC: factory/sei1e3gttzq5e5k49f9f5gzvrl0rltlav65xu6p9xc0aj7e84lantdjqp7cnmu/usdc
--
-- == Terra (LUNA) ==
-- axlUSDC, axlUSDT via Axelar Bridge
--
-- ============================================================================
-- ALTERNATIVE DATENQUELLEN FUER COSMOS
-- ============================================================================
--
-- 1. Numia (numia.xyz) - Cosmos-spezifische Analytik
-- 2. Flipside Crypto - Hat Cosmos/Osmosis Daten
-- 3. SubQuery / SubGraph - Indexer fuer IBC Daten
-- 4. Mintscan API - Block Explorer mit Transfer-Daten
-- 5. Imperator.co - Osmosis-spezifische Analytik
--
-- ============================================================================
-- TEMPLATE: Wenn Dune Cosmos-Support hinzufuegt
-- ============================================================================

-- Beispiel-Query (aktivieren wenn Cosmos auf Dune verfuegbar):
/*
WITH cosmos_stablecoins AS (
    SELECT * FROM (VALUES
        ('USDC',  'Noble',     'noble',     'uusdc',                                                                         6),
        ('USDC',  'Noble/IBC', 'osmosis',   'ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4',          6),
        ('USDC',  'Noble/IBC', 'injective', 'peggy0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',                               6),
        ('USDC',  'Noble/IBC', 'cosmoshub', 'ibc/498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4',          6),
        ('USDT',  'Kava/IBC',  'osmosis',   'ibc/4ABBEF4C8926DDDB320AE5188CFD63267ABBCEFC0583E4AE05D6E5AA2401DDAB',          6),
        ('USDT',  'Tether',    'injective', 'peggy0xdAC17F958D2ee523a2206206994597C13D831ec7',                                6)
    ) AS t(symbol, issuer, blockchain, denom, decimals)
)

SELECT
    DATE_TRUNC('day', block_time) AS day,
    blockchain,
    symbol,
    SUM(amount) AS daily_volume,
    COUNT(DISTINCT tx_hash) AS tx_count
FROM cosmos.transfers  -- Hypothetische Dune-Tabelle
INNER JOIN cosmos_stablecoins s
    ON transfers.blockchain = s.blockchain
    AND transfers.denom = s.denom
WHERE block_time >= NOW() - INTERVAL '{{period}}'
GROUP BY 1, 2, 3
ORDER BY day DESC
*/

-- Placeholder Query damit Dune nicht leer zurueckgibt
SELECT
    'cosmos_ecosystem' AS category,
    chain AS blockchain,
    stablecoin AS symbol,
    note
FROM (VALUES
    ('Noble',      'USDC', 'Native USDC issuance chain fuer Cosmos (Circle)'),
    ('Osmosis',    'USDC', 'Groesster Cosmos DEX, USDC via Noble IBC'),
    ('Osmosis',    'USDT', 'USDT via Kava IBC bridge'),
    ('Injective',  'USDT', 'peggy-bridged USDT, hohe DeFi Aktivitaet'),
    ('Injective',  'USDC', 'peggy-bridged USDC'),
    ('Injective',  'USDe', 'Ethena USDe via factory contract'),
    ('Cosmos Hub', 'USDC', 'USDC via Noble IBC'),
    ('Celestia',   'USDC', 'USDC via Noble IBC (geringes Volumen)'),
    ('Sei',        'USDC', 'Native + IBC USDC (EVM-Seite in Query 10)'),
    ('Terra',      'axlUSDC', 'Axelar-bridged USDC'),
    ('Kava',       'USDT', 'Groesser USDT Markt (EVM-Seite in Query 10)')
) AS t(chain, stablecoin, note)
