# Atlanta_APD_Zones.R: Plotting zones from Atlanta Police Department's Shape File
# Data location: http://www.atlantapd.org/crimedatadownloads.aspx --> "APD Map Files (SHAPE)"

# Thanks to Spatioanalytics.com for the mapping process with rgdal & ggmap
# http://spatioanalytics.com/2013/07/12/throw-some-throw-some-stats-on-that-map-part-1/
# http://spatioanalytics.com/2014/02/20/shapefile-polygons-plotted-on-google-maps-using-ggplot-throw-some-throw-some-stats-on-that-mappart-2/

setwd("[Insert local directory where you extracted the shape files]")

library(rgdal)
library(ggplot2)
library(ggmap)
library(RgoogleMaps)
library(dplyr)

# Initialize map object for Atlanta
CenterOfMap <- geocode("Atlanta, GA")
Atlanta <- get_map(c(lon=CenterOfMap$lon, lat=CenterOfMap$lat),zoom = 11, maptype = "roadmap", source = "google")
AtlantaMap <- ggmap(Atlanta)

# Display map object
AtlantaMap

# Function to read data from shape file
read_shapefile_transform <- function(layer){
     readOGR(".", layer) %>% 
          spTransform(CRS("+proj=longlat +datum=WGS84")) %>% 
          fortify()
}

# There are 2 shapefiles, each mapping to different locations.  The apd_NewZone_2011_region
# seems to be the one that is most up to date (matches the APD Wikipedia zone map as of 5/12/16)
crime1 <- read_shapefile_transform(layer = "APD_BEAT_2011_region")
crime2 <- read_shapefile_transform(layer = "apd_NewZone_2011_region")

# Add zones as a layer on AtlantaMap object
AtlantaMap + 
# Uncomment these 3 lines to also map the (old?) zone map
#      geom_polygon(aes(x = long, y = lat, group = group), 
#                   fill = "grey", size= .2, color="green", 
#                   data = crime1, alpha = 0) + 
     geom_polygon(aes(x = long, y = lat, group = group), 
                  fill = "grey", size= 1, color="red", 
                  data = crime2, alpha = 0) +
     geom_label(data = crime2 %>% group_by(id) %>% 
                     summarise(mid.long = (max(long) + min(long))/2, mid.lat = (max(lat) + min(lat))/2), 
                aes(x = mid.long, y = mid.lat, label = id), size = 6) +
     ggtitle("Atlanta Crime Data Shape File: ID locations")
