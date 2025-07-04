// Define the region of interest: Sri Lanka
var sriLanka = ee.FeatureCollection("FAO/GAUL/2015/level0")
                 .filter(ee.Filter.eq('ADM0_NAME', 'Sri Lanka'));

// Load VIIRS DNB Monthly Composites for 2021
var viirs2021 = ee.ImageCollection("NOAA/VIIRS/DNB/MONTHLY_V1/VCMSLCFG")
                  .filterDate('2021-01-01', '2021-12-31')
                  .select('avg_rad')
                  .mean()
                  .clip(sriLanka);

// Visualization for map
Map.centerObject(sriLanka, 7);
Map.addLayer(viirs2021, {min: 0, max: 60, palette: ['black', 'yellow', 'white']}, 'VIIRS 2021');

// Export to Google Drive
Export.image.toDrive({
  image: viirs2021,
  description: 'VIIRS_2021_SriLanka',
  folder: 'GEE_Exports',
  scale: 500,  // meters per pixel
  region: sriLanka.geometry(),
  crs: 'EPSG:4326',
  maxPixels: 1e13
});

// Define the region of interest: Sri Lanka
var sriLanka = ee.FeatureCollection("FAO/GAUL/2015/level0")
                 .filter(ee.Filter.eq('ADM0_NAME', 'Sri Lanka'));

// Load VIIRS DNB Monthly Composites for 2022
var viirs2022 = ee.ImageCollection("NOAA/VIIRS/DNB/MONTHLY_V1/VCMSLCFG")
                  .filterDate('2022-01-01', '2022-12-31')
                  .select('avg_rad')
                  .mean()
                  .clip(sriLanka);

// Visualization for map
Map.centerObject(sriLanka, 7);
Map.addLayer(viirs2022, {min: 0, max: 60, palette: ['black', 'yellow', 'white']}, 'VIIRS 2022');

// Export to Google Drive
Export.image.toDrive({
  image: viirs2022,
  description: 'VIIRS_2022_SriLanka',
  folder: 'GEE_Exports',
  scale: 500,  // meters per pixel
  region: sriLanka.geometry(),
  crs: 'EPSG:4326',
  maxPixels: 1e13
});

