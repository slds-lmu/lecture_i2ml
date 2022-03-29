library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(tidyr)
library(colorspace)
library(BBmisc)
library(data.table)
library(penalized)
library(reshape)
library(gridExtra)
library(viridis)
###########################################################

load("regu_example_2.RData")
d_l1 <- rbind(
  data.frame(lam = paste("L1-", lams[1]), coefval = cc_l1_1),
  data.frame(lam = paste("L1-", lams[2]), coefval = cc_l1_2)
)
d_l1$lam <- as.factor(d_l1$lam)
d_l2 <- rbind(
  data.frame(lam = paste("L2-", lams[1]), coefval = cc_l2_1),
  data.frame(lam = paste("L2-", lams[2]), coefval = cc_l2_2)
)
d_l2$lam <- as.factor(d_l2$lam)
plot_coef_hist <- function(d) {
  pl <- ggplot(d, aes(x = coefval, fill = lam)) +
    scale_fill_viridis(end = 0.9, discrete = TRUE) +
    geom_histogram(alpha = 0.9, position = "dodge") +
    theme_gray(base_size = 14)
  return(pl)
}
plot_cv_path <- function(cv_lam, xlab) {
  pl <- ggplot(data = cv_lam, aes(x = lambda, y = mse))
  pl <- pl + geom_line()
  pl <- pl + scale_x_log10()
  pl <- pl + ylim(1, 10)
  pl <- pl + xlab(xlab) + theme_gray(base_size = 14)
}

pl1 <- plot_coef_hist(d_l1) + guides(fill=guide_legend(title="lambda"))
pl2 <- plot_coef_hist(d_l2)+ guides(fill=guide_legend(title="lambda")) +
  ylim(0, 50)
pl3 <- plot_cv_path(cv_l1, "lambda")
pl4 <- plot_cv_path(cv_l2, "lambda")

p <- grid.arrange(pl1, pl2, pl3, pl4, nrow = 2)
ggsave("../figure/shrinkage_2.png", plot = p, width = 8, height = 5)