#######################
# Technology Adoption #
# TidyTuesday Wk 29   #
# Adam Bushman        #
#######################

library('ggplot2')
library('tidyr')
library('dplyr')
library('countrycode')
library('stringr')
library('NatParksPalettes')
library('ggtext')
library('patchwork')
library('camcorder')


###
# Data Setup
###

tuesdata <- tidytuesdayR::tt_load('2022-07-19')
technology <- tuesdata$technology

# Chose to focus on electricity from nuclear energy
energy <- 
  technology %>% 
  filter(category == "Energy" & str_detect(label, "Electricity from")) %>%
  mutate(country = countrycode(iso3c, origin = "iso3c", destination = "country.name"), 
         country = ifelse(is.na(country), "Kosovo", country)) %>%
  mutate(source = str_sub(label, 18, str_locate(label, "\\(")[,2]-2)) %>%
  mutate(type = factor(ifelse(source %in% c('coal', 'oil', 'gas'), 'Fossil', 'Renewable'), 
                        levels = c('Renewable', 'Fossil'))) %>%
  group_by(year, country, type) %>%
  summarise(total = sum(value), .groups = 'drop') %>%
  pivot_wider(names_from = type, values_from = total, values_fill = 0) %>%
  mutate(perc_renewable = Renewable / (Renewable  + Fossil), 
         total_energy = Renewable + Fossil)


top_countries <-
  energy %>%
  filter(year == 2020 & total_energy > 200) %>%
  arrange(desc(perc_renewable)) %>%
  select(country) %>%
  unlist(., use.names = FALSE)


final_ranks <- 
  energy %>% 
  filter(country %in% top_countries) %>% 
  arrange(year, desc(perc_renewable)) %>%
  group_by(year) %>%
  mutate(rank = rank(-perc_renewable), 
         highlight = ifelse(country %in% c('United Kingdom', 'United States', 'Japan'), 
                            country, 'AAA'))


###
# Data Viz Setup
###

camcorder::gg_record(
  dir = 'C:/Users/Adam Bushman/Pictures/_test', 
  device = 'png', 
  width = 16, 
  height = 9, 
  units = 'cm', 
  dpi = 300
)



# Main Plot
p <-
  ggplot() +
  geom_line(data = final_ranks, 
            aes(x = year, y = rank, group = country, 
                color = highlight), 
            size = 2, 
            alpha = 0.8, 
            show.legend = FALSE) +
  geom_point(data = final_ranks,
             mapping = aes(x = year, y = rank, group = country), 
             color = "#F5F5F5", 
             size = 0.75, 
             show.legend = FALSE) +
  scale_y_reverse()

p

# Texts

ggtitle = "<span style='color:#cdd0bd'>**Renewable Energy**</span><br>Production Advancements"
ggsubtitle = "Technology advancements over the past half century have catapulted industries <br>forward, particularly those for renewable energy production. <br>Below are the yearly ranks (minimum  200 MegaWattHours) in <br>**Percent of Energy Production As Renewable**. <br>Interesting countries highlighted."

p <- 
  p +
  geom_text(mapping = aes(x = 2020, y = 1:20, label = top_countries), 
            hjust = 0, size = 2.25, position = position_nudge(x=0.5)) +
  xlim(1983, 2024) +
  labs(title = ggtitle, 
       subtitle = ggsubtitle, 
       caption = "Data Sourced from data.nber.org [CHAT dataset via 10.3386/w15319]\nVisualization by @adam_bushman") +
  annotate("text", x = 1983, y = 18, 
           label = "Higher Is Better Ranking", 
           hjust = 0, angle = 90, size = 2.25) +
  geom_segment(aes(x = 1983, y = 6, xend = 1983, yend = 2), 
               arrow = arrow(length = unit(0.1, "cm")))

p

# Themeing
p <- 
  p +
  scale_color_manual(values = append("#cdd0bd", c(natparks.pals("BryceCanyon", 3, "discrete")))) +
  theme_void() +
  theme(
    plot.margin = margin(0.25, 0.75, 0.25, 0.25, "cm"), 
    plot.background = element_rect(fill = "#FFFFFF", color = NA), 
    plot.title = element_textbox_simple(
      padding = margin(0.25, 1.5, 0, 0.65, "cm"), 
      fill = NA
    ),
    plot.subtitle = element_textbox_simple(
      size = 6, 
      face = "italic", 
      padding = margin(0.15, 1.75, 0.25, 0.65, "cm"), 
      fill = NA
    ), 
    plot.caption = element_text(size = 6)
  )

p


l <- 
  ggplot(mapping = aes(1:10, 1:10)) +
  annotate("rect", xmin = 1, xmax = 10, ymin = 6, ymax = 10, fill = "#cdd0bd") +
  annotate("rect", xmin = 1, xmax = 10, ymin = 1, ymax = 5, fill = NA, color = "#cdd0bd") +
  annotate("text", x = 1.5, y = 8.75, hjust = 0, size = 2.75, 
           label = "Renewable Sources") +
  annotate("text", x = 2, y = 7.5, hjust = 0, size = 1.8, 
           label = "Hydro, Nuclear, Solar, Wind, Other") +
  annotate("text", x = 1.5, y = 3.75, hjust = 0, size = 2.75, 
           label = "Fossil Sources") +
  annotate("text", x = 2, y = 2.5, hjust = 0, size = 1.8, 
           label = "Coal, Gas, Oil") +
  theme_void()





p +
  inset_element(
    l, 
    left = 0.65,
    bottom = 1,
    right = 0.9,
    top = 1.45
  )

S




camcorder::gg_stop_recording()
camcorder::gg_playback(
  name = "test.gif", 
  last_image_duration = 30
)


