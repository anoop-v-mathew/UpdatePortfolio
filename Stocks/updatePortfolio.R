library(RCurl)
library(XML)
library(dplyr)


# function updateFile()
#
# Updates a file with values in the column name passed to it.
# If data is already present for the column name, the column is updated, 
# if not, a new column is created for the column name passed in
#
# Args:
#   colName: Name of the column to update with values
#   colValues: The values to be updated in the column. The no. of items 
#              in the column should match the other columns in the file
#   csvFileToUpdate: The CSV file to be updated. The file will be read from and 
#                    written to in the current working directory  
#   
# Returns:
#   The data set with the data which was written to file
#
# Sample Usage:
#   > View(updateFile("01-Jan-2015", c(110.3, 2630.4), "SharePriceHistory.csv"))
#
# Pre-requisites:
#   dplyr package has to be installed already
#

updateFile <- function (colName, colValues, csvFileToUpdate) {
  dt <- read.csv(csvFileToUpdate, 
                 check.names = FALSE, # required to retain dates as column names
                 stringsAsFactors = FALSE)
  
  colNum <- ncol(dt)
  if(colnames(dt)[colNum] == colName) { 
    #file already contains data for current date
    dt[colNum] = colValues # update last column with latest data
  } else {
    # file does not contain any data for current date
    dt <- mutate(dt, newCol = colValues) #add a new column for current date
    oldColNames <- colnames(dt)
    newColNames <- oldColNames
    newColNames[colNum+1] <- colName
    colnames(dt) <- newColNames    
  }
  write.csv(dt, file=csvFileToUpdate, row.names = FALSE)
  
  return(dt)
}

# function updatePortfolio()
#
# Queries the Yahoo Finance API to get the latest share prices and
# updates files with the latest stock holdings, share price, share value and
# portfolio value. It uses the stock ticker symbols found in 
# ShareQuantityHistory.csv (column name "Share_Symol") to build the portfolio.
#
# It will use the stock holdings/quantities found in  the last column
# If data is already present for the date, the column is updated, if not, a 
# new column is created for the date
#
# The Yahoo Finance API uses stock ticker symbols which can be looked up 
# at the following URL - https://in.finance.yahoo.com/lookup
# The Yahoo Finance API used is available at 
#   http://finance.yahoo.com/webservice/v1/symbols/<stock_symbol>/quote
#
# Args:
#   dir: path to the directory containing the portfolio files
#        For e.g., "C:\\Downloads\\StockPortfolio\\"
#        It defaults to the current directory
#   useProxy: If T, will try to use a proxy to connect to the Internet
#             It defaults to F for False
#   proxyURL: URL for the Proxy Server, required if useProxy is T
#   proxyUser: Username for the Proxy Server login. Should be of the form
#              <domain>\\<username> if domain is applicable
#   proxyPwd: Password for the proxy server
#   proxyPort: Port used by the proxy server, defaults to 8080
#   writeToFiles: If T, the files for Share Quantity, Price, Value and 
#                 Portfolio Value will be updated. Defaults to T
#
# Returns:
#   The data set with the share portfolio snapshot, containing details of
#   Share Symbol, Share Name, Share Quantity, Date, Share Price and Share Value
#
# Sample Usage:
#   > View(updatePortfolio()) or
#   > View(updatePortfolio(UseProxy=T, 
#                          ProxyURL="proxy.company.com", 
#                          ProxyUser="domain\\username"
#                          ProxyPwd="password"
#                          ProxyPort="8080"
#                          WriteToFiles="T"))
#   > updatePortfolio(useProxy="T")
#
# Pre-requisites:
#   dplyr, RCurl and XML packages have to be installed already
#

updatePortfolio <- function (dir="./",
                             useProxy="F", 
                             proxyURL="proxy.company.com", 
                             proxyUser="domain\\username", 
                             proxyPwd="prompt", 
                             proxyPort=8080, 
                             writeToFiles="T") {
  
  # check if we need a proxy to connect to the Internet
  useProxy <-  eval(useProxy)
  
  # get the proxy password 
  # Note: unfortunately, in Windows, the password is echoed to the terminal
  if (useProxy) {

    if (proxyPwd == "prompt") {
      proxyPwd <- readline("Proxy Password :")
    }
    cat("\014")  # Clear the screen to remove the password
    
    opts <- list(
      proxy         = proxyURL, 
      proxyusername = proxyUser, 
      proxypassword = proxyPwd, 
      proxyport     = 8080
    )  
  }
  
  # read the list of equity symbols 
  #(as per Yahoo - https://in.finance.yahoo.com/lookup)
  df <- read.csv("ShareQuantityHistory.csv", 
                 check.names = FALSE, # required to retain dates as column names
                 stringsAsFactors = FALSE)
  
  noOfEqty <- length(df$Share_Symbol) # no. of stocks to query/update
  
  # set up lists for each of the columns
  equitySymbol <- character(noOfEqty)
  equityName <- character(noOfEqty)
  equityQuantity <- double(noOfEqty)
  equitySharePrice <- double(noOfEqty)
  equityDate <- character(noOfEqty)
  equityValue <- double(noOfEqty)
  latestQuantityColumn <- length(colnames(df))
  
  portfolioValue <- 0
  for (n in 1:noOfEqty) {
  
    # load the symbols for the stocks
    equitySymbol[n] <- df$Share_Symbol[n]
    
    # get the latest quantities of stocks held in the portfolio
    equityQuantity[n] <- as.double(df[n,latestQuantityColumn])
    
    # construct the Yahoo Finance Webservice API url
    urlEqty <- paste("http://finance.yahoo.com/webservice/v1/symbols/",
                     equitySymbol[n], 
                     "/quote", 
                     sep = "" )
    
    # use the proxy details if necessary
    if (useProxy) {
        xmlCode <- getURL(urlEqty, .opts=opts)
    } else {
        xmlCode <- getURL(urlEqty)
    }
    
    # check if the expected xml output was returned
    if (areQuotesAvailable <- grep("resource-list", xmlCode)) {
      
      # parse the text to XML
      eqtyQuoteXML <- xmlParse(xmlCode, useInternalNodes = TRUE, asText = TRUE)
      
      # retrieve the name of the stock
      equityName[n] <- xpathSApply(eqtyQuoteXML, 
                              "//field[@name='name']", 
                              xmlValue)
      
      # retrieve the current share price for the stock
      equitySharePrice[n] <- as.double(xpathSApply(eqtyQuoteXML, 
                           "//field[@name='price']", 
                           xmlValue))
      
      # format the current date into an unambigious format
      equityDate[n] <- format(Sys.Date(),"%d-%b-%Y")
      
      # calculate the current value of the stock holding
      equityValue[n] <- equitySharePrice[n]*equityQuantity[n]
      
      # accumulate the value of the stock holdings to determine portfolio value
      portfolioValue <- portfolioValue + equityValue[n]
      
      # provide an indicator of progress 
      # "|" for each one except every fifth one which has "\"
      if (n%%5 != 0) {
        cat("...")
      } else {
        cat(paste(format(as.integer(100*n/noOfEqty), format="d"),"%", sep = ""))
      }
    }
  }
  
  # check if retrieval of stock quotes was successful
  if(areQuotesAvailable) {
    pwd <- ""
    cat("\014") # clear the screen
    cat(paste("Portfolio value : \u20B9",
                format(portfolioValue,nsmall=2,big.mark = ",",decimal.mark = "."), "\n\n", sep=""))
    # create a data frame with a snapshot of the current portfolio
    dfEquitySnapshot <- data.frame(equitySymbol, 
                                     equityName, 
                                     equityDate, 
                                     equityQuantity, 
                                     equitySharePrice, 
                                     equityValue)
    
    # assign meaningful column names
    colnames(dfEquitySnapshot) <- c("Share_Symbol", 
                                    "Share_Name", 
                                    "Date", 
                                    "Quantity", 
                                    "Share_Price", 
                                    "Share_Value")
    dfEquitySnapshot <- arrange(dfEquitySnapshot, desc(Share_Value))
    
    writeToFiles <- eval(writeToFiles)
    
    if (writeToFiles) {
      
      # update the Share Quantity History
      updateFile(equityDate[1], # date in dd-mmm-yyyy format (for column name)
                 equityQuantity, # values to be updated in new/existing column
                 "ShareQuantityHistory.csv") # file to be updated
      
      # update the Portfolio Value History
      updateFile(equityDate[1], 
                 portfolioValue, 
                 "PortfolioValueHistory.csv") 
      
      # update the Share Value History
      updateFile(equityDate[1], 
                 equityValue, 
                 "ShareValueHistory.csv")
      
      # update the Share Price History
      updateFile(equityDate[1], 
                 equitySharePrice, 
                 "SharePriceHistory.csv")
      
    } 
    
    return(dfEquitySnapshot)
  } else return(NULL)
}