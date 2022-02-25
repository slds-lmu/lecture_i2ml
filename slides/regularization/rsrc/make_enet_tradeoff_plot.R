# ------------------------------------------------------------------------------
# FIG: ENET TRADE-OFF BTW LASSO & RIDGE PLOT
# ------------------------------------------------------------------------------

library(ggplot2)
library(gridExtra)

# DATA -------------------------------------------------------------------------

load("beta_ridge_better.Rda")
load("beta_lasso_better.Rda")

# PLOT -------------------------------------------------------------------------

p1 <- ggplot(data = beta_ridge_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge", trim = FALSE, scale = "width") +
  geom_boxplot(width = 0.4, color = "gray50", alpha = 0.5) +
  coord_flip()+
  facet_grid(reg~.)+
  xlab("value") +
  ylab("index of beta") +
  scale_y_continuous(breaks=1:10)

p2 <- ggplot(data = beta_lasso_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge", trim = FALSE, scale = "width") +
  geom_boxplot(width = 0.4, color = "gray50", alpha = 0.5) +
  coord_flip()+
  facet_grid(reg~.) +
  xlab("value") +
  ylab("index of beta") +
  scale_y_continuous(breaks=1:10)

p <- grid.arrange(p1, p2, nrow=1)

ggsave("../figure/enet_tradeoff.png", plot = p, width = 8, height = 4.5)