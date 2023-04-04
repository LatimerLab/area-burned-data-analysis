#### Calculate daily burned area from file structure containing individual fires and corresponding geotiffs with burn dates. #### 

library(raster)

data_dir <- "./data/dob-per-fire" # base of file tree with fire data in it

# annoying renaming hack to make all the geotiff names consistent. currently 2020 and 2021 have fire-specific geotif names; 2002-2019 don't 
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

for (i in 1:n_fires) {
  r <- raster(fires$fire.path[i])
  
  
}


