library(viridis)
library(ggplot2)

theme_set(theme_bw())

df <- data.frame(x=c(0, 0.15, 0.3, 0.5, 0.62, 0.68, 0.85, 1),
                 y=c(0, 0.15, 0.25, 0.28, 0.26, 0.25, 0.15, 0))

p <- ggplot(data=df,aes(x=x,y=y)) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 0.5)) +
  labs(x="PC(+) - Probability Cost",y="Normalized Expected Cost") +
  geom_point(data=df[2:(nrow(df) -1),], shape=21, size=3) +
  geom_line(size=1.3) +
  geom_segment(aes(x=0,y=0,xend=0.5,yend=0.5)) +
  geom_segment(aes(x=0.5,y=0.5,xend=1,yend=0)) +
  geom_segment(aes(x=0.15,y=0,xend=0.15,yend=0.15), linetype="dashed") +
  geom_segment(aes(x=0.85,y=0,xend=0.85,yend=0.15), linetype="dashed")

ggsave("../figure/cost_curve_compare_trivial.png", width=3.5, height=3.5, plot=p)
