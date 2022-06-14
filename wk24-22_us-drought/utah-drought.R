##############################
# Week 24, 2022 | US Drought #
# Adam Bushman               #
##############################

library('ggplot2')
library('dplyr')
library('tidyr')
library('ggridges')
library('lubridate')

# Data setup
tuesdata <- tidytuesdayR::tt_load('2022-06-14')


# Initial plot setup
p1 <- 
  tuesdata$`drought-fips` %>%
  filter(State == 'UT') %>%
  mutate(yr = year(ymd(date))) %>%
  ggplot(., aes(x = DSCI, y = yr, group = yr, fill = stat(x))) +
    geom_density_ridges_gradient(rel_min_height = 0.01) +
    scale_fill_gradient(low = '#d0162e', high = '#fcc425')

p1 # Quick peek


# Adjusting labels, titles, and theme
p1 <-
  p1 + 
  labs(title = 'Utah Drought Severity by Year',
       subtitle = 'Since Year 2000', 
       y = '', 
       x = 'DSCI Score [Drought Severity]', 
       fill = 'DSCI') +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = '#221e1f'), 
    text = element_text(color = '#fcfcfc'),
    axis.text = element_text(color = '#fcfcfc'), 
    panel.grid.major = element_line(color = '#6e6565'), 
    panel.grid.minor = element_line(color = '#6e6565'), 
    plot.title = element_text(size = 18, hjust = 0.5, face = 'bold'), 
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  )

p1 # Quick peek


# Adding arrows and annotations
p1 <-
  p1 +
  geom_segment(aes(x = 250, y = 1998, xend = 0, yend = 1998), 
               arrow = arrow(length = unit(0.3, "cm")), 
               color = '#fcfcfc') +
  annotate(geom = 'text', x = 0, y = 1998.5, 
           label = 'A \"0\" DSCI Score is Desireable', 
           color = '#fcfcfc', 
           hjust = 0) +
  geom_segment(aes(x = 200, y = 2021, xend = 200, yend = 2023), 
            color = '#fcfcfc', 
            size = 2.5) +
  annotate(geom = 'text', x = 190, y = 2022, 
           label = 'Past two years have been \n the worst drought since \'03-\'04', 
           color = '#fcfcfc', 
           hjust = 1) +
  ylim(1998, 2023)


p1 # Final
