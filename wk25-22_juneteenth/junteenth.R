library('ggplot2')
library('dplyr')
library('tidyr')
library('gridExtra')
library('scales')
library('ggimage')
library('showtext')
library('stringr')


# Data setup
census <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-06-16/census.csv')

censusDF <-
  census %>%
  filter(region != 'USA Total') %>%
  group_by(region, year) %>%
  summarise(total_f = sum(black_free), 
            total_s = sum(black_slaves), 
            .groups = 'drop') %>%
  mutate(Free = round(total_f / (total_f + total_s), 4), 
         Enslaved = round(total_s / (total_f + total_s), 4)) %>%
  pivot_longer(cols = c(Free, Enslaved)) %>%
  select(region, year, name, value) %>%
  rename(group = name, percent = value) %>%
  mutate(region = str_to_upper(region), 
         group = str_to_upper(group))

# Font load
showtext_auto()
font_add(family = 'OCRA', regular = 'OCRAEXT.TTF')

# Initial plot setup
p <-
  ggplot(censusDF) +
  geom_bar(aes(x = percent, y = as.factor(year), fill = group), 
           stat = "identity") +
  facet_wrap(vars(region))

# Quick Peek
p

# Adjusting labels
p <-
  p +
  scale_x_continuous(labels = label_number(suffix = "%", scale = 1e+2)) +
  labs(title = 'PROGRESSION OF EMANCIPATION BY DECADE', 
       subtitle = 'FREE VS ENSLAVED BY REGION', 
       caption = 'DATA SOURCE: US CENSUS ARCHIVES', 
       x = '', 
       y = '', 
       fill = '')

# Quick Peek
p

# Theme adjustments
p <-
  p +
  scale_fill_manual(values = c('#a7ac9d', '#a683a6')) +
  theme_minimal() +
  theme(
    plot.margin = margin(1.5, 2.5, 0.5, 1.75, "cm"),
    text = element_text(family = 'OCRA'), 
    plot.title = element_text(hjust = 0.5, size = 25, face = 'bold'), 
    plot.subtitle = element_text(hjust = 0.5, size = 17),
    axis.text = element_text(size = 13, color = 'black', face = 'bold'), 
    strip.text = element_text(size = 14, face = 'bold'), 
    panel.grid = element_line(color = 'gray'), 
    legend.position = 'top'
  )

# Quick Peek
p

# Adding final background
p <- 
  ggbackground(p, 'C:/Users/Adam Bushman/Documents/background-plot.jpg', 
               by = 'width')
# Final Plot
p

ggsave(filename = 'emancipation-by-decade.jpg', 
       width = 1000, height = 750, units = 'px', dpi = 150)
