# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# FUNCTIONS --------------------------------------------------------------------

circleFun = function(center = c(0,0), diameter = 1, npoints = 100) {
  
  r = diameter / 2
  tt = seq(0,2 * pi, length.out = npoints)
  xx = center[1L] + r * cos(tt)
  yy = center[2L] + r * sin(tt)
  
  return(data.frame(Sepal.Length = xx, 
                    Sepal.Width = yy, 
                    Species = NA))
  
}

# DATA -------------------------------------------------------------------------

set.seed(600000)

dd = iris %>% 
  filter(between(Sepal.Length, 6.2, 6.6), 
         between(Sepal.Width, 2.9, 3.2)) %>% 
  dplyr::select(Sepal.Length, Sepal.Width, Species)

xnew = c(6.4, 3)

circle.dat = circleFun(xnew, 0.24, npoints = 100)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_knn_1.pdf", width = 8, height = 6)

q = ggplot(dd, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 10) + 
  scale_color_viridis_d(end = .9)
q = q + geom_polygon(data = circle.dat, 
                     alpha = 0.2, 
                     fill = "#619CFF")
q = q + theme(legend.position = c(0.14, 0.82), 
              text = element_text(size = 25))
q = q  + annotate("text", 
                  x = xnew[1], 
                  y = xnew[2], 
                  label = "x[new]", 
                  size = 10, 
                  parse = TRUE)
q

ggsave("../figure/reg_class_knn_1.pdf", width = 8, height = 6)
dev.off()