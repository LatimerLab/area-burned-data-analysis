#### Outline of how to get daily (24 hour period) spread rates from a fire spread raster output from some version of the Parks algorithm #### 
# For example: https://github.com/LatimerLab/burn-date-and-weather
# Individual fire tifs here: https://ucdavis.app.box.com/file/1058589676906?s=qi6iuamk92pikevpmmt24dbaccpm0qkz

library(raster)
library(terra)
library(whitebox)
library(lubridate)
library(sf)
  
data_dir <- "./data/dob-per-fire/dob-new-final/2020/" 

fire_ids <- list.dirs(data_dir, full.names=FALSE)
fire_id <- "CA4185812335420200908"

r <- raster(paste(data_dir, fire_ids[4], "/dob.tif", sep = ""))
plot(r)

#### Set up data objects ####

# Example fire tif 
r <- raster(paste(data_dir, fire_ids[4], "/dob.tif", sep = ""))

# get unique set of julian dates for fire
v <- getValues(r)
firedays <- sort(unique(v)) # note this often has gaps so we'll have to deal with some days with no recorded spread. 

# create rasterbrick with one layer per day

b <- boundaries(r, classes = TRUE, type = "outer", asNA = TRUE)
plot(b)
r_edges <- setValues(r, getValues(b) * getValues(r))
plot(r_edges)
r_days <- layerize(r_edges, classes = firedays)
plot(r_days[[2]])

distance(r_days[[2]], r_days[[1]]) # runs out of memory try this: wbt_euclidean_distance()

b_days <- layerize(b, classes = firedays)
plot(b_days[[2]])
# create a matrix with values of 


for (i in min(firedays):max(firedays)) { # loop through all the days the fire was recorded as spreading
  
  
  
  

}

# focal() # moving window smoother
# boundaries() # find edges 
# coordinates() # get coords from cell number
# direction() # angle to nearest non-NA cell 
# distance x, y # distance from cells in x to cells in y. can "doEdge" first to save time and just find distance to edge cells 

# layerize() # split the whole-fire raster into a brick where each layer indicates cumulative spread through a day.  Problem is how to use "boundaries" to detect just the new NA edges, not the boundaries with previous day. 
# idea: layerize -> boundaries (for each layer) -> distance() and direction() for each pair of adjacent layers -> focal() over results to smooth 
# Then question would be how to detect which is the leading edge and erase all the other edges (or just could use max dist for spread rate??)


# set counter to first julian date for the fire  
# Get cell ids of candidate edge cells for day 1 (all cells with >=1 queens move neighbor that was never burned or burned on later date)
# Loop over all julian dates (2:ndays)
# Get cell ids of candidate edge cells for current day (all cells with >=1 queens move neighbor that was never burned or burned on later date)
# Get cell ids of candidate edge cells. 
# Loop over all candidate cells. 
# For each cell, identify potential parent cells (e.g. closest 10 edge cells from yesterday)
# For each cell, calculate its movement vector as the mean of the vectors from each parent cell. 
# Optional: run a smoother over these vector directions? moving average of the cell plus several neighbors?
# Optional: filter today's edge cells as follows. Look forward some distance (?) along the cell's movement vector. If there are at least 2 unburned neighbors within 90 (?) degrees of that direction, then it's an edge, otherwise not. 
# Measure fire progression distance: From each edge cell, search the area with D degrees of its mean vector. If there are multiple cells in that search wedge, calculate the mean distance from them to the current cell. Alternatively the search wedge could be defined by reference to the variability in the vectors in neighboring cells in today's candidate edge cells. 
# Store today's cell ids, vector directions, and vector lengths. 
# If today is the last day of the fire, stop. 
# Else go to next fire progression day. 
