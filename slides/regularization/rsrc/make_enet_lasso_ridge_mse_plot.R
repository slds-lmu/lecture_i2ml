# ------------------------------------------------------------------------------
# FIG: ENET LASSO RIDGE MSE BOXPLOT
# ------------------------------------------------------------------------------

library(ggplot2)
library(gridExtra)

# DATA -------------------------------------------------------------------------

load("error_ridge_better.Rda")
load("error_lasso_better.Rda")

# PLOT -------------------------------------------------------------------------

# MSE in boxplot of different algorithms
p1 <- ggplot(data = error_ridge_better, aes(x = error, y = factor(reg))) +
  geom_boxplot() +
  coord_flip() +
  ylab("") +
  xlab("MSE")+
  theme_gray(base_size = 10) +
  theme(legend.position="none",
        axis.title.x=element_blank())

p2 <- ggplot(data = error_lasso_better, aes(x = error, y = factor(reg))) +
  geom_boxplot() +
  coord_flip() +
  ylab("") +
  xlab("MSE")+
  theme_gray(base_size = 10) +
  theme(legend.position="none",
        axis.title.x=element_blank())

p <- grid.arrange(p1, p2 , nrow= 1)

ggsave("../figure/enet_lasso_ridge_mse.png", plot = p, width = 6, height = 2)