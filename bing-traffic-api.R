library(httr)

key <- "YOUR_BING_KEY" #To set one up, go to www.bingmapsportal.com

# Get all traffic incident data from specified bounding box
# Bounding Box: Atlanta Perimeter (format South,West,North,East)
r <- GET(paste0("http://dev.virtualearth.net/REST/v1/Traffic/Incidents/",
                "33.629548,-84.512112,33.927471,-84.242947/true?",
                "t=1,2,3,4,5,6,7,8,9,10,11&s=1,2,3,4&key=", key, "&o=json"))

request.time <- headers(r)$date

response <- content(r)

# TO DO: Flatten response data into a data frame
