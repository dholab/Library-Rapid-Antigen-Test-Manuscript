#!/usr/bin/env Rscript

library(tidyverse)
library(tmaptools)
library(sf)
library(tigris)
options(tigris_use_cache = TRUE, tigris_class = "sf")

#
library_data_path <- "data/Dane_County_Library_Addresses.tsv"

#
library_df <- read_tsv(library_data_path,
  skip = 2, trim_ws = TRUE, show_col_types = FALSE
)

# find the latitudes and longitudes for every row
lat_lons <- lapply(library_df$Address, function(address) {
  lat_lon <- geocode_OSM(address)$coords
  return(lat_lon)
})

# separate out longitudes
longitudes <- lapply(lat_lons, function(lat_lon) {
  if (is.null(lat_lon)) {
    return(NA)
  }

  return(unlist(lat_lon["x"]))
}) |>
  unlist() |>
  unname()

# separate out latitudes
latitudes <- lapply(lat_lons, function(lat_lon) {
  if (is.null(lat_lon)) {
    return(NA)
  }

  return(unlist(lat_lon["y"]))
}) |>
  unlist() |>
  unname()

# double check that they are the same length
stopifnot(length(latitudes) == length(longitudes))

# Get the map data for Wisconsin counties
dane_co_limits <- counties("WI", cb = TRUE) |>
  filter(NAME == "Dane")

# pull out indices for the enrolled libraries
facility_indices <- library_df |>
  filter(`In program?`) %>%
  `row.names<-`(., NULL) |>
  select(`Location Name`) |>
  arrange(`Location Name`) |>
  rowid_to_column() |>
  mutate(index = rowid) |>
  select(-rowid) |>
  unite(
    `Legend Label`, c(index, `Location Name`),
    remove = FALSE, na.rm = TRUE, sep = " - "
  )

# add them to the dataframe along with some additional tidying
plotting_df <- library_df |>
  mutate(
    longitude = longitudes,
    latitude = latitudes
  ) |>
  drop_na() |>
  rename(enrolled = `In program?`) |>
  rename(`Facility Type` = `Bldg Type`) |>
  left_join(
    facility_indices,
    by = join_by(`Location Name`)
  ) |>
  mutate(index = as.factor(index)) |>
  mutate(`Legend Label` = as.factor(`Legend Label`))

# generate the plot
simple_map <- plotting_df |>
  ggplot(aes(x = longitude, y = latitude, label = index)) +
  geom_sf(
    data = dane_co_limits, fill = alpha("white", 0.5),
    color = "black", inherit.aes = FALSE
  ) +
  geom_point(
    mapping = aes(shape = factor(if_else(`Facility Type` == "Library", 5, 16))),
    color = if_else(plotting_df$enrolled, "darkgreen", alpha("gray", 0.8)),
    size = 2.5
  ) +
  scale_shape_manual(
    values = c(16, 5), labels = c("Clinic", "Library"),
    guide = guide_legend(title = "Facility Type")
  ) +
  geom_text(vjust = -1, color = "darkgreen", inherit.aes = TRUE) +
  theme_minimal() +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "lines"),
    legend.position = "right"
  )

ggsave("visuals/library_map.pdf", simple_map, height = 5, width = 7)
