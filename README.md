# UpdatePortfolio
Updates, calculates and plots investment portfolio over time

The Stocks folder contains programs and data that deal with Shares and ETFs listed on a Stock Exchange
PrintPortfolioGrowth.R calls the functions in the other R files to 
* retrieve and store latest data (UpdatePortfolio.R), 
* calculate portfolio growth (CalculatePortfolioReturn.R) and 
* plot portfolio growth (PlotPortfolioValue.R)

It can be invoked from the R shell by
```> setwd("/path/to/dir/UpdatePortfolio")```
```> source("PrintPortfolioGrowth.R)```

The updatePortfolio() function queries the Yahoo Finance API to get the latest share prices and
updates files with 
* the latest stock holdings (ShareQuantityHistory.csv), 
* share price (ShareQuantityHistory.csv), 
* share value (ShareValueHistory.csv) and
* portfolio value (PortfolioValueHistory.csv)

It uses the stock ticker symbols found in ShareQuantityHistory.csv (column name "Share_Symol") to build the portfolio.

The Yahoo Finance API uses stock ticker symbols which can be [looked up here] (https://in.finance.yahoo.com/lookup "Yahoo Stock Code Lookup").
The Yahoo Finance API used is available [here] (http://finance.yahoo.com/webservice/v1/symbols/<stock_symbol>/quote "Yahoo Finance API")

Note: Replace ```<stock_symbol>``` with the appropriate stock symbol from the Yahoo Stock Code Lookup. Example stock codes are
* [AAPL] (http://finance.yahoo.com/webservice/v1/symbols/AAPL/quote "Apple Inc.") - Apple Inc.
* [TCS.NS] (http://finance.yahoo.com/webservice/v1/symbols/TCS.NS/quote "TCS NSE") - TCS on NSE
* [TCS.BO] (http://finance.yahoo.com/webservice/v1/symbols/TCS.BO/quote "TCS BSE") - TCS on BSE
