library(tidyverse)
library(here)
read_csv(here("../covariates_full.csv")) -> covdata
read_csv(here("../global_wind_solar_2020/global_solar_2020_WGS84.csv")) -> solardata
solardata |> mutate(x = trunc(X),y = trunc(Y)) -> solardata
covdata |> mutate(x = trunc(x), y = trunc(y)) -> covdata
solardata |> mutate(ratio = power / panel.area) |>
      rename(lng = X, lat = Y, radius = ratio) |>
      mutate(lng = round(lng), lat = round(lat)) |>
      group_by(lng,lat) |>
      summarise(radius = mean(radius)) |>
      ungroup() -> sx

sx |> left_join(
  covdata |>
    rename(lng = x, lat = y) |>
    mutate(lng = round(lng), lat = round(lat)) |>
    group_by(lng,lat) |>
    drop_na() |> 
    select(lng, lat, biomass_ndvi, slope, PVOUT) |>
    summarise(across(biomass_ndvi:PVOUT, .fns = mean, na.rm = TRUE)) |>
    ungroup(), by = c("lng","lat")) -> final_data

final_data <- final_data |> rename(latitude = lat, longitude = lng, power_ratio = radius, Biomass = biomass_ndvi, Slope = slope, Potential = PVOUT)
saveRDS(final_data, here("data_rds/solar_table_data.rds"))