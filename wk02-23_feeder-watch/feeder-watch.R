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
