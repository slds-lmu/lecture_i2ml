################################################################################
################### Create example data points #################################
################################################################################
library(ggplot2)
library(viridis)

set.seed(8)
n = 15
x = sort(runif(n, 0, 18))
y = sin(x / 2) + rnorm(length(x), 0, sd = 0.1)
pl_data = data.frame(x=x, y=y)

y_lim = c(-1.3,1.3)

theme_set(theme_minimal())
options(ggplot2.continuous.colour="viridis")
options(ggplot2.discrete.colour="viridis")