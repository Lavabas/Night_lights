libs <- c(
  "tidyverse", "ggplot2", "terra", "sf",
  "giscoR", "shiny"
)

installed_libraries <- libs %in% rownames(
  installed.packages()
)

if(any(installed_libraries == F)){
  install.packages(
    libs[!installed_libraries]
  )
}

invisible(lapply(
  libs, library, character.only = T
))


# 1. GET COUNTRY MAP
#-------------------

country_sf <- giscoR::gisco_get_countries(
  country = "LKA",
  resolution = "3"
)

# 2. GET DATA
#------------
library(terra)

# Load both raster files
raster_files <- c(
  "c:/Users/strangers/Documents/VIIRS_2021_SriLanka.tif",
  "c:/Users/strangers/Documents/VIIRS_2022_SriLanka.tif"
)

# Load them into a list
viirs_rasters <- lapply(raster_files, rast)



# 4. CROP DATA
#-------------
viirs_lka_list <- lapply(
  viirs_rasters,
  function(x) {
    terra::crop(
      x,
      terra::vect(country_sf),
      snap = "in",
      mask = TRUE
    )
  }
)

# ---- 5. Transform projection ----
# Use a suitable projection for Sri Lanka.
# Let's use a Lambert Azimuthal Equal Area centered on Sri Lanka approx at lat 7.8, lon 81
crs_lambert_lka <- "+proj=laea +lat_0=7.8 +lon_0=81 +datum=WGS84 +units=m +no_defs"

viirs_lka_reproj <- lapply(
  viirs_lka_list,
  function(x){
    terra::project(x, crs_lambert_lka)
  }
)

# ---- 6. Remove zeros and subzeros ----
viirs_lka_final <- lapply(
  viirs_lka_reproj,
  function(x){
    terra::ifel(x <= 0, NA, x)
  }
)

# ---- 7. Raster to dataframe ----
viirs_lka_df <- lapply(
  viirs_lka_final,
  function(x){
    as.data.frame(x, xy = TRUE, na.rm = TRUE)
  }
)

col_names <- c("x", "y", "value")
viirs_lka_df <- lapply(
  viirs_lka_df,
  setNames,
  col_names
)

# ---- 8. Map ----
cols <- c("#1f4762", "#FFD966", "white")
pal <- colorRampPalette(cols, bias = 8)(512)

years <- c(2021, 2022)
names(viirs_lka_df) <- years

map_list <- lapply(
  names(viirs_lka_df),
  function(y){
    ggplot(viirs_lka_df[[y]]) +
      geom_sf(data = country_sf, fill = NA, color = cols[[1]], size = 0.05) +
      geom_tile(aes(x = x, y = y, fill = value)) +
      scale_fill_gradientn(name = "", colors = pal) +
      coord_sf(crs = crs_lambert_lka) +
      theme_void() +
      theme(
        legend.position = "none",
        plot.title = element_text(size = 30, color = "white", hjust = 0.5, vjust = 1),
        plot.caption = element_text(size = 10, color = "white", hjust = 0.5, vjust = -1),
        plot.margin = margin(t = 20, r = 10, b = 30, l = 10)  # add space for caption
      ) +
      labs(title = paste("Night-Time Light Intensity Across Sri Lanka", y),
           caption = "Prepared by Lavanya Baskaran — Source:VIIRS DNB Monthly Composites, NASA/NOAA Suomi NPP Satellite",
           x = NULL, y = NULL
      )
  }
)

# ---- 9. Save PNG maps ----
for (i in 1:length(map_list)) {
  file_name <- paste0("srilanka_map_", i, ".png")
  png(file_name, width = 800, height = 800, units = "px", bg = "#182833")
  print(map_list[[i]])
  dev.off()
}

# ---- 10. Move images to shiny/www ----
shiny_dir <- file.path(getwd(), "www")
if (!dir.exists(shiny_dir)) dir.create(shiny_dir)

images_list <- list.files(path = getwd(), pattern = "srilanka_map_.*\\.png", full.names = TRUE)
file.copy(from = images_list, to = shiny_dir, overwrite = TRUE)

# ---- 11. Shiny swipe app ----

library(htmltools)

css <- HTML('
  #comparison {
    width: 80vw;
    height: 80vw;
    max-width: 800px;
    max-height: 800px;
    overflow: hidden;
    position: relative;
  }
  #comparison figure {
    background-image: url("srilanka_map_1.png");
    background-size: cover;
    position: relative;
    font-size: 0;
    width: 100%;
    height: 100%;
    margin: 0;
  }
  #divisor {
    background-image: url("srilanka_map_2.png");
    background-size: cover;
    position: absolute;
    width: 50%;
    box-shadow: 0 5px 10px -2px rgba(0,0,0,0.3);
    overflow: hidden;
    bottom: 0;
    height: 100%;
    top: 0;
    left: 0;
    pointer-events: none;
  }
  input[type=range] {
    -webkit-appearance:none;
    -moz-appearance:none;
    position: relative;
    top: -2rem;
    left: -2%;
    background-color: rgba(255,255,255,0.1);
    width: 102%;
  }
  input[type=range]:focus {
    outline: none;
  }
  input[type=range]::-webkit-slider-thumb {
    -webkit-appearance:none;
    width: 20px;
    height: 15px;
    background: #fff;
    border-radius: 0;
  }
  input[type=range]::-moz-range-thumb {
    -moz-appearance: none;
    width: 20px;
    height: 15px;
    background: #fff;
    border-radius: 0;
  }
')

js <- HTML('
  Shiny.addCustomMessageHandler("initSwipe", function(message) {
    var divisor = document.getElementById("divisor");
    var slider = document.getElementById("slider");
    slider.addEventListener("input", function() {
      divisor.style.width = slider.value + "%";
    });
    divisor.style.width = slider.value + "%";
  });
')

ui <- fluidPage(
  tags$head(tags$style(css)),
  tags$head(tags$script(js)),
  
  HTML('
    <div id="comparison">
      <figure>
        <div id="divisor"></div>
      </figure>
      <input type="range" min="0" max="100" value="50" id="slider">
    </div>
  ')
)

server <- function(input, output, session){
  session$sendCustomMessage("initSwipe", list())
}

shinyApp(ui, server)

library(magick)

# Read the two PNGs
img1 <- image_read("srilanka_map_1.png")
img2 <- image_read("srilanka_map_2.png")

# Combine and animate
animation <- image_animate(c(img1, img2), fps = 1)

# Save the GIF
image_write(animation, "viirs_comparison.gif")

