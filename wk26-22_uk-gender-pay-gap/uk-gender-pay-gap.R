#####################
# UK Gender Pay Gap #
# TidyTuesday Wk 26 #
# Adam Bushman      #
#####################


library('ggplot2')
library('dplyr')
library('tidyr')
library('stringr')
library('ggdist')
library('showtext')

# Data setup
tuesdata <- 
  tidytuesdayR::tt_load('2022-06-28')$paygap %>%
  pivot_longer(cols = contains('quartile'), names_to = 'gender', values_to = 'percent') %>%
  select(employer_name, gender, percent) %>%
  mutate(
    quartile = str_sub(gender, str_locate(gender, "_")[,1]+1, str_length(gender)-9), 
    gender = str_sub(gender, 1, str_locate(gender, "_")[,1]-1))

tuesdata$quartile = factor(tuesdata$quartile, levels = c("lower", "lower_middle", "upper_middle", "top"))


# Font setup
showtext_auto()
font_add_google("libre baskerville")


# Basic plot
p <- 
  ggplot(tuesdata, aes(x = gender, y = percent)) +
    ggdist::stat_halfeye(
      aes(fill = gender), 
      adjust = .5, 
      width = .6, 
      .width = 0, 
      justification = -.3, 
      point_colour = NA) + 
    geom_boxplot(
      aes(color = gender),
      fill = "transparent",
      size = 1.05, 
      width = .25, 
      outlier.shape = NA, 
      show.legend = FALSE
    ) +
    facet_wrap(vars(quartile), nrow = 1, ncol = 4)

# Quick peek
p


# Custom colors and labels
p <- 
  p +
  scale_fill_manual(values = c("#9C3848", "#4F4789")) +
  scale_color_manual(values = c("#9C3848", "#4F4789")) +
  labs(title = "United Kingdom Gender Pay Gap", 
       subtitle = "Distribution of Reported Corporate Figures", 
       y = "Percent of Gender in Quartile", 
       x = "Salary Quartile", 
       caption = "Data Source: gender-pay-gap.service.gov.uk\n\nVisualization by @adam_bushman", 
       fill = "")

# Quick peek
p



# Custom theme
p +
  theme_minimal() +
  theme(
    # Plot Look
    plot.margin = margin(2, 0.75, 2, 1, "cm"), 
    plot.background = element_rect(fill = "#E0DFE2"), 
    
    # Panel Look
    panel.grid = element_line(color = "#F5F4F5"), 
    
    # Text
    text = element_text(family = "libre baskerville"), 
    plot.title = element_text(hjust = 0.5, size = 22, face = "bold"), 
    plot.subtitle = element_text(hjust = 0.5, size = 13, face = "italic"),
    
    # Facets
    strip.background = element_rect(fill = "#504D56"), 
    strip.text = element_text(color = "#F5F4F5"), 
    
    # Legend
    legend.position = "top", 
    legend.background = element_rect(fill = "#E0DFE2", color = NA), 
    
    # Caption
    plot.caption = element_text(vjust = -5)
  )


# Save plot
ggsave('uk-gender-pay-gap.jpeg', width = 1200, height = 700,
       units = 'px', dpi = 75)
