library(ggplot2)
library(sqldf)

## This first line will likely take a few seconds. Be patient!
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

colnames(NEI)

scc_through_time <- sqldf('select SCC, year, Pollutant, Emissions from NEI where fips = "24510" group by SCC, year')

# Simple Bar Plot
counts <- sqldf("select year, sum(Emissions) as em from scc_through_time group by year")

barplot(counts$em,
        names = counts$year,
        main="Total emissions from PM2.5 in Baltimore City, Maryland",
        xlab="Year",
        ylab="Emission")
lines(counts$em/2)
points(counts$em/2)
#lines(lowess(counts$em, delta = 0.05 * diff(range(counts$em))))
