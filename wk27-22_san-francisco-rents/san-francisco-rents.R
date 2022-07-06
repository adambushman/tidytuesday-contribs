#######################
# San Francisco Rents #
# TidyTuesday Wk 27   #
# Adam Bushman        #
#######################


library('ggplot2')
library('dplyr')
library('tigris')
library('sf')
library('scales')
library('gganimate')
library('transformr')
library('showtext')


###
# Font Setup
###
showtext_auto()
font_add_google("rajdhani")


###
# Data Setup
###
tuesdata <- tidytuesdayR::tt_load('2022-07-05')
newconst <- tuesdata$new_construction %>%
  mutate(county = str_replace(county, " County", ""))

# Setting up the simple features
ca <- counties("CA") %>%
  filter(NAME %in% c("Alameda", "Contra Costa", "Marin", "Napa", 
                     "San Francisco", "San Mateo", "Santa Clara", "Solano", 
                     "Sonoma")) %>%
  select(NAME, geometry) %>%
  rename(county = NAME)

# Setting up the data and joining with sf
fulldata <-
  newconst %>%
  select(year, county, sfproduction) %>%
  pivot_wider(names_from = year, names_prefix = "yr_", values_from = sfproduction) %>%
  arrange(county)
fulldata$geometry = (ca %>% arrange(county) %>% .$geometry)
fulldata <-
  fulldata %>%
  pivot_longer(cols = contains("yr_"), names_to = "year", values_to = "production") %>%
  group_by(county) %>%
  arrange(year) %>%
  mutate(year = as.integer(str_replace(year, "yr_", "")), 
         production_cs = cumsum(production)) %>%
  st_as_sf(.)

###
# Plotting
###

# Basic plot
p <- 
  ggplot(fulldata) +
  geom_sf(aes(fill = production_cs)) +
  theme_void()

p # Quick peek


# Custom color scale and theme
p <- 
  p +
  scale_fill_viridis_b(option = "magma", 
                       labels = label_number(big.mark = ",")) +
  theme(
    plot.margin = margin(1.5, 1.5, 1.5, 2.5, "cm"), 
    plot.background = element_rect(fill = "#333333"), 
    
    # Text
    text = element_text(family = "rajdhani", color = "#F8FCDA"), 
    plot.title = element_text(size = 20, face = "bold"), 
    plot.subtitle = element_text(size = 15, face = "italic"), 
    legend.text = element_text(size = 13), 
    legend.title = element_text(size = 15), 
    plot.caption = element_text(size = 13)
  )

p # Quick peek


# Animation by year and labels
p <-
  p +
  transition_time(year) +
  geom_sf_label(aes(label = county), size = 4, 
                color = "#F8FCDA", fill = "#333333", 
                family = "rajdhani") +
  labs(title = "New Construction of Single Family Dwellings", 
       subtitle = "San Francisco & Surrounding Counties | Year: {frame_time}", 
       fill = "Ssingle Family\nDwelling Production")


# Display and save
animate(p, height = 722, width = 800)
anim_save("san-francisco-new-construction.gif")

