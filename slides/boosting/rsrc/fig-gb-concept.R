################################################################################
############## Gradient Boosting Concept Plots #################################
################################################################################

# Dependencies------------------------------------------------------------------
library(ggplot2)

# Load data --------------------------------------------------------------------
source("boosting-example-datapoints.R")

################################################################################
# former: figure_man/gradient-boosting.png


pl1 = ggplot(pl_data, aes(x=x, y=y)) +
  geom_point() +
  ylim(y_lim) +
  ylab(expression("Target"~y)) +
  xlab(expression("Feature"~x))

pred_data = data.frame(x=x, y=mean(y), c="1")

pl2 = pl1 + 
  geom_line(data=pred_data, aes(x=x, y=y, colour=c), lty = "dotted") +
  geom_point(data=pred_data, aes(x=x, y=y, colour=c))+
  theme(legend.position = "none")

ggsave("../figure/fig-gb-concept-1.png", pl2)
# ggsave("figure_man/gradient-boosting.png", pl2)

################################################################################
# former: figure_man/forward-stagewise-expl.png

res = y #- mean(y)
res_data = data.frame(x = x, y = res)
pl_arrow = data.frame(x = x, x_end=x, y = res-0.15, y_end=res+0.15)
pl3 = ggplot(res_data, aes(x=x, y=y)) +
  geom_point(col="red") +
  geom_line(lty = "dotted", col="red") +
  geom_segment(data=pl_arrow, aes(x=x, y=y, xend=x, yend=y_end),
               alpha=0.2, arrow=arrow(ends = "both", length = unit(0.13, "inches"))) +
  ylim(y_lim) +
  ylab(expression("Target"~y)) +
  xlab(expression("Feature"~x))
ggsave("../figure/fig-gb-concept-2.png", pl3)








