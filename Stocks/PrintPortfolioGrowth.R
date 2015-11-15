setwd("./")
source('updatePortfolio.R') # updates files with latest data
source('calculatePortfolioReturn.R') # calculate growth using data in files
source('plotPortfolioValue.R') # plot the portfolio growth

# Set useProxy to "T", if behind a proxy server
# For convenience, set the proxy details in updatePortfolio.R as defaults
updatePortfolio(useProxy="F") 
# alternate usage where proxy details are passed explicitly
#updatePortfolio(UseProxy="T", 
#                          ProxyURL="proxy.company.com", 
#                          ProxyUser="domain\\username"
#                          ProxyPwd="password"
#                          ProxyPort="8080"
#                          WriteToFiles="T"))
CalculatePortfolioReturn()
print(plotPortfolioValue())