library(terra)
library(raster)

# Create base raster
baseRaster = raster(ncols = 3600, nrows = 1800,
                    xmn = -180, xmx = 180,
                    ymn = -90, ymx = 90)

baseRaster = terra::rast(baseRaster)
baseRaster$id = 1:(nrow(baseRaster)*ncol(baseRaster))
baseRasterXY = xyFromCell(baseRaster, 1:ncell(baseRaster)) %>% 
  data.frame() %>% 
  mutate(id = 1:nrow(.))

# function
saveConsistentMaps <- function(tf, baseRaster){
  
  name = str_extract(tf, "(?<=/)[^/]+(?=\\.tif)")
  
  rawSlope = terra::rast(tf)
  
  slope_resample = resample(rawSlope, baseRaster, method = "bilinear")
  
  slopeXY = as.data.frame(slope_resample, xy = TRUE, na.rm = FALSE) %>% 
    mutate(id = 1:ncell(slope_resample))
  
  write_csv(slopeXY, file = paste0("/datathon/data/parsed_datafiles/", name, ".csv"))
}

# Loop through data files
ff <- c("/datathon/data/night-light.tif",
        "/datathon/data/biomass_ndvi.tiff",
        "/datathon/data/solar_potential/World_PVOUT_GISdata_LTAy_AvgDailyTotals_GlobalSolarAtlas-v2_GEOTIFF/PVOUT.tif",
        "/datathon/data/gmtedSlope.tif",
        "/datathon/data/population_data_pq/density.tif",
        "/datathon/data/population_data_pq/density_raw_grid.tif",
        "/datathon/data/populationDen.tif")
for(i in ff){
  saveConsistentMaps(i, baseRaster)
  print(str_extract(i, "(?<=/)[^/]+(?=\\.tif)"))
}

## END SCRIPT ## ---------------------------------------------------------------