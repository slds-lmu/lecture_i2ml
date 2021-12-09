# ------------------------------------------------------------------------------
# FIG: ENTROPY UNIFORM
# ------------------------------------------------------------------------------

library(ggplot2)
library(gridExtra)


# DATA -------------------------------------------------------------------------

entropy_function <- function(g) log(g, base = 2)

g <- seq(2L,10L)
entropy <- entropy_function(g)
data <- as.data.frame(cbind('g' = factor(g), 'H(X)' = entropy))

# PLOTS ------------------------------------------------------------------------

p <- ggplot(data = data, aes(x = g, y = `H(X)`)) +
  geom_bar(stat = "identity") +
  scale_x_discrete(limits = as.character(g))

ggsave("../figure/entropy_uniform_plot.png", width = 6, height = 2)