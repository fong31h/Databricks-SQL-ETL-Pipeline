-- Databricks notebook source
-- Create schema for gold table
CREATE SCHEMA IF NOT EXISTS finance_elt.analytics;

-- COMMAND ----------

-- Create gold table stock_metrics
CREATE OR REPLACE TABLE finance_elt.analytics.stock_metrics AS

WITH daily_returns AS (
  SELECT 
    date, 
    stock, 
    open, 
    close, 
    high, 
    low,
    volume,
    -- Use lag function to calculate close-close change
    ROUND(
      ((close - LAG(close) OVER (PARTITION BY stock ORDER BY date)) /
       LAG(close) OVER (PARTITION BY stock ORDER BY date)) * 100,
      2) AS daily_pct_change
  FROM finance_elt.cleaned_data.silver_table
)

SELECT 
  date, 
  stock, 
  open, 
  close, 
  high, 
  low,
  volume,
  daily_pct_change,
  -- use window function to calculate moving averages
  ROUND(
    AVG(close) OVER(PARTITION BY stock ORDER BY date
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
    2) AS three_day_moving_average,

  ROUND(
    AVG(close) OVER(PARTITION BY stock ORDER BY date
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),
    2) AS thirty_day_moving_average,

  ROUND(
    AVG(close) OVER(PARTITION BY stock ORDER BY date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
    2) AS seven_day_moving_average,
  -- use window function to calculate volatility
  ROUND(
    STDDEV(daily_pct_change) OVER(PARTITION BY stock ORDER BY date
      ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),
    2) AS volatility_30d,
  -- use window function to calculate moving 30-day return
  ROUND(SUM(daily_pct_change) OVER (
    PARTITION BY stock 
    ORDER BY date 
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
  ), 2) AS return_30d

FROM daily_returns;