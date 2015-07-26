library(ggplot2)
library(sqldf)
library(scales)

## This first line will likely take a few seconds. Be patient!
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

colnames(NEI)
head(NEI, n=1)
str(unique(NEI$type))

colnames(SCC)
str(unique(SCC$SCC.Level.Two))
summary(SCC)

which(duplicated(SCC$SCC) == T)

grep("vehicle", unique(SCC$SCC.Level.Two),
     ignore.case = T, value = T)

motor <- sqldf('SELECT n.year, n.type,
               sum(n.Emissions) as emissions
              FROM NEI n
              JOIN SCC s ON (n.SCC = s.SCC)
              WHERE (s.`SCC.Level.Two` like "%Vehicle%")
               AND (n.fips = "24510")
              GROUP BY year, type')

motor_plot <-
   ggplot(motor, aes(x = factor(year), y = emissions, fill = type)) +
   geom_bar(stat = "identity", colour="grey50") +
   scale_y_continuous(labels = comma) +
   geom_smooth(method = "auto", se=F, aes(group=1), color="yellow") +
   xlab("Year") + ylab("Total emissions") +
   labs(title="Emissions from motor vehicle sources in Baltimore")

suppressMessages(print(motor_plot))
