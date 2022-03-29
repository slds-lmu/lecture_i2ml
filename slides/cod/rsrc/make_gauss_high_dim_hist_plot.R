# ------------------------------------------------------------------------------
# FIG: GAUSS HIGH DIM HIST
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)
library(tidyverse)
library(mvtnorm)
library(gridExtra)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------
x <- seq(from = 0, to = 8, length.out = 1000)

# PLOTS ------------------------------------------------------------------------
plot_p_r_hist <- function(p = 1, n = 1e4){
  X <- rmvnorm(n, rep(0, p))
  ds <- apply(X, 1, function(x) sqrt(sum(x*x)))

  ggplot(data.frame(x = x), aes(x)) +
    ggtitle(paste0("p = ", p)) +
    stat_bin(data = data.frame(ds = ds),
             aes(x = ds, y = stat(count) / sum(count) / width),
             bins = 30, boundary=0) +
    stat_function(fun = function(r) p_r(r=r, p=p), colour="red", size = 1, alpha = 0.8) +
    ylab(NULL) +
    xlab("r") +
    ylim(0, 0.85) +
    theme_minimal()
}

set.seed(123)
p <- grid.arrange(grobs = lapply(c(1,2,20), plot_p_r_hist), ncol=3, left="density")

ggsave(filename = "../figure/gauss_high_dim_hist_plot.png", plot = p, width = 6, height = 2)