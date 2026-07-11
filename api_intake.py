# Databricks notebook source
import requests
import pandas as pd
import time

# COMMAND ----------

apikey = 'CUOA9L2NLK5UZ5ZF'
apikey1 = 'APSJWAEMFV42UC1C'
url = 'https://www.alphavantage.co/query'

# COMMAND ----------

# Call Alphavantage API in a loop, accounting for 1 request per second limit
symbols = ["AAPL", "MSFT", "NVDA", "AMZN", "META",
    "GOOGL", "GOOG", "TSLA", "AVGO", "COST",
    "NFLX", "AMD", "PEP", "CSCO", "ADBE",
    "LIN", "QCOM", "TMUS", "TXN", "INTU",
    "AMGN", "INTC", "HON", "AMAT"]
df_list = []
for symbol in symbols:
    params = {
          "function": 'TIME_SERIES_DAILY',
          "symbol": symbol,
          "outputsize":'compact', # compact output means last 100 days, instead of full output of many years
          "apikey": apikey1}
    response = requests.get(url,params=params).json()
    # save response to pandas data frame
    # account for possible API error messages
    try:
        df = pd.DataFrame(response['Time Series (Daily)']).T
        df['Stock'] = symbol
        df_list.append(df)
    except KeyError as e:
        print(e)
        print(response)



    time.sleep(1.5)

# COMMAND ----------

all_together = pd.concat(df_list)
all_together = all_together.sort_index(ascending=False).reset_index(names='Date')

# rename columns to clean format
all_together.rename(columns={'Date':'date', '1. open':'open', '2. high':'high', '3. low':'low', '4. close':'close', '5. volume':'volume','Stock':'stock'}, inplace=True)

# COMMAND ----------

all_together

# COMMAND ----------

# write to pyspark data frame and save to Databricks catalog
spark_df = spark.createDataFrame(all_together)
spark_df.write \
    .mode("overwrite") \
    .saveAsTable("finance_elt.raw_data.bronze_table")