library(sf)
library(dplyr)
library(lubridate)
library(stringr)
geopackage_path <- "C:/Users/yagmur/work/Spain/filtered_out-data/filtered_datas"
# Get a list of all the files in the directory
geopackage_files <- list.files(geopackage_path, pattern = "^filtered_.*\\.gpkg$", full.names = TRUE)
# Loop through each file
for (filepath in geopackage_files) {
  # Extract the year from the filename
  year <- str_extract(filepath, "\\d{4}")
  # Read the GeoPackage file
  data <- st_read(filepath)
  # Convert the timestamp column to a date
  data$timestamp <- as.Date(data$timestamp)
  # Extract year from the timestamp
  data$year <- year(data$timestamp)
  # Group by station and year, and summarize the values
  yearly_data <- data %>%
    group_by(station_id, station_name, year) %>%
    summarize(
      mean_temperature = mean(mean_temperature, na.rm = TRUE),
      min_temperature = min(min_temperature, na.rm = TRUE),
      max_temperature = max(max_temperature, na.rm = TRUE),
      precipitation = mean(precipitation, na.rm = TRUE)
    ) %>%
    ungroup()
  # Filter out rows with no calculations (all variables are NA)
  yearly_data_filtered <- yearly_data %>%
    group_by(station_id, station_name, year) %>%
    filter(n() > 0)  # Keep rows with at least one entry for the year
  # Create the filename for the aggregated data
  aggregated_filename <- paste0(year, "_agg_yearly.gpkg")
  aggregated_filepath <- file.path(geopackage_path, aggregated_filename)
  # Save the aggregated yearly data as a new GeoPackage file
  st_write(yearly_data_filtered, aggregated_filepath)
}
