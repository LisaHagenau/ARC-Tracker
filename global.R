### Reading the files and creating a dataframe containing all the information > allpositions
### missing: add start position for all boats 

library(plyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggmap)
library(maps)
library(mapdata)
library(measurements)
library(reshape2)
library(leaflet)

#  directory with position reports > change to appropriate full path > all other paths are relative
setwd("D:/documents/ARC_Positionsmeldungen/PosDaten/")

# get the data from folder
file_names <- dir(getwd())
allpositions <- do.call(rbind,lapply(file_names,read.csv, stringsAsFactors=FALSE))

# format date to POSIXct format, 
allpositions$time <- strptime(allpositions$time, "%d/%m/%Y", tz="UTC")
allpositions$time <- as.Date(as.POSIXct(allpositions$time, tz = "UTC"))

# convert Lat and Long to decimals for plotting
# change the degree symbol to a space
allpositions$Lat = gsub('°', '', allpositions$Lat)
allpositions$Lat = gsub("' N", '', allpositions$Lat)
allpositions$Long = gsub('°', '', allpositions$Long)
allpositions$Long = gsub("' W", '', allpositions$Long)

# convert from decimal minutes to decimal degrees
allpositions$Lat = measurements::conv_unit(allpositions$Lat, from = 'deg_dec_min', to = 'dec_deg')
allpositions$Long = measurements::conv_unit(allpositions$Long, from = 'deg_dec_min', to = 'dec_deg')

# change column structures from character to factor or numeric
allpositions$BoatName <- as.factor(allpositions$BoatName)
allpositions$Class <- as.factor(allpositions$Class)
allpositions$Lat  <- as.numeric(allpositions$Lat)
allpositions$Long <- as.numeric(allpositions$Long)

# longitude to negative values for automatic map retrieval (W=minus)
pos2neg <- function(x) x *-1
allpositions["Long"] <- lapply(allpositions["Long"], pos2neg)

# sort by BoatName and Time to be able to use geom_path 
allpositions <- arrange(allpositions, BoatName, time)

# calculate standings by group from last DTF and add to dataframe > use mutate?
allpositions <- mutate(allpositions, 
                       ranking = ave(allpositions$DTD, 
                                     allpositions$Class, 
                                     allpositions$time, 
                                     FUN = function(x) rank(x, ties.method="max")))

### add starting positions for all boats 
date <- min(allpositions$time)-1

for (boatname in unique(allpositions$BoatName)) {
  boatno <- allpositions$BoatNo[allpositions$BoatName == boatname][1]
  Class <- allpositions$Class[allpositions$BoatName== boatname][1]
  allpositions <- rbind(allpositions, list(boatno,     # conditional on boatname
                                   boatname, 
                                   "Start", 
                                   Class,         # conditional on boatname
                                   date, # conditional on earliest date
                                   28.128539,  # static > coordinates Las Palmas (28.128539, -15.423893)
                                   -15.423893, # static > doordinates Las Palmas
                                   2667.26, # static > distance LP to St Lucia
                                   0,    # static > VMG >> 0
                                   NA    # static > ranking >> NA
  )
  )
}

# sort by BoatName and Time to be able to use geom_path 
allpositions <- arrange(allpositions, BoatName, time)