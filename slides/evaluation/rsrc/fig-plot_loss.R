# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

source("plot_loss.R")

# DATA -------------------------------------------------------------------------

set.seed(31415)

x = 1:5
y = 2 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)
model = lm(y ~ x)

# PLOT 1 -----------------------------------------------------------------------

# pdf("../figure/plot_abs_loss.pdf", height = 3)

p1 <- plotModAbsoluteLoss(data, model = model, pt_idx = c(1, 4))

ggsave("../figure/plot_abs_loss.pdf", p1, width = 7, height = 2.5)
# dev.off() 

# PLOT 2 -----------------------------------------------------------------------

# pdf("../figure/plot_quad_loss.pdf", height = 2.5)

p2 <- plotModQuadraticLoss(data = data, model = model, pt_idx = c(1, 4))

ggsave("../figure/plot_quad_loss.pdf", p2, width = 7, height = 2.5)
# dev.off() 