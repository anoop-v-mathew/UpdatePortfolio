library(ggplot2)
library(scales)

plotPortfolioValue <- function() {
  csvPortfolio <- "PortfolioValueHistory.csv"
  dt <- read.csv(csvPortfolio, 
                 stringsAsFactors = FALSE,
                 header = FALSE)
  
  # plot the portfolio value over time
  df <- data.frame(tm=strptime(dt[1,], format="%d-%b-%Y"), 
                   val=as.numeric(dt[2,]))
  gg <- ggplot(df, aes(x=tm, y=val))
  pp <- gg+labs(title="Portfolio Value Over Time")+
    xlab("Time")+
    ylab("Portfolio Value")+
    scale_y_continuous(labels=comma)+
    scale_colour_gradient(low="red", high="green")+
    theme(legend.position="none")+
    geom_point(aes(size=2, colour=val))+geom_line(aes(size=1))
}