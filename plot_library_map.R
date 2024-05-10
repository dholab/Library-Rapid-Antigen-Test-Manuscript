#!/usr/bin/env Rscript

library(tidyverse)
library(tmaptools)
library(maps)
library(leaflet)

#
library_data_path <- "data/Dane_County_Library_Addresses.tsv"

#
library_df <- read_tsv(library_data_path,
                       skip = 2, trim_ws = TRUE, show_col_types = FALSE)

# find the latitudes and longitudes for every row
lat_lons <- lapply(library_df$`Library Address`, function(address) {
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

# add them to the dataframe
plotting_df <- library_df |>
  mutate(
    longitude = longitudes,
    latitude = latitudes
  ) |>
  drop_na() |>
  rename(enrolled = `In program?`) |>
  mutate(
    enrollment_status = if_else(
      enrolled,
      paste(`Library Name`, " Status: Enrolled"),
      paste(`Library Name`, " Status: Not Enrolled")
    )
  )

# define a function that will determine color
getColor <- function(df) {
  sapply(df$enrolled, function(whether_enrolled) {
    if (whether_enrolled) {
      "green"
    } else {
      "gray"
    } })
}

# define a function that will determine opacity
getOpacity <- function(df) {
  sapply(df$enrolled, function(whether_enrolled) {
    if (whether_enrolled) {
      0.9
    } else {
      0.5
    } })
}

# define icons
icons <- awesomeIcons(
  icon = 'ion-ios-book',
  iconColor = 'black',
  library = 'ion',
  markerColor = getColor(plotting_df)
)

# throw them on the map
leaflet(data = plotting_df) |>
  addTiles() |>
  addAwesomeMarkers(~longitude, ~latitude,
                    icon = icons,
                    popup = ~as.character(enrollment_status),
                    label = ~as.character(enrollment_status),
                    labelOptions = labelOptions(noHide = FALSE, textOnly = FALSE),
                    options = markerOptions(opacity = getOpacity(plotting_df),
                                            riseOnHover = TRUE)) |>
  addLegend(
    values = ~enrolled,
    position = "bottomright",
    colors = c("green", "gray"),
    labels = c("Enrolled", "Unenrolled"), opacity = 1,
    title = "Enrollment Status"
  )
