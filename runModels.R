library(caret)
library(tidyverse)
rm(list = ls())

# Load data and concordances
solarData = read_csv("/datathon/data/global_wind_solar_2020/global_solar_2020_WGS84.csv")
solarIntersection = readRDS("/datathon/data/solarIntersection.rds")
covariates = read_csv("/datathon/data/parsed_datafiles/covariates_full.csv")

# filter solar dara
solarData = solarData %>% 
  filter(!is.na(power)) %>% 
  mutate(powerRatio = power/panel.area)
# convert to sf
solarSf = st_as_sf(solarData, coords = c("X", "Y"), crs = 4326)

# Wrangling data
solarData$id = solarIntersection
solarSub = solarData %>% 
  dplyr::select(id, powerRatio)

# Create full dataframe
full_dat = covariates %>% 
  dplyr::select(id, x, y, biomass_ndvi, slope, PVOUT) %>% 
  left_join(solarSub, by = join_by(id))

# Model matrix
modelMat = full_dat %>% 
  filter(!is.na(powerRatio)) %>% 
  na.omit()

## Model ## --------------------------------------------------------------------

# RANGER - spatial random forest - SOTA
fit = readRDS("/datathon/results/resultsRANGER.rds")

# subset
sub_cov <- full_dat %>%
  dplyr::select(-powerRatio) %>% 
  drop_na() %>% 
  filter(slope < max(modelMat$slope, na.rm = T),
         PVOUT < max(modelMat$PVOUT, na.rm = T),
         biomass_ndvi < max(biomass_ndvi, na.rm = T))

# predicted values
full_predict = predict(fit$finalModel, data = sub_cov)
sub_cov$pred = full_predict$predictions

# Save pretitions
write_csv(dplyr::select(covariates, x, y, id, pred), "/datathon/data/parsed_datafiles/predictions.csv")

## END SCRIPT ## ---------------------------------------------------------------