#### Calculate daily burned area from file structure containing individual fires and corresponding geotiffs with burn dates. #### 
# Andrew Latimer 
# Input data is from Derek, and was produced using his modified Parks date of burn script here: https://github.com/LatimerLab/burn-date-and-weather
# And data here https://ucdavis.app.box.com/file/1058589676906?s=qi6iuamk92pikevpmmt24dbaccpm0qkz (note I deleted the "dob-new" directory before running this since it has duplicate files in it)


library(raster)
library(terra)
library(doParallel)
library(lubridate)
library(ggplot2)

data_dir <- "./data/dob-per-fire" # base of file tree with fire data in it

# set up parallelization
cl <- makeCluster(8)
registerDoParallel(cl)

# renaming hack to make all the geotiff names consistent. currently 2020 and 2021 have fire-specific geotif names; 2002-2019 don't.
new_tifs <- list.files("./data/dob-per-fire/dob-new-final", pattern = ".tif", recursive = TRUE)
new_dirs <- list.dirs("./data/dob-per-fire/dob-new-final")
new_dirs_length <- unlist(sapply(new_dirs, nchar))
new_dirs <- new_dirs[which(new_dirs_length > 50)]
for (i in 1:length(new_tifs)) file.rename(paste("./data/dob-per-fire/dob-new-final/", new_tifs[i], sep = ""), paste(new_dirs[i], "/dob.tif", sep = ""))

# Get list of all files 
f <- list.files(data_dir, pattern = ".tif", recursive = TRUE)

n_fires <- length(f)

# set up storage for info for each fire 
year = state = fire.id = start.date = fire.path = vector(mode = "character")

# extract info about each fire including path to geotif 
for (i in 1:n_fires) {
  file_info <- strsplit(f[i], split = "/")[[1]]
  year[i] <- file_info[2] 
  state[i] <- substr(file_info[3], start = 1, stop = 2)
  fire.id[i] <- substr(file_info[3], start = 3, stop = 13)
  start.date[i] <- substr(file_info[3], start = 14, stop = 21)
  fire.path[i] <- paste(data_dir, file_info[1], file_info[2], file_info[3], "dob.tif", sep = "/")
}

fires <- data.frame(fire.id = fire.id, year = year, state = state, start.date = start.date, fire.path = fire.path)
head(fires)


# Pull up individual geotif for each fire and extract daily area burned info from it 

# Check area of pixels
r_terra <- rast(fires$fire.path[100])
cellSize(r_terra) # 900 m^2 per pixel
cell_area <- 900 / 10000 # area of each pixel in hectares

#daily_table <- foreach(i = 1:10, .combine = rbind) %dopar% as.data.frame(table(getValues(raster(fires$fire.path[i])))) 
daily_area <- data.frame()
for (i in 1:n_fires) { 
  r <- raster(fires$fire.path[i])
  t <- as.data.frame(table(getValues(r)))
  # add fire.id column 
  t$fire.id <- fires$fire.id[i]
  t$state <- fires$state[i]
  t$year <- fires$year[i]
  daily_area <- rbind(daily_area, t)
}

# Convert cell counts to area and julian dates to date 
names(daily_area)[1] <- "julian_date"
names(daily_area)[2] <- "pixel_count"
daily_area$area <- daily_area$pixel_count * cell_area
origin_dates <- paste(daily_area$year, "01", "01", sep = "-")
daily_area$date <- as_date(as.numeric(as.character(daily_area$julian_date)), origin = origin_dates)
daily_area$month <- month(daily_area$date)

# Save the results
write.csv(daily_area, "./data/fire_daily_area_2002_2021.csv")


# Quick checks of the results
hist(daily_area$month)

ggplot(daily_area[daily_area$state == "CA" & daily_area$year<2013,], aes(y = area, x = month)) + geom_bar(stat = "sum") 

plot(sort((daily_area$area)))




