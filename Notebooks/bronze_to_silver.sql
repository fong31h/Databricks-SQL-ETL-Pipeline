-- Databricks notebook source
-- Create new schema for silver table
CREATE SCHEMA IF NOT EXISTS finance_elt.cleaned_data;
-- Create silver table
CREATE OR REPLACE TABLE finance_elt.cleaned_data.silver_table AS
-- Enforce data types and formatting
SELECT DISTINCT
    CAST(date AS DATE) AS date,
    CAST(open AS DOUBLE) AS open,
    CAST(high AS DOUBLE) AS high,
    CAST(low AS DOUBLE) AS low,
    CAST(close AS DOUBLE) AS close,
    CAST(volume AS BIGINT) AS volume,
    UPPER(stock) AS stock

FROM finance_elt.raw_data.bronze_table
-- Filter out invalid records
WHERE
    date IS NOT NULL
    AND open IS NOT NULL
    AND high IS NOT NULL
    AND low IS NOT NULL
    AND close IS NOT NULL
    AND volume IS NOT NULL
    AND stock IS NOT NULL

    AND CAST(open as DOUBLE) > 0
    AND CAST(high AS DOUBLE) > 0
    AND CAST(low AS DOUBLE) > 0
    AND CAST(close AS DOUBLE) > 0

    AND CAST(volume as BIGINT) >= 0

    AND high >= open
    AND high >= close
    AND high >= low

    AND low <= open
    AND low <= close
    AND low <= high

    AND CAST(date AS DATE) <= CURRENT_DATE()
;

-- COMMAND ----------

-- DBTITLE 1,Create quarantine table for rejected records
-- Create quarantine table for invalid records
CREATE OR REPLACE TABLE finance_elt.cleaned_data.quarantine_table AS

SELECT 
    date,
    open,
    high,
    low,
    close,
    volume,
    stock,
    CASE 
        WHEN date IS NULL THEN 'NULL_DATE'
        WHEN open IS NULL THEN 'NULL_OPEN'
        WHEN high IS NULL THEN 'NULL_HIGH'
        WHEN low IS NULL THEN 'NULL_LOW'
        WHEN close IS NULL THEN 'NULL_CLOSE'
        WHEN volume IS NULL THEN 'NULL_VOLUME'
        WHEN stock IS NULL THEN 'NULL_STOCK'
        WHEN TRY_CAST(open AS DOUBLE) IS NULL THEN 'INVALID_OPEN'
        WHEN TRY_CAST(high AS DOUBLE) IS NULL THEN 'INVALID_HIGH'
        WHEN TRY_CAST(low AS DOUBLE) IS NULL THEN 'INVALID_LOW'
        WHEN TRY_CAST(close AS DOUBLE) IS NULL THEN 'INVALID_CLOSE'
        WHEN TRY_CAST(volume AS BIGINT) IS NULL THEN 'INVALID_VOLUME'
        WHEN TRY_CAST(date AS DATE) IS NULL THEN 'INVALID_DATE'
        WHEN CAST(open AS DOUBLE) <= 0 THEN 'OPEN_NOT_POSITIVE'
        WHEN CAST(high AS DOUBLE) <= 0 THEN 'HIGH_NOT_POSITIVE'
        WHEN CAST(low AS DOUBLE) <= 0 THEN 'LOW_NOT_POSITIVE'
        WHEN CAST(close AS DOUBLE) <= 0 THEN 'CLOSE_NOT_POSITIVE'
        WHEN CAST(volume AS BIGINT) < 0 THEN 'VOLUME_NEGATIVE'
        WHEN CAST(high AS DOUBLE) < CAST(open AS DOUBLE) THEN 'HIGH_LESS_THAN_OPEN'
        WHEN CAST(high AS DOUBLE) < CAST(close AS DOUBLE) THEN 'HIGH_LESS_THAN_CLOSE'
        WHEN CAST(high AS DOUBLE) < CAST(low AS DOUBLE) THEN 'HIGH_LESS_THAN_LOW'
        WHEN CAST(low AS DOUBLE) > CAST(open AS DOUBLE) THEN 'LOW_GREATER_THAN_OPEN'
        WHEN CAST(low AS DOUBLE) > CAST(close AS DOUBLE) THEN 'LOW_GREATER_THAN_CLOSE'
        WHEN CAST(low AS DOUBLE) > CAST(high AS DOUBLE) THEN 'LOW_GREATER_THAN_HIGH'
        WHEN CAST(date AS DATE) > CURRENT_DATE() THEN 'FUTURE_DATE'
        ELSE 'UNKNOWN'
    END AS rejection_reason,
    CURRENT_TIMESTAMP() AS quarantined_at

FROM finance_elt.raw_data.bronze_table

WHERE NOT (
    date IS NOT NULL
    AND open IS NOT NULL
    AND high IS NOT NULL
    AND low IS NOT NULL
    AND close IS NOT NULL
    AND volume IS NOT NULL
    AND stock IS NOT NULL
    AND TRY_CAST(open AS DOUBLE) IS NOT NULL
    AND TRY_CAST(high AS DOUBLE) IS NOT NULL
    AND TRY_CAST(low AS DOUBLE) IS NOT NULL
    AND TRY_CAST(close AS DOUBLE) IS NOT NULL
    AND TRY_CAST(volume AS BIGINT) IS NOT NULL
    AND TRY_CAST(date AS DATE) IS NOT NULL
    AND CAST(open AS DOUBLE) > 0
    AND CAST(high AS DOUBLE) > 0
    AND CAST(low AS DOUBLE) > 0
    AND CAST(close AS DOUBLE) > 0
    AND CAST(volume AS BIGINT) >= 0
    AND CAST(high AS DOUBLE) >= CAST(open AS DOUBLE)
    AND CAST(high AS DOUBLE) >= CAST(close AS DOUBLE)
    AND CAST(high AS DOUBLE) >= CAST(low AS DOUBLE)
    AND CAST(low AS DOUBLE) <= CAST(open AS DOUBLE)
    AND CAST(low AS DOUBLE) <= CAST(close AS DOUBLE)
    AND CAST(low AS DOUBLE) <= CAST(high AS DOUBLE)
    AND CAST(date AS DATE) <= CURRENT_DATE()
);
