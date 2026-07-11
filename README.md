# Databricks-SQL-ETL-Pipeline

Automated ETL Pipeline in Databricks, processing 3,000 records in less than two minutes.

Stock Market Dashboard provides one-stop shop for analyzing the most important metrics for top US stocks!

This project takes raw data obtained from API calls to the Alphavantage stock market API and transforms it into business-ready analytics and reporting following the industry-standard Medallion architecture: Bronze-Silver-Gold.

<img src="/assets/Screenshot 2026-07-10 195611.png" width="600">

The Medallion Architecture Data Flow:

<img src="/assets/Untitled Diagram.drawio.png" width="500">

<br />
<br>

The bronze table holds raw stock market data pulled directly from the Alphavantage API.

<img src="/assets/Screenshot 2026-07-10 220354.png" width="500">

The silver table holds data cleaned with SQL CAST, and WHERE statements, 

There are 8 variables in the silver table: Date, Open, High, Low, Close, Stock, and Volume.

Open, High, Low, and Close are daily stock market measures from which financial analytics are derived.

Open, High, Low, and Close are of the data type "double," since they need decimals. Stock is "string," since it is text only. Date is "date," and Volume is "bigint," since it doesn't need decimal places.

<img src="/assets/Screenshot 2026-07-10 220547.png" width="500">

The gold table holds metrics calculated from the silver table. These were done primarily with SQL WINDOW functions, utilizing PARTITION BY, ORDER BY, LAG(), and other functions to calculate moving averages and other aggregations.

<img src="/assets/Screenshot 2026-07-10 221618.png" width="300">

Lastly, my Stock Market Dashboard updates automatically every morning, providing a one-stop shop for critical stock decisions made by investment professionals.

If you wish to log into a Databricks account to view the dashboard, click [here](https://dbc-03155024-2f3c.cloud.databricks.com/dashboardsv3/01f1766041841a2c88b736fc39bb3276/published?o=7474660638127554&f_d8b0b242%7Ec3f70f95.s=META).

Otherwise, a screenshot below shows the dashboard. Critical metrics like moving averages, stock price, volatility, and volume are included to provide a complete picture into each stock's health.
A selector is used to select different stocks to examine when desired.

<img src="/assets/Screenshot 2026-07-11 160830.png" width="500">

