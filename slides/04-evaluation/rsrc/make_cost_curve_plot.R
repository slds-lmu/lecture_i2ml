library(viridis)
library(ggplot2)

theme_set(theme_bw())

p <- ggplot() +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 0.5)) +
  labs(x="PC(+) - Probability Cost", y="Normalized Expected Cost") +
  geom_segment(
    aes(x=0,y=0.13,xend=1,yend=0.17, linetype="solid")
  ) +
  geom_segment(
    aes(x=0,y=0.2,xend=1,yend=0.07, linetype="dotted")
  ) +
  theme_bw() +
  theme(legend.position = "none")

ggsave(glue("../figure/cost_curve.png"), width = 3.5, height = 3.5, plot = p)