##########################
# Tidy Tuesday | Week 31 #
# Oregon Spotted Frog    #
# Adam BUshman           #
##########################


library('camcorder')
library('tidyverse')
library('scales')
library('flextable')
library('patchwork')
library('jpeg')

# Camcorder Setup
camcorder::gg_record(
  dir = 'C:/Users/Adam Bushman/Pictures/_test', 
  device = "png", 
  width = 16, 
  height = 9, 
  dpi = 300, 
  units = 'cm'
)

# Data Setup
tuesdata <- tidytuesdayR::tt_load('2022-08-02')

freqTable <-
  tuesdata$frogs %>%
  count(HabType, Female = as.factor(Female)) %>%
  pivot_wider(names_from = Female, values_from = n) %>%
  rename(`Habitat Type` = HabType, Male = `0`, Female = `1`)

# attach(tuesdata$frogs)
# t = table(HabType, Female)

results <- 
  chisq.test(t)

valsTable <- 
  freqTable %>%
  mutate(MalePerc = (Male / (Male + Female) * -1), 
         FemalePerc = Female / (Male + Female)) %>%
  pivot_longer(cols = contains('Perc'), names_to = 'Sex', values_to = 'Concentration')



# Data Viz

p1 <- 
  ggplot(valsTable, aes(Concentration, HabType)) +
  geom_bar(aes(fill = Sex), stat = "identity", show.legend = FALSE) +
  scale_fill_manual(values = c("#B83A00", "#1F3300")) + 
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#FFFFFF", color = NA), 
    plot.title = element_text(color = "#683927", hjust = 0.5, face = "bold"), 
    legend.position = "top", 
    axis.title = element_blank(), 
    axis.text.x = element_blank(), 
    axis.text.y = element_text(color = "#683927", face = "bold")
  )
  

df <- 
  data.frame(
    class = c("weak", "significant", "strong"), 
    x = c(rep(NA, 3), rep(NA, 3), 0.10, 0.04, 0.01), 
    y = c(rep("3", 3), rep("2", 3), rep("1", 3))
  ) %>%
  mutate(class = factor(class, levels = c("weak", "significant", "strong")))


p2 <-
  ggplot(df, aes(x, y)) +
  geom_bar(stat = "identity", aes(fill = class), 
           show.legend = FALSE, width = 0.6) +
  xlim(0,0.15) +
  scale_fill_manual(values = c("#683927", "#945238", "#BC6D4E")) +
  annotate("text", x = 0.002, y = "2", hjust = 0, 
           label = expression(paste("Chi-Squared P-Value:  ", 2.326*e^-7)), 
           size = 2,
           color = "#BC6D4E") +
  annotate("text", x = 0.075, y = "3", 
           label = "Probability Male & Female Frog\nHabitat Type Preferences Are the Same", 
           size = 3,
           color = "#683927") +
  geom_segment(aes(x = 2.326/(10^7), y = "2", xend = 2.326/(10^7), yend = "1"),
               arrow = arrow(length = unit(0.15, "cm"))) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#FFFFFF", color = NA), 
    axis.text.y = element_blank(),
    axis.title = element_blank(), 
    panel.grid = element_blank()
  )

  
tbl <- 
  flextable(freqTable) %>%
  color(j = 'Male', color = "#FFFFFF", part = "body") %>%
  bg(j = 'Male', bg = "#1F3300", part = "body") %>%
  color(j = 'Female', color = "#FFFFFF", part = "body") %>%
  bg(j = 'Female', bg = "#B83A00", part = "body") %>%
  as_raster()


t1 <-
  ggplot() +
  theme_void() +
  annotation_custom(grid::rasterGrob(tbl), xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)

pic = readJPEG("oregon-spotted-frog.jpg", native = TRUE)


i1 <- 
  ggplot() +
  theme_void() +
  inset_element(
    pic, 
    top = 1, 
    bottom = 0, 
    right = 1, 
    left = 0
  )

lay = "
B#A
B#A
##D
C#D
C#D
"

i1 + p2 + t1 + p1 +
  plot_layout(widths = c(5, -0.05, 5), 
              heights = c(3, 3, 2, 5, 5), 
              design = lay) +
  plot_annotation(
    title = 'Habitat Preferences by Sex of Oregon Spotted Frogs',
    caption = 'Data Source: USGS\nVisualization by @adam_bushman'
  )


camcorder::gg_stop_recording()
