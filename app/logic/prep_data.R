library(dplyr)
library(readr)
library(here)
source(here("app/logic/scale_fns.R"))

# pop_density_data <- read_csv("density.csv", show_col_types = FALSE) |>
#       rename(density = `vis-gray`) |>
#       filter(!is.na(density), density < 100, density > 0) |>
#       rename(lng = x, lat = y) |>
#       mutate(lng = round(lng), lat = round(lat)) |>
#       group_by(lng,lat) |>
#       summarise(density = mean(density, na.rm = T)) |>
#       ungroup() |>
#       mutate(radius = density) |>
#       mutate(radius = min_max_scale(radius))

# saveRDS(pop_density_data, file = here("data_rds", "pop_density.rds"))

# night_light_data <- read_csv(here("covar.csv"), show_col_types = FALSE) |>
#       rename(lng = x, lat = y, radius = `night_light`) |>
#       mutate(radius = radius / 255) |>
#       dplyr::filter(radius > 0.5) |>
#       mutate(radius = min_max_scale(radius))

# saveRDS(night_light_data, file = here("data_rds", "night_light_data.rds"))

demand_data <- read_csv(here("data-raw/demand.csv"), show_col_types = FALSE) |>
  rename(lng = x, lat = y) |>
  mutate(radius = demand) |>
  filter(demand > 0, raw_density != 0) |>
  mutate(lng = trunc(lng), lat = trunc(lat)) |>
  group_by(lat, lng) |>
  summarise(radius_raw= median(demand)) |>
  ungroup() |>
  mutate(radius = min_max_scale(radius_raw))

saveRDS(demand_data, file = here("data_rds", "demand_data.rds"))

solar_data <- read_csv(here("data-raw/global_solar_2020_WGS84.csv"), show_col_types = FALSE) |>
      mutate(ratio = power / panel.area) |>
      rename(lng = X, lat = Y, radius = ratio) |>
      mutate(lng = round(lng), lat = round(lat)) |>
      group_by(lng,lat) |>
      summarise(radius = mean(radius)) |>
      ungroup()

saveRDS(solar_data, here("data_rds", "solar_data.rds"))

solar_table_data <- read_csv(here("data-raw/global_solar_2020_WGS84.csv"), show_col_types = FALSE) |>
      mutate(ratio = power / panel.area) |>
      rename(lng = X, lat = Y, radius = ratio) |>
      mutate(lng = round(lng), lat = round(lat)) |>
      group_by(lng,lat) |>
      mutate(radius = mean(radius)) |>
      ungroup()

saveRDS(solar_table_data, here("data_rds", "solar_table_data.rds"))

prediction_data <- read_csv(here("data-raw/predictions.csv"), show_col_types = FALSE) |>
      filter(!is.na(pred)) |> 
      mutate(x = round(x), y = round(y)) |> 
      group_by(x, y) |> 
      summarise(pred = median(pred)) |> 
      ungroup() |>
      rename(lng = x, lat = y) |>
      mutate(radius = pred) |> 
      mutate(radius = min_max_scale(radius))

saveRDS(prediction_data, here("data_rds", "prediction_data.rds"))

biomass_data <- read_csv(here("data-raw/biomass_ndvi.csv"), show_col_types = FALSE) |>
  filter(!is.na(biomass_ndvi)) |>
  mutate(x = round(x), y = round(y)) |>
  group_by(x, y) |>
  summarise(biomass_ndvi = median(biomass_ndvi)) |>
  ungroup() |>
  rename(lng = x, lat = y) |>
  mutate(radius_raw = biomass_ndvi) |>
  mutate(radius = min_max_scale(radius_raw))

saveRDS(biomass_data, here("data_rds", "biomass_data.rds"))

slope_data <- read_csv(here("data-raw/gmtedSlope.csv"), show_col_types = FALSE) |>
  filter(!is.na(slope)) |>
  mutate(x = round(x), y = round(y)) |>
  group_by(x, y) |>
  summarise(slope = median(slope)) |>
  ungroup() |>
  rename(lng = x, lat = y) |>
  mutate(radius_raw = slope) |>
  mutate(radius = min_max_scale(radius_raw))

saveRDS(slope_data, here("data_rds", "slope_data.rds"))

pv_potential <- read_csv(here("data-raw/PVOUT.csv"), show_col_types = FALSE) |>
  filter(!is.na(PVOUT)) |>
  mutate(x = round(x), y = round(y)) |>
  group_by(x, y) |>
  summarise(PVOUT = median(PVOUT)) |>
  ungroup() |>
  rename(lng = x, lat = y) |>
  mutate(radius_raw = PVOUT) |>
  mutate(radius = min_max_scale(radius_raw))

saveRDS(pv_potential, here("data_rds", "pv_potential.rds"))


