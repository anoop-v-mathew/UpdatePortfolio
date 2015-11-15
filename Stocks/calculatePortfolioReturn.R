# Net present value.
npv <- function(irr, cashflow, times) {
  sum(cashflow / (1 + irr)^times) 
}

SimpleIRR <- function(pv, principal, dtPV, dtInvestment) {
  n <- abs(as.double(difftime(strptime(dtInvestment, format = "%d-%b-%Y"),
                strptime(dtPV, format = "%d-%b-%Y"),units="days")/365.24))
  100*((pv/principal)^(1/n)-1)
}

CalculatePortfolioReturn <- function() {
  csvPortfolio <- "PortfolioValueHistory.csv"
  dt <- read.csv(csvPortfolio, 
                 check.names = FALSE, # required to retain dates as column names
                 stringsAsFactors = FALSE)
  colNum <- length(colnames(dt))
  
  startingValue <- dt[1,1]
  lastValue <- dt[1,colNum]
  startingDate <- colnames(dt)[1]
  lastDate <- colnames(dt)[colNum]
  growth <- lastValue-startingValue
  
  cat(paste("Portfolio Growth:", format(round(growth, 
                                              digits=2), 
                                        format="%d", big.mark = ",")))
  
  cat(paste("\nAbsolute Growth %: ",format(round((growth)*100/startingValue, 
                                                 digits=2), 
                                           format="%d"),
            "%", 
            sep=""))
  
  cat(paste("\nPortfolio Growth % (annualized): ",
              format(round(SimpleIRR(lastValue, # initial portfolio value
                               startingValue, # last updated portfolio value
                               startingDate, # tracking commencement date
                               lastDate), # last updated portfolio date
                           digits=2),
                     format="%d"), 
              "%", 
              sep=""))
  

}
