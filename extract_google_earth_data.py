import ee
import geemap
import geopandas as gpd

ee.Authenticate()
ee.Initialize()

## Slope data

gmtedData = ee.Image('USGS/GMTED2010')
gmtedElevation = gmtedData.select('be75')
gmtedSlope = ee.Terrain.slope(gmtedElevation)

gmtedMap = geemap.Map()
gmtedMap.set_center(-112.8598, 336.2841, 10)

slopeVis = {
    "min":0,
    "max": 90
}
gmtedMap.add_layer(gmtedSlope, slopeVis ,'slope')


task = ee.batch.Export.image.toDrive(
    image = gmtedSlope,
    folder = "UNDatathon - Down under data wizards",
    fileNamePrefix = "gmtedSlope",
    scale = 5000,
    fileFormat = "GeoTIFF"
)
task.start()

## Population Density

popDen = ee.ImageCollection("projects/sat-io/open-datasets/ORNL/LANDSCAN_GLOBAL")
popDenImage = ee.Image(popDen.toList(50).get(22))

popMap = geemap.Map()
popMap.set_center(-112.8598, 36.2841, 10)
popVis = {
  'max': 1000.0,
  'min': 0.0
}
popMap.add_layer(popDenImage, popVis)
popDenImage.visualize(min = 0, max = 255)

task = ee.batch.Export.image.toDrive(
    image = popDenImage.visualize(min = 0, max = 255),
    folder = "UNDatathon - Down under data wizards",
    fileNamePrefix = "populationDen",
    scale = 5000,
    fileFormat = "GeoTIFF"
)
task.start()