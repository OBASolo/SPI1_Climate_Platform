# ============================================================
# Climate Early Warning Platform with Animated SPI Maps
# Output: Interactive HTML file
# ============================================================

# Install packages if needed
packages <- c("terra", "sf", "leaflet", "leaflet.extras2",
              "htmlwidgets", "dplyr", "RColorBrewer")

new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if(length(new_packages)) install.packages(new_packages)

#install.packages("htmltools")
#install.packages("leaflet")
#install.packages("leaflet.extras2")
library(terra)
library(sf)
library(leaflet)
library(leaflet.extras2)
library(htmlwidgets)
library(dplyr)
library(RColorBrewer)

# ------------------------------------------------------------
# 1. Load spatial data
# ------------------------------------------------------------

# SPI raster file with monthly layers
# Example layer names should be: Jan, Feb, Mar, ..., Dec
spi_file <- "E:/ILIMS_project/FIGURES/DROUGHT/SPI-1_animation_1984-2023.gif"
list.files(paste0("E:/ILIMS_project/FIGURES/DROUGHT/SPI-1"))
# Ghana boundary shapefile
ghana_shp <- "E:/ILIMS_project/DATA/SHAPEFILE_FOLDER/Country_shp/GHA_adm0.shp"

# ============================================================
# SPI-1 Climate Platform from PNG maps
# Output: HTML with play/pause animation
# ============================================================

# Install if needed
packages <- c("htmltools", "stringr")
new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if(length(new_packages)) install.packages(new_packages)

library(htmltools)
library(stringr)

# ------------------------------------------------------------
# 1. Define input and output folders
# ------------------------------------------------------------

img_dir <- "E:/ILIMS_project/FIGURES/DROUGHT/SPI-1"

out_dir <- file.path(img_dir, "SPI1_HTML_Platform")
dir.create(out_dir, showWarnings = FALSE)

img_out_dir <- file.path(out_dir, "images")
dir.create(img_out_dir, showWarnings = FALSE)

# ------------------------------------------------------------
# 2. List PNG files
# ------------------------------------------------------------

png_files <- list.files(
  img_dir,
  pattern = "SPI-1_classification_[0-9]{4}_GHA_Agroeco\\.png$",
  full.names = TRUE
)

# Extract years
years <- str_extract(basename(png_files), "[0-9]{4}")

# Order by year
ord <- order(years)
png_files <- png_files[ord]
years <- years[ord]

# Copy images to HTML folder
file.copy(
  from = png_files,
  to = file.path(img_out_dir, basename(png_files)),
  overwrite = TRUE
)

img_names <- basename(png_files)

# ------------------------------------------------------------
# 3. Build HTML platform
# ------------------------------------------------------------

html_file <- file.path(out_dir, "SPI1_Climate_Platform.html")

html_content <- HTML(paste0(
  '
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SPI-1 Climate Early Warning Platform</title>

<style>
body {
  font-family: Arial, sans-serif;
  background: #f4f7fb;
  margin: 0;
  padding: 0;
}

.header {
  background: linear-gradient(90deg, #08306B, #2171B5);
  color: white;
  padding: 20px;
  text-align: center;
}

.header h1 {
  margin: 0;
  font-size: 30px;
}

.header p {
  margin: 8px 0 0 0;
  font-size: 16px;
}

.container {
  width: 92%;
  margin: 25px auto;
  background: white;
  padding: 20px;
  border-radius: 16px;
  box-shadow: 0 4px 18px rgba(0,0,0,0.15);
}

.controls {
  text-align: center;
  margin-bottom: 20px;
}

button {
  background: #2171B5;
  color: white;
  border: none;
  padding: 10px 18px;
  margin: 5px;
  font-size: 15px;
  border-radius: 8px;
  cursor: pointer;
}

button:hover {
  background: #08306B;
}

select, input[type=range] {
  padding: 8px;
  margin: 8px;
  font-size: 15px;
}

#yearLabel {
  font-size: 24px;
  font-weight: bold;
  color: #08306B;
}

.map-box {
  text-align: center;
}

.map-box img {
  max-width: 100%;
  border: 1px solid #ddd;
  border-radius: 10px;
}

.footer {
  text-align: center;
  color: #555;
  font-size: 13px;
  margin-top: 15px;
}
</style>
</head>

<body>

<div class="header">
  <h1>SPI-1 Climate Early Warning Platform</h1>
  <p>Animated yearly monitoring of drought and wetness conditions across Ghana</p>
</div>

<div class="container">

  <div class="controls">
    <div id="yearLabel">Year: ', years[1], '</div>

    <br>

    <button onclick="previousYear()">Previous</button>
    <button onclick="playAnimation()">Play</button>
    <button onclick="pauseAnimation()">Pause</button>
    <button onclick="nextYear()">Next</button>

    <br>

    <label><b>Select year:</b></label>
    <select id="yearSelect" onchange="selectYear(this.value)">
',
paste0(
  '<option value="', seq_along(years) - 1, '">', years, '</option>',
  collapse = "\n"
),
'
    </select>

    <br>

    <input 
      type="range" 
      id="yearSlider" 
      min="0" 
      max="', length(years) - 1, '" 
      value="0" 
      step="1" 
      oninput="selectYear(this.value)"
      style="width:70%;"
    >
  </div>

  <div class="map-box">
    <img id="mapImage" src="images/', img_names[1], '" alt="SPI-1 map">
  </div>

  <div class="footer">
    Indicator: SPI-1 | Classes: Extremely Dry to Extremely Wet | Source: ILIMS Project
  </div>

</div>

<script>
var images = [
',
paste0('"images/', img_names, '"', collapse = ",\n"),
'
];

var years = [
',
paste0('"', years, '"', collapse = ","),
'
];

var currentIndex = 0;
var timer = null;

function updateMap() {
  document.getElementById("mapImage").src = images[currentIndex];
  document.getElementById("yearLabel").innerHTML = "Year: " + years[currentIndex];
  document.getElementById("yearSlider").value = currentIndex;
  document.getElementById("yearSelect").value = currentIndex;
}

function nextYear() {
  currentIndex = (currentIndex + 1) % images.length;
  updateMap();
}

function previousYear() {
  currentIndex = (currentIndex - 1 + images.length) % images.length;
  updateMap();
}

function selectYear(index) {
  currentIndex = parseInt(index);
  updateMap();
}

function playAnimation() {
  pauseAnimation();
  timer = setInterval(nextYear, 1200);
}

function pauseAnimation() {
  if (timer !== null) {
    clearInterval(timer);
    timer = null;
  }
}
</script>

</body>
</html>
'
))

writeLines(as.character(html_content), html_file)

# ------------------------------------------------------------
# 4. Open platform
# ------------------------------------------------------------

browseURL(html_file)

cat("HTML platform created here:\n", html_file, "\n")
