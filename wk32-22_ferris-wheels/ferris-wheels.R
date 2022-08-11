#########################
# TidyTuesday | Week 32 #
# Ferris Wheels         #
# Adam Bushman          #
#########################


library('tidyverse')
library('camcorder')
library('patchwork')


# Camcorder setup

camcorder::gg_record(
  dir = 'C:/Users/Adam Bushman/Pictures/_test', 
  device = 'png', 
  width = 16, 
  height = 9, 
  units = 'cm', 
  dpi = 300
)

# Grob setup

img <- readPicture(system.file('SVG', 'ferris.svg'))

# Data setup

buildings <- read.csv('tallest-buildings.csv')
tuesdata <- tidytuesdayR::tt_load('2022-08-09')

dataFerris <- 
  tuesdata$wheels %>%
  mutate(country = ifelse(country == "Tailand", "Thailand", country), 
         country = ifelse(country == "Phillippines", "Philippines", country), 
         country = ifelse(country == "S Korea", "South Korea", country),
         country = ifelse(country == "Dubai", "UAE", country)) %>%
  left_join(buildings, by = c("country" = "country")) %>%
  filter(!is.na(diameter)) %>%
  rename(loca_b = location.y, height_b = height.y, 
         loca_f = name.x, height_f = height.x) %>%
  mutate(radius_f = diameter / 2, 
         c_height_f = height_f - radius_f, 
         perc = (c_height_f + radius_f) / height_b) %>%
  select(country, loca_b, height_b, loca_f, c_height_f, radius_f, perc)


# Visualization setup

p <- 
  ggplot(dataFerris) +
  ggforce::geom_circle(aes(x0 = 0, y0 = c_height_f, r = radius_f, color = country), 
                       size = 0.75, show.legend = FALSE) +
  geom_bar(aes(1000, height_b, fill = country), stat = "identity", 
           width = 300, show.legend = FALSE) +
  geom_text(aes(x = -600, y = 1250, label = paste(round(perc * 100, 0), "%", sep = "")), 
            size = 1.75, hjust = 0) +
  geom_text(aes(x = -600, y = 2000, label = country, color = country), 
            size = 1.5, vjust = 1, hjust = 0) +
  scale_y_continuous(breaks = c(0, 1000, 2000)) +
  coord_fixed(xlim = c(-700, 1700)) +
  facet_wrap(vars(loca_f), ncol = 11, nrow = 4, 
             labeller = label_wrap_gen(12)) +
  labs(
    title = "Ferris Wheels - Just How Tall?", 
    subtitle = "Comparing ferris wheel heights to the tallest buildings in their respective countries (for those featuring diameter measurements)", 
    y = "Height in Feet"
  ) +
  theme(
    text = element_text(color = "#E2E6FA"), 
    
    axis.text.x = element_blank(), 
    axis.text = element_text(color = "#E2E6FA", size = 5), 
    axis.title.y = element_text(vjust = 2, size = 8), 
    axis.ticks.y = element_line(color = "#E2E6FA"), 
    axis.ticks.x = element_blank(), 
    axis.title.x = element_blank(), 
    
    plot.background = element_rect(fill = "#5D477A", color = NA), 
    plot.margin = margin(0.25, -2, 0.1, -2.5, "cm"), 
    plot.title = element_text(face = "bold"), 
    plot.subtitle = element_text(size = 7), 
    
    legend.position = "none", 
    
    panel.background = element_rect(fill = "#E2E6FA"), 
    panel.grid.major.x = element_blank(), 
    panel.grid.minor.x = element_blank(),
    
    strip.text = element_text(size = 4.5, margin = margin(0.2, 0.75, 0.2, 0.75), 
                              face = "bold"), 
    strip.background = element_rect(fill = "#AEB9F5")
  )



l1 <- 
  ggplot(dataFerris[1,]) +
  ggforce::geom_circle(aes(x0 = 0, y0 = c_height_f, r = radius_f), 
                       color = "#7C757C", size = 0.75, show.legend = FALSE) +
  geom_bar(aes(1000, height_b), stat = "identity", 
           fill = "#7C757C", width = 300, show.legend = FALSE) +
  geom_text(aes(x = -600, y = 650, label = paste(round(perc * 100, 0), "%", sep = "")), 
            size = 2.5, hjust = 0,  color = "#88138A") +
  geom_text(aes(x = -600, y = 1100, label = country, color = country), 
            size = 2.25, vjust = 1, hjust = 0) +
  coord_fixed(xlim = c(-1200, 2200), ylim = c(0, 1100)) +
  annotate("text", x = 1600, y = 500, size = 2, color = "#7C757C", label = "Building\nHeight") +
  annotate("text", x = -700, y = 200, size = 2, color = "#7C757C", label = "Ferris Wheel\nHeight") +
  annotate("text", x = 700, y = 650, size = 1.5, hjust = 1, color = "#88138A", 
           label = "Ferris Wheel\nHeight as %\nof Building") +
  annotate("text", x = 1600, y = 1100, size = 1.5, label = "Ferris Wheel Name") +
  facet_wrap(vars(loca_f), labeller = label_wrap_gen(12)) +
  theme(
    text = element_text(color = "#E2E6FA"), 
    
    axis.text = element_blank(),
    axis.ticks = element_blank(), 
    axis.title = element_blank(), 
    
    plot.background = element_blank(), 
    plot.margin = margin(0.25, -2, 0.1, -2.5, "cm"), 
    plot.title = element_text(face = "bold"), 
    plot.subtitle = element_text(size = 9), 
    
    legend.position = "none", 
    
    panel.background = element_rect(fill = "#E2E6FA"), 
    panel.grid.major.x = element_blank(), 
    panel.grid.minor.x = element_blank(),
    
    strip.text = element_text(size = 4.5, margin = margin(0.2, 0.75, 0.2, 0.75), 
                              face = "bold"), 
    strip.background = element_rect(fill = "#AEB9F5")
  )

l2 <- 
  ggplot() +
  annotate("text", x = 2, y = 8, hjust = 0, size = 3, color = "#E2E6FA", 
           label = "Legend") +
  annotate("text", x = 2, y = 4, hjust = 0, size = 1.5, color = "#AEB9F5", 
           label = "Data Sourced from:\n - {ferriswheels} by Emil Hvitfeldt\n - SkyscraperCenter.com\n\nVisualization by @adam_bushman") +
  ylim(0, 10) + xlim(2,4) +
  theme_void()

p +
  inset_element(
    l1, 
    left = 0.4,
    bottom = -0.03,
    right = 0.9,
    top = 0.297
  ) +
  inset_element(
    l2, 
    left = 0.8,
    bottom = -0.03,
    right = 1,
    top = 0.297
  )


camcorder::gg_stop_recording()
