# ARC-Tracker
# Description
This is a shiny app that maps position data to an offline map. The position data I used here is from the 2016 Atlantic Rallye for Cruisers. During the course of the regatta, every boat receives the positions of all the boats in the fleet daily in the form of textfiles. There are plenty of map plotting apps out there, however, the vast majority rely on internet access to get the map data (i.e. via the leaflet library). Internet access being limited in the middle of the Atlantic, I found a way to create an offline map to use with this app. This also allowed me to customize it, e.g. by adding the weather quadrants used in the daily weather report. 

# Installation
Download the 3 scripts (global.R, server.R, ui.R) to a folder of your liking. Create a new subfolder for the position data and set it as working directory in global.R (line 15). 
```R
setwd("C:/directory/with/positions")
```
You can run the Tracker from R, which should open a new browser window or tab.

# Offline Map
I created the offline map using Quantum GIS (for the island contours and weather grid) and Tilemill (to make it look nice). I then used MBUtil (<https://github.com/mapbox/mbutil>) to create the offline map tile folders. 
