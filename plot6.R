library(ggplot2)
library(sqldf)
library(scales)
library(dplyr)

## This first line will likely take a few seconds. Be patient!
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# colnames(NEI)
# head(NEI, n=1)
# str(unique(NEI$type))

# colnames(SCC)
# str(unique(SCC$SCC.Level.Two))
# summary(SCC)

# which(duplicated(SCC$SCC) == T)

# grep("vehicle", unique(SCC$SCC.Level.Two),
#     ignore.case = T, value = T)

motor_compare <- sqldf('SELECT n.year, n.type, n.fips,
               sum(n.Emissions) as emissions
              FROM NEI n
              JOIN SCC s ON (n.SCC = s.SCC)
              WHERE (s.`SCC.Level.Two` like "%Vehicle%")
               AND ((n.fips = "24510") OR (n.fips = "06037") )
              GROUP BY year, type, fips')

motor_compare$fips[motor_compare$fips == "06037"] <- "Los Angeles County"
motor_compare$fips[motor_compare$fips == "24510"] <- "Baltimore City, Maryland"

motor_compare_general <- sqldf("select year, fips,
                                 sum(Emissions) as emissions
                               from motor_compare
                               group by year, fips")

motor_compare_general <-
   motor_compare_general %>% group_by(fips) %>%
   mutate(change=((emissions / emissions[1])-1) *100) %>%
   mutate(type = "ON-ROAD")  # dummy mutate just to plot it
# ggplot2 won't plot if columns don't match

# motor_compare_general$change[motor_compare_general$change == 0] <- NA
motor_compare_general <- motor_compare_general[-1,]

motor_compare_plot <-
   ggplot(motor_compare, aes(x = factor(year), y = emissions, fill = type)) +
   geom_bar(stat = "identity", colour="grey50") +
   scale_y_continuous(limits=c(0, 7900), labels = comma) +
   facet_grid(. ~ fips) +
   xlab("Year") + ylab("Total emissions") +
   geom_text(aes(label = as.integer(emissions)),
             color="#00008A", size=6,
             position = position_dodge(width=1)) +

   geom_text(data = motor_compare_general,
             aes(label=paste(
                            ifelse(change < 0,
                              as.integer(change),
                              paste('+',as.integer(change),sep='')
                                  ),'%',sep=''
                            )
                ),
             color="red",
             vjust=-0.5) +

   labs(title="Emissions (from motor vehicle) Baltimore vs Los Angeles")

motor_compare_plot
