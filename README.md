# Night_lights
# Night-Time Light Intensity Swipe App for Sri Lanka (2021–2022)

This Shiny app enables a visual comparison of night-time light intensity across Sri Lanka for the years **2021** and **2022** using a swipe interface. The maps are generated from VIIRS DNB (Day/Night Band) satellite imagery processed in R.
![viirs_comparison](https://github.com/user-attachments/assets/da00c772-43b0-46ed-98e6-6049376ad4c9)

✨ Features
- Visualizes night-time light intensity in Sri Lanka using VIIRS DNB data
- Allows users to **swipe** interactively between 2021 and 2022 maps
- Clean map design with dark mode and custom color gradients
- High-resolution PNG exports and automated image handling

## 🌍 Data Source

- **Dataset**: VIIRS DNB Monthly Composites from NASA/NOAA Suomi NPP Satellite  
- **Original Access**: [NASA Earthdata VIIRS](https://earthdata.nasa.gov/)

**Note**: The official `.zip` archive provided for the VIIRS GeoTIFFs failed to unzip on Windows (likely due to compression format or file corruption).  
Therefore, the `.tif` files were **downloaded and exported manually from Google Earth Engine (GEE)** to ensure correct formatting and projection.



