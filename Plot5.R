# plot5.R
#--------------------------
# this file does the following
# 1. download data from UCI Machine Learning Repository
# 2. read the data into R
# 3. inspect and recode the data
# 4. plot the data
# =========================

file.url <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
file.dest <- 'NEI.zip'
download.file( file.url, file.dest )
source.files <- unzip( file.dest, list = TRUE )$Name
unzip( file.dest )
file.remove( file.dest )
rm(file.url)
rm(file.dest)


# 2. read the data into R, save, and remove source file
print(source.files)
SCC <- readRDS("Source_Classification_Code.rds")
NEI <- readRDS("summarySCC_PM25.rds")
# clean up
file.remove( source.files )
rm(source.files)
# save to RData file
save.image( 'NEI.RData' )


# 3. inspect data and recode
str(SCC)
head(SCC)
str(NEI)
head(NEI)
names(SCC)
names(NEI)
new.names <- gsub( '_', '.', names(SCC)  )
new.names <- tolower( new.names )
names( SCC ) <- new.names
new.names <- gsub( '_', '.', names(NEI)  )
new.names <- tolower( new.names )
names( NEI ) <- new.names
names(SCC)
names(NEI)
rm(new.names)

levels(SCC$ei.sector)
heavy.diesel <- SCC[which(SCC$ei.sector == "Mobile - On-Road Diesel Heavy Duty Vehicles"),]$scc
light.diesel <- SCC[which(SCC$ei.sector == "Mobile - On-Road Diesel Light Duty Vehicles"),]$scc
heavy.gasoline <- SCC[which(SCC$ei.sector == "Mobile - On-Road Gasoline Heavy Duty Vehicles"),]$scc
light.gasoline <- SCC[which(SCC$ei.sector == "Mobile - On-Road Gasoline Light Duty Vehicles"),]$scc

NEI$heavy.diesel <- ifelse( NEI$scc %in% heavy.diesel, TRUE, FALSE)
NEI$light.diesel <- ifelse( NEI$scc %in% light.diesel, TRUE, FALSE)
NEI$heavy.gasoline <- ifelse( NEI$scc %in% heavy.gasoline, TRUE, FALSE)
NEI$light.gasoline <- ifelse( NEI$scc %in% light.gasoline, TRUE, FALSE)

rm(heavy.diesel)
rm(light.diesel)
rm(heavy.gasoline)
rm(light.gasoline)

NEI$vehicle <- with(NEI,
                    ifelse(heavy.diesel == TRUE, 
                           'heavy.diesel', 
                           ifelse(light.diesel == TRUE,
                                  'light.diesel',
                                  ifelse(heavy.gasoline == TRUE,
                                         'heavy.gasoline',
                                         ifelse(light.gasoline == TRUE,
                                                'light.gasoline',
                                                NA
                                         )
                                  )
                           )
                    )
)

library(plyr)
NEI <- subset(NEI, fips == "24510")
emissions <- ddply(subset(NEI, !is.na(vehicle)), .(year, vehicle), summarize, total.emissions = sum(emissions) )

# 4. plot the data
library(ggplot2)
nei.plot <- ggplot(emissions, aes(year, total.emissions, color = vehicle) )
nei.plot <- nei.plot + geom_line()

# plot the data
png('plot5.png')
print(nei.plot)
dev.off()