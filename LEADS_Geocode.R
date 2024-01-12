# Install and load the httr package
library(httr)
library(ggmap)

# Your API key from the Google Cloud Console
api_key <- ""

register_google(key = api_key)

# Your list of location texts
location_texts <- all_data_wOrg$Organization

# Initialize empty vectors for latitude and longitude
latitudes <- numeric(length(location_texts))
longitudes <- numeric(length(location_texts))

# Iterate through the list and geocode each location
for (i in seq_along(location_texts)) {
  location <- geocode(location_texts[i])
  latitudes[i] <- location$lat
  longitudes[i] <- location$lon
}

result_df <- data.frame(Location = location_texts, Latitude = latitudes, Longitude = longitudes)

