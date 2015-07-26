library(ggplot2)
library(sqldf)

## This first line will likely take a few seconds. Be patient!
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

colnames(NEI)
head(NEI, n=1)
str(unique(NEI$type))

colnames(SCC)
summary(SCC)

baltimore_types <- sqldf('SELECT year, type,
                         sum(Emissions) as emissions
                         FROM NEI
                         WHERE fips = "24510"
                         GROUP BY year, type')

baltimore_plot <-
   ggplot(baltimore_types, aes(x = factor(year), y = emissions)) +
   geom_bar(stat = "identity", colour="grey50") +
   facet_grid(. ~ type) +
   geom_smooth(method = "lm", se=F,
               color="#73C2FB", aes(group=1), size=0.5) +
   xlab("Year") + ylab("Total emissions") +
   labs(title="Emissions in Baltimore grouped by type")

baltimore_plot
