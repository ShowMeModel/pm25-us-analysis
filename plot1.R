library(ggplot2)
library(sqldf)

## This first line will likely take a few seconds. Be patient!
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# First, summary all the loaded data
summary(NEI)
summary(SCC)

# How many distinct types of pullants are there ?
str(NEI$Pollutant)
unique(NEI$Pollutant)

# Is there a situation in data when a
# single source reports only for a factor of all years?
# How many sources have a single county?
# In other words, consider dealing with NAs per a county

sources <- sqldf("select fips as county, year, count(distinct SCC) from NEI group by fips, year")
# yes, there are such situations, SCC vary between years

# Aggregate to answer first question
total_emission <- sqldf("select year, Pollutant, sum(Emissions) as sum_emissions from NEI group by year, Pollutant")
total_emission

# I don't think it's the proper way to do it

# Let's better focus on a sigle SCC through time, as far as I understand
# SCCs are stationairy and It should be enough to analyze their output
# without grouping by counties

# probably I will need to do some NA's rough fix if SCC is turned off for a particular year

# check if this happens

scc_through_time <- sqldf("select SCC, year, Pollutant, Emissions from NEI group by SCC, year")

# it occurs in SOME of the data

# Simple Bar Plot
counts <- sqldf("select year, sum(Emissions) as em from scc_through_time group by year")
barplot(counts$em,
        names = counts$year,
        main="Total emissions from PM2.5 in US",
        xlab="Year",
        ylab="Emission")
lines(counts$em/2)
points(counts$em/2)
