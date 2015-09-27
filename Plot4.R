# plot4.R
#--------------------------
# Bastiaan Quast
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

institutional <- SCC[which(SCC$ei.sector == "Fuel Comb - Comm/Institutional - Coal"),]$scc
electric <- SCC[which(SCC$ei.sector == "Fuel Comb - Electric Generation - Coal"),]$scc
industrial <- SCC[which(SCC$ei.sector == "Fuel Comb - Industrial Boilers, ICEs - Coal"),]$scc

NEI$institutional <- ifelse( NEI$scc %in% institutional, 'institutional', NA )
NEI$electric <- ifelse( NEI$scc %in% electric, 'electric', NA )  
NEI$industrial <- ifelse( NEI$scc %in% industrial, 'industrial', NA )  

rm(institutional)
rm(electric)
rm(industrial)

NEI$coal <- with(NEI,
                 ifelse(!is.na(institutional), 
                        'institutional', 
                        ifelse(!is.na(electric), 
                               'electric',
                               ifelse(!is.na(industrial),
                                      'industrial',
                                      NA
                               )
                        )
                 )
)

library(plyr)
emissions <- ddply(subset(NEI, !is.na(coal)), .(year, coal), summarize, total.emissions = sum(emissions) )

# 4. plot the data
library(ggplot2)
nei.plot <- ggplot(emissions, aes(year, total.emissions, color = coal) )
nei.plot <- nei.plot + geom_line()

# plot the data
png('plot4.png')
print(nei.plot)
dev.off()