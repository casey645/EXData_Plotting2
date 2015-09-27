# plot3.R
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
save.image( 'NEI.RData' )


# 4. plot the data
install.packages('ggplot2')
library(ggplot2)
library(plyr)
emissions <- ddply(NEI, .(year, type), summarize, total.emissions = sum(emissions) )

# create the plot object
emi.plot <- ggplot(emissions, aes(year, total.emissions, color = type) )
emi.plot <- emi.plot + geom_line()

# plot the data
png('plot3.png')
print(emi.plot)
dev.off()