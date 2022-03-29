

library(qrmix)
library(quantreg)
library(reshape2)
library(ggplot2)

theme_set(theme_minimal())

x <- seq(-2, 2, by = 0.01);
y <- x^2
squared_func <- function(x) x^2
df <- data.frame(x = x, y = y)

p <- ggplot(data = df, aes(x = x)) +
  stat_function(fun = squared_func) +
  geom_point(x = 1, y = 1, color = "red") +
  geom_segment(x = 1, y = 1, xend = 1, yend = 0, color = "red", alpha = 0.5) +
  geom_abline(intercept = -1, slope = 2, color = "red") +
  theme(text = element_text(size = 20L))

p