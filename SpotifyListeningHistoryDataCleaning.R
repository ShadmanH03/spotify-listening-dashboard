# Title: Spotify Listening History - Data Preparation 
# Goal: Merge raw JSON files into one CSV, clean it, and export the output for Tableau.

library(jsonlite)
library(dplyr)
library(lubridate)

folder <- "/Users/shadmanh/Downloads/Spotify Extended Streaming History" # Change to your own export folder.

# Finds list of .json files from user's Spotify history

files <- list.files(folder, pattern = "\\.json$", full.names = TRUE) 

data <- files |>
  lapply(fromJSON) |>
  bind_rows()

data <- data |>
  mutate(
    ts             = ymd_hms(ts),               # parse timestamp
    minutes_played = ms_played / 60000,         # ms -> minutes
    hour           = hour(ts),                  # time-of-day view
    weekday        = wday(ts, label = TRUE),    # weekday heatmap
    month          = floor_date(ts, "month")    # trend over time
  ) |>
  filter(!is.na(master_metadata_track_name)) |> # drops podcasts and empty plays (NAs, etc.)
  select(-any_of(c("ip_addr", "conn_country"))) # remove personal fields

write.csv(data, "ExtendedStreamingHistory_clean.csv", row.names = FALSE)

