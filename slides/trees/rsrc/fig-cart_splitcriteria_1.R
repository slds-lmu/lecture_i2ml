# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)

# DATA -------------------------------------------------------------------------

set.seed(1221)
n = 50
data = data.frame(x = seq(-4 , 2, l = n)) %>% 
  mutate(y = ifelse(x < 0, 
                    2.5 + rnorm(n), 
                    2 - 3 * plogis(x) + .5 * rnorm(n)))

datal = subset(data, x < 0)
datar = subset(data, x > 0)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_splitcriteria_2.pdf", width = 8, height = 3)

p1 = ggplot(data) + 
  geom_point(aes(x, y)) + 
  geom_segment(
    aes(x = min(x), xend = max(x), y = mean(y), yend = mean(y)), col = "red") +
  geom_point(aes(x, y), alpha = .5) + 
  theme_light(base_size = 16) + 
  scale_y_continuous(breaks = mean(data$y), labels = "c", ) +
  scale_x_continuous(expression(x[j]), 
                     breaks = NULL,
                     minor_breaks = NULL) + 
  theme(axis.text.y = element_text(colour = "red"),
        panel.grid.major = element_line(colour = NA),
        plot.margin = unit(c(3, 3, 1, 1), "lines")) +
  annotation_custom(
    grob = grid::textGrob(label = "\uD835\uDCA9", 
                          gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(data$x),
    xmax = mean(data$x)) +
  annotation_custom(
    grob = grid::textGrob(label = "\u21E8", 
                          gp = grid::gpar(fontsize = 28)), 
    ymin =  mean(data$y),
    ymax =  mean(data$y) ,
    xmin = max(data$x) + 1,
    xmax = max(data$x) + 1)  +
  coord_cartesian(clip = 'off')

p2 = ggplot(data) + 
  geom_point(aes(x, y)) + 
  geom_segment(data = datal, 
               aes(x = min(x), xend = 0, y = mean(y), yend = mean(y)),
               col = "red") +
  geom_segment(data = datar, 
               aes(x = max(x), xend = 0, y = mean(y), yend = mean(y)),
               col = "red") +
  geom_point(aes(x,y), alpha = .5) + 
  theme_light(base_size = 16) + 
  scale_y_continuous(breaks = c(mean(datal$y), mean(datar$y)), 
                     minor_breaks = NULL,
                     labels = c(expression(c[1]), expression(c[2]))) +
  scale_x_continuous(expression(x[j]), 
                     breaks = NULL) + 
  theme(axis.text.y = element_text(colour = "red"),
        panel.grid.major = element_line(colour = NA),
        plot.margin = unit(c(3, 1, 1, 1), "lines")) +
  annotation_custom(
    grob =  grid::textGrob(label = expression("\uD835\uDCA9"[1]),
                           gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(datal$x),
    xmax = mean(datal$x)) +
  annotation_custom(
    grob = grid::textGrob(label = expression("\uD835\uDCA9"[2]),
                          gp = grid::gpar(fontsize = 18)), 
    ymin =  max(data$y) + 1,
    ymax =  max(data$y) + 1,
    xmin = mean(datar$x),
    xmax = mean(datar$x)) +
  geom_vline(xintercept = 0, lty = 3, alpha = .5) +
  annotation_custom(
    grob = grid::textGrob(label = "t"), 
    ymin =  min(data$y) - .5,
    ymax =  min(data$y) - .5,
    xmin = 0,
    xmax = 0) +
  coord_cartesian(clip = 'off')

gridExtra::grid.arrange(p1, p2, nrow = 1, widths = c(1.2, 1))

ggsave("../figure/cart_splitcriteria_2.pdf", width = 8, height = 3)
dev.off()