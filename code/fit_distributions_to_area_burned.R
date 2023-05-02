#### Explore distribution of daily burned areas, test power law fits and changes over time #### 
# Andrew Latimer 
# Q: are there more "extreme spread events" EWEs recently? If so, are those simply the result of drawing more fire days from the same distribution, or is there a distribution shift that favors higher extremes? If so is there any clue why that's happening? 

# Input to this script is the file of daily burned areas output from "extract_daily_area.R" in this repository 

library(fitdistrplus)
library(actuar)

d <- read.csv("./data/fire_daily_area_2002_2021.csv")
head(d)

hist(log10(d$area))

fire_areas <- d$area[d$state == "CA" & d$area > 42]

fires.pareto <- fitdist(fire_areas, "pareto", start = list(shape = 10, scale = 10), lower = 2+1e-6, upper = Inf)
fires.ln <- fitdist(fire_areas, "lnorm")
cdfcomp(list(fires.pareto, fires.ln), xlogscale = TRUE, ylogscale = TRUE, legendtext = c("Pareto", "lognormal"))
gofstat(list(fires.pareto, fires.ln), fitnames = c("Pareto", "lognormal"))

# Lognormal fits better than Pareto, although for CA fires in 2020 & 2021, it's getting more similar to Pareto. 

# Next - compare earlier and later decade -- does distribution shift, or is fire just more prevalent? I guess that Coop paper already showed the distribution shifted. So is there anything more to learn? 
