#######################
# European Flights   #
# TidyTuesday Wk 28   #
# Adam Bushman        #
#######################


library('ggplot2')
library('dplyr')
library('tidyr')
library('lubridate')
library('MetBrewer')
library('patchwork')
library('showtext')


###
# Font Setup
###
showtext_auto()
font_add_google("raleway")


###
# Data Setup
###
tuesdata <- tidytuesdayR::tt_load('2022-07-12')

maxDT = max(tuesdata$flights$FLT_DATE)
minDT = min(tuesdata$flights$FLT_DATE)

flights <-
  tuesdata$flights %>%
  mutate(date_group = ifelse(FLT_DATE < ymd("2020-03-07"), "Pre-COVID", 
                             ifelse(FLT_DATE > ymd("2021-10-17"), "Since COVID", "Mid-COVID"))) %>%
  group_by(STATE_NAME, date_group) %>%
  summarise(flt_total = sum(FLT_TOT_1), .groups = "drop") %>%
  rename(state = STATE_NAME) %>%
  pivot_wider(names_from = date_group, values_from = flt_total) %>%
  mutate(pre_covid_PM = `Pre-COVID` / ((interval(minDT, ymd("2020-03-08")) %/% days(1)) / 30.4375), 
         since_covid_PM = `Since COVID` / ((interval(ymd("2021-10-18"), maxDT) %/% days(1)) / 30.4375), 
         recovery_PM = since_covid_PM / pre_covid_PM, 
         group = as.factor(ifelse(recovery_PM < 0.5, "sub-50", ifelse(recovery_PM < 1, "sub-100", "plus-100"))))

flights$group = factor(flights$group, levels = c("sub-50", "sub-100", "plus-100"))

###
# Legend Setup
###

lej <-
  data.frame(
    a = "group", 
    b = 1.1, 
    c = 0.76, 
    d = 0.49
    )

# Basic Legend plot
l <-
  ggplot(lej, aes(ymin = 0, ymax = 1, xmax = 2, xmin = 1)) +
  geom_rect(aes(ymin = 0, ymax = 1, xmax = 2, xmin = 1), fill = "#D9CAB3") +
  geom_segment(aes(y = 1, yend = 1, x = 0.5, xend = 2), 
               color = '#fcfcfc', 
               size = 2) +
  geom_rect(aes(ymin = 0, ymax = b, xmax = 2, xmin = 1.64), fill = "#FFBC42") +
  geom_rect(aes(ymin = 0, ymax = c, xmax = 1.645, xmin = 1.34), fill = "#C45E43") +
  geom_rect(aes(ymin = 0, ymax = d, xmax = 1.345, xmin = 1), fill = "#880044") +
  coord_polar(theta = "y", start = 3*pi/2) +
  xlim(0, 2) + ylim(0, 2) +
  theme_void()

l # Quick peek

# Basic Legend plot
l <- 
  l +
  labs(title = "Reading the Gagues") +
  annotate("text", y = 0, x = 1.166, color = "#880044", label = "<50%", 
           hjust = 1, angle = 90, size = 3) +
  annotate("text", y = 0, x = 1.5, color = "#C45E43", label = "<100%", 
           hjust = 1, angle = 90, size = 4) +
  annotate("text", y = 0, x = 1.833, color = "#FFBC42", label = "Full", 
           hjust = 1, angle = 90, size = 4) +
  annotate("text", y = 1, x = 0.5, color = "#fcfcfc", label = "Full Recovery", 
           hjust = 1, angle = 90, size = 3) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"), 
    text = element_text(family = "raleway", color = "#D9CAB3"),
  )


.###
# Data Setup
###

# Basic setup
p <- 
  ggplot(flights, aes(fill = group, ymin = 0, ymax = recovery_PM, xmax = 2, xmin = 1)) +
  geom_rect(aes(ymin = 0, ymax = 1, xmax = 2, xmin = 1), fill = "#D9CAB3") +
  geom_rect(show.legend = FALSE) +
  geom_segment(aes(y = 1, yend = 1, x = 0.5, xend = 2), 
               color = '#fcfcfc', 
               size = 0.75) +
  coord_polar(theta = "y", start = 3*pi/2) +
  xlim(0, 2) + ylim(0, 2) +
  facet_wrap(~ state, labeller = labeller(state = label_wrap_gen(width = 10)), ncol = 14, nrow = 3) +
  theme_void()

p # Quick peek

# Adding titles, captions
p <-
  p +
  labs(title = "European Airtravel Recovery", 
       subtitle = paste("On March 8th 2020, 15 provinces in Italy were shut down due to the COVID-19 pandemic.\n", 
                        "Most of Europe would follow in the ensuing weeks, haulting airtravel.", 
                        "On October 18th 2021, \nairtravel throughout the continent resumed, but not without difficultiesreturning to former volume.\n", 
                        "The below gagues measure European's country's progress toward full recovery of pre-COVID volume.", 
                        sep = ""), 
       caption = "Data Source: ec.europa.eu\nVisualization by @adam_bushman")

p # Quick peek

# Adding theme
p <-
  p +
  scale_fill_manual(values = c("#880044", "#C45E43", "#FFBC42")) +
  theme(
    plot.margin = margin(2.5, 1.5, 1, 1.5, "cm"), 
    text = element_text(family = "raleway", color = "#D9CAB3"), 
    plot.background = element_rect(fill = "#394032"), 
    plot.title = element_text(size = 18, face = "bold", vjust = 12), 
    plot.subtitle = element_text(size = 11, face = "italic", vjust = 16), 
    plot.caption = element_text(face = "italic")
  )


# Final Plot
p +
  inset_element(
    l, 
    left = 0.15,
    right = 1.55,
    bottom = 0.92, 
    top = 1.5,
  )

