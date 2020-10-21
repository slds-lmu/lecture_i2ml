# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)
library(data.table)
library(gridExtra)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPERS ----------------------------------------------------------------------

make_line = function(x, a, b) a * x + b

make_line_plot = function(intercept, slope)  {
  
  # Base
  
  p = ggplot(data.frame(x = c(0, 5)), aes(x))
  
  # Line
  
  p = p + stat_function(
    fun = make_line, 
    args = list(a = slope, b = intercept))
  
  # Marker for intercept
  
  p = p + geom_point(
    data = data.frame(x = 0, y = intercept), 
    aes(x = x, y = y),
    color = "blue",
    size = 4)
  
  p = p + annotate(
    "text",
    x = 0.8,
    y = intercept + 0.3,
    label = expr(paste(theta[0], " = ", !!intercept)),
    size = 4,
    color = "blue")
  
  # Marker for slope
  
  triangle = data.table(
    group = c(1, 1, 1), 
    x = c(1, 2, 2), 
    y = c(intercept + slope, intercept + slope, intercept + 2 * slope)
    )
  
  p = p + geom_polygon(
    triangle, 
    mapping = aes(x = x, y = y, group = group),
    fill = "orange",
    alpha = 0.2)
  
  p = p + annotate(
    "text",
    x = 3,
    y = ifelse(slope < 0, intercept + slope - 0.3, intercept + slope + 0.3),
    label = expr(paste(theta[1], " = ", !!slope)),
    size = 4,
    color = "orange"
  )
  
  # Labs

  p = p + labs(
    title = paste(
      "f(x) = ",
      ifelse(slope == 0, "", slope), 
      "x", 
      " + ", 
      ifelse(intercept == 0, "", intercept)
    ),
    y = "f(x)"
  )
  
  p = p + ylim(0, 5)
  p

}

# PLOT -------------------------------------------------------------------------

pdf("../figure/ml-basics-hs-lin-functions.pdf", width = 8, height = 4)

p_1 = make_line_plot(1, 2)
p_2 = make_line_plot(2, 0)
p_3 = make_line_plot(3, -0.5)
grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/ml-basics-hs-lin-functions.pdf", width = 8, height = 4)
dev.off()