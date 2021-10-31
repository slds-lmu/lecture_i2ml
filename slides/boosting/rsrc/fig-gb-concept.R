################################################################################
############## Gradient Boosting Concept Plots #################################
################################################################################

# Dependencies------------------------------------------------------------------
library(ggplot2)
library(ggrepel)

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
  geom_line(data=pred_data, aes(x=x, y=y, col="blue"), lty = "dotted") +
  geom_point(data=pred_data, aes(x=x, y=y, col ="blue"))+
  theme(legend.position = "none") +
  scale_color_viridis_d(begin = 0.5)

ggsave("../figure/fig-gb-concept-1.png", pl2, width = 7, height = 3)
# ggsave("figure_man/gradient-boosting.png", pl2)

################################################################################
# former: figure_man/forward-stagewise-expl.png

res = y #- mean(y)
number = seq_along(x)

#label of the points
label = as.character(sapply(number, function(x) bquote(f~( bold(x) ^(.(x))))))

# show label only at some points 
show_label = rep(FALSE, length(label))
show_label[c(3,4,6)] = TRUE


res_data = data.frame(x = x, y = res, label = label, show_label = show_label)
pl_arrow = data.frame(x = x, x_end=x, y = res-0.15, y_end=res+0.15)



pl3 = ggplot(res_data, aes(x=x, y=y)) +
  geom_point(col="blue") +
  geom_line(lty = "dotted", col="blue") +
  geom_segment(data=pl_arrow, aes(x=x, y=y, xend=x, yend=y_end),
               alpha=0.2, arrow=arrow(ends = "both", length = unit(0.13, "inches"))) +
  ylim(y_lim) +
  ylab(expression("Target"~y)) +
  xlab(expression("Feature"~x))

# add labels

pl4 <- pl3 + geom_label_repel(data = res_data[res_data$show_label, ],aes(label = label),
                   box.padding   = 1, 
                   point.padding = 0,
                   #segment.color = 'grey50', 
                   max.overlaps = Inf,
                   nudge_x = 1,
                   nudge_y = .1,
                   segment.curvature = -1e-20,
                   #arrow = arrow(length = unit(0.015, "npc")),
                   parse= TRUE)


ggsave("../figure/fig-gb-concept-2.png", pl4, height = 4, width = 3.3)







