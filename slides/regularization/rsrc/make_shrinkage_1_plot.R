# ------------------------------------------------------------------------------
# FIG: SHRINNKAGE 1
# ------------------------------------------------------------------------------


library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(tidyr)
library(colorspace)
library(BBmisc)
library(penalized)
library(reshape)
library(gridExtra)
library(ggrepel)
library(data.table)
library(viridis)

# DATA -------------------------------------------------------------------------

load("regu_example_1.RData")

# PLOTS ------------------------------------------------------------------------

plot_coef_paths <- function(path, featnames, xlab) {
  ggd <- data.table::melt(path, id.vars = "lambda", measure = featnames, variable.name = "featname", value.name = "coefval")
  ggd$label <- ifelse(ggd$lambda == min(lambda_seq), as.character(ggd$featname), NA)
  pl <- ggplot(data = ggd, aes(x = lambda, y = coefval, group = featname, col = featname)) +
    guides(color = "none") +
    geom_line() +
    geom_label_repel(aes(label = label), na.rm = TRUE, max.overlaps = Inf) +
    scale_color_discrete(guide = FALSE) +
    scale_x_log10() +
    xlab(xlab) +
    theme_bw() +
    scale_color_viridis(end = 0.9, discrete = TRUE)


}

plot_cv_path <- function(cv_lam, xlab) {
  pl <- ggplot(data = cv_lam, aes(x = lambda, y = mse)) +
    geom_line() +
    scale_x_log10() +
    xlab(xlab) +
    theme_minimal()
}

pl1 <- plot_coef_paths(path_l1$path, featnames, "Lasso / lambda")
pl2 <- plot_coef_paths(path_l2$path, featnames, "Ridge / lambda")
pl3 <- plot_cv_path(path_l1$cv_lam, "Lasso / lambda") + ylim(25, 90)
pl4 <- plot_cv_path(path_l2$cv_lam, "Ridge / lambda") + ylim(20, 90)

p <- grid.arrange(pl1, pl2, pl3, pl4, nrow = 2)
ggsave("../figure/shrinkage_1.png", plot = p, width = 8, height = 4)