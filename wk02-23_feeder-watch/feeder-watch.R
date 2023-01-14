library('tidyverse')


###
# Data Setup
###

# Load from TidyTuesday repo

tuesdata <- tidytuesdayR::tt_load('2023-01-10')

# Transform & filter for Bluejays

bj_data <- 
  tuesdata$PFW_2021_public |>
  mutate(country = stringr::str_sub(subnational1_code, 1, 2)) |> 
  filter(
    species_code == 'blujay' & country != 'XX'
  )

# Location frequency data

bj_grouped <-
  bj_data |>
  group_by(
    latitude, longitude
  ) |>
  summarise(
    total_many = sum(how_many), 
    .groups = 'drop'
  ) |>
  arrange(desc(total_many))

# Month frequency data

bj_month <- 
  bj_data |>
  filter(species_code == 'blujay') |>
  group_by(
    Month
  ) |>
  summarise(
    total_many = sum(how_many)
  )


###
# Visualization
###


# Map plot

us_canada <- 
  ggplot2::map_data("world") |>
  filter(
    region %in% c("Canada", "USA") &
    lat >= 22 & long <= -50
  )

ggplot() +
  geom_map(
    data = us_canada, map = us_canada,
    aes(long, lat, map_id = region), 
    color = "white", fill = "lightgray"
  ) +
  geom_point(
    data = bj_grouped, 
    aes(longitude, latitude, size = total_many), 
    color = "#2B547E", 
    alpha = 0.3
  ) + 
  labs(
    size = "Observations"
  ) +
  theme_void()


