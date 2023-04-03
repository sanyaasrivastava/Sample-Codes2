# #=============================================================================*
#   
# * TITLE: National Family Health Survey Use Case 						
# 
# * AUTHOR: 	Sanya Srivastava 	
# 
# * LAST UPDATED:			02 April 2023
# 
# * REVIEWED BY:					
# 
# * REVIEW DATE:				
# 
# * DESCRIPTION: 
# #=============================================================================*

library(sf)
library(dplyr)
library(ggplot2)

# Read in the shapefile
shapefile <- st_read("/Users/sanyasrivastava/Downloads/ForMegh/shapefiles/polbnda_ind.shp")

# Read in the dataframe
dataframe <- read.csv("/Users/sanyasrivastava/Downloads/ForMegh/NFHS_usecase.csv")


# AMS - Note that we only keep those whose data we have. Also - the shapefile has a lot more data points than what we need. 
# So - upto you if you'd like to keep that. 

# Earlier we were trying to 'extract' a bunch of information from the shapefile - I realized there's no need to do so. 
# Because - 'geometry' variable includes a ton of random shit - which is why the extraction was very off. 

# From Chatgpt below:
# The geometry variable in a shapefile typically includes information about the spatial location and shape of the features in the dataset. In particular, the geometry variable in a shapefile can include the following variables:
#   
#   point: A single x,y coordinate representing a point location
# multipoint: Multiple x,y coordinates representing multiple point locations
# linestring: A series of connected x,y coordinates representing a line
# multilinestring: Multiple series of connected x,y coordinates representing multiple lines
# polygon: A closed series of connected x,y coordinates representing an area
# multipolygon: Multiple closed series of connected x,y coordinates representing multiple areas

# So we simply merge the two datasets 

# Merge the two datasets on the "laa" column
merged_data <- merge(shapefile, dataframe, by = "laa", all.x = T)

# Plot low birth weight chart 
ggplot(data = merged_data, aes(fill = LBW_per)) +
  geom_sf() +
  scale_fill_gradientn(colors = c("darkgreen", "yellow", "red"), 
                       breaks = c(0, 10, 20, 30, 40, 50), 
                       na.value = "gray",
                       guide = guide_coloursteps(title = "Low Birth Weight (%)")) +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        legend.title = element_text(size = 10, face = "bold"),
        legend.position = "right",
        legend.key.width = unit(0.6, "cm"),
        panel.border = element_blank(),
        panel.spacing = unit(0.1, "cm"),
        plot.margin = unit(c(1, 1, 0.5, 0.5), "cm"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.background = element_rect(fill = "white"),
        axis.line = element_blank(),
        axis.ticks = element_blank()) +
  ggtitle("Low Birth Weight (%): District Level") +
  labs(fill = "Low Birth Weight (%)")
