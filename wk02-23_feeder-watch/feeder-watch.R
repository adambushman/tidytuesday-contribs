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
  ) |>
  inner_join(
    tuesdata$PFW_count_site_data_public_2021, 
    by = c("loc_id" = "loc_id")
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
  ) |>
  mutate(
    month_name = case_when(
      Month == 1 ~ "January", 
      Month == 2 ~ "February", 
      Month == 3 ~ "March", 
      Month == 4 ~ "April", 
      Month == 11 ~ "November", 
      Month == 12 ~ "December" 
    ), 
    month_name = factor(month_name, levels = c(
      "November", "December", "January", "February", "March", "April"
    ))
  )

# Bluejay habitat

bj_hab <-
  bj_data |>
  select(yard_type_pavement:hab_marsh) |>
  pivot_longer(cols = everything(), names_to = "type", values_to = "obs") |>
  group_by(type) |>
  summarise(
    observation = sum(!is.na(obs)), 
    attempt = n(), 
    .groups = 'drop'
  ) |>
  filter(stringr::str_detect(type, "hab")) |>
  mutate(
    share = observation / attempt, 
    location = stringr::str_extract(type, "^[^_]*"), 
    sublocation = stringr::str_sub(type, 5, stringr::str_length(type)), 
  ) |>
  (function(.) assign("hab", ., envir = .GlobalEnv))() |>
  mutate(
    sublocation = factor(
      sublocation, 
      levels = hab |> arrange(share) |> select(sublocation) |> unlist(use.names = FALSE)
    )
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

location <-
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


# Column chart

season <-
  ggplot(
    data = bj_month, 
    aes(month_name, total_many)
  ) +
  geom_col(
    fill = "#2B547E"
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ",")
  ) +
  labs(
    y = "Observations"
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_blank()
  )

# Another chart about where to look

habitat <-
  ggplot(
    bj_hab, 
    aes(share, sublocation)
  ) +
  geom_point(
    color = "#2B547E"
  ) +
  scale_x_continuous(
    labels = scales::label_percent()
  ) +
  labs(
    x = "Frequency of Bluejay Sightings"
  ) +
  theme_minimal() +
  theme(
    axis.title.y = element_blank()
  )

