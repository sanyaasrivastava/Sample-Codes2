# #=============================================================================*
#   
# * TITLE: National Family Health Survey Use Case 						
# 
# * AUTHOR: 	Sanya Srivastava 	
# 
# * LAST UPDATED:			02 April 2023
# 
# * REVIEWED BY:Sanya Srivastava 		
# 
# * REVIEW DATE: 01/04/2023				
# 
# * DESCRIPTION:  Making a  district-wise heatmap which provides a use case that 
# identifies areas with high incidence of malnutrition
# i.e. Low Birth Weight (from National Family Health Survey 2015-16), 
# revealing that the patriarchal society of the Hindi belt in the north has 
# poorer outcomes, while the north-east and south have relatively better
# outcomes. India's shapefiles have 766 districts mapped to the 
# Local Government Directory, while the
# National Family Health Survey is mapped to Census, 
# which is an older system and only has 640 districts.
# Data has been merged with shapefiles - polygon based and then I used ggplot
# to plot the heatmap
#=============================================================================*

library(sf)
library(dplyr)
library(ggplot2)

# Read in the shapefile
shapefile <- st_read("/Users/sanyasrivastava/Downloads/ForMegh/shapefiles/polbnda_ind.shp")

# Read in the dataframe
dataframe <- read.csv("/Users/sanyasrivastava/Downloads/ForMegh/NFHS_usecase.csv")

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
