
# files to load
ff <- paste0("/datathon/data/parsed_datafiles/", 
             c("biomass_ndvi.csv", 
               "gmtedSlope.csv",
               "PVOUT.csv",
               "night-light.csv",
               "density.csv"))

# load csv
ll <- lapply(1:5, FUN = function(x)read_csv(ff[x]))

# ndvi - setting negative to na
ll[[1]]  <- mutate(ll[[1]], biomass_ndvi = ifelse(biomass_ndvi < 0, NA, biomass_ndvi))

# gmtedSlope - must be positive
ll[[2]]  <- mutate(ll[[2]], slope = ifelse(slope < 0, NA, slope))

# PVOUT - setting negative to na
ll[[3]]  <- mutate(ll[[3]], PVOUT = ifelse(PVOUT < 0, NA, PVOUT))

# density
ll[[4]] <- ll[[4]] %>% 
  rename(night_light = `night-light_1`) %>% 
  dplyr::select(-c(`night-light_2`, `night-light_3`))

# density - setting negative to na
ll[[5]] <- ll[[5]] %>% 
  mutate(density = ifelse(density < 0, NA, density))

# left join
full_df <- ll %>% reduce(., left_join)

# save file
write_csv(full_df, file = "/datathon/data/parsed_datafiles/covariates_full.csv")