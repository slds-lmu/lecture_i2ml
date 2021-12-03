library(ggplot2)
library(viridis)
library(gridExtra)

theme_set(theme_minimal())

df <- readRDS("datasets/overfitting.rds")

draw_of_heatmap <- function(learner_id) {
  ggplot(df[df$learner_id==learner_id,], aes(dim, sample, fill=of)) +
    geom_tile() +
    scale_fill_viridis(end=0.9, name = expression(OF(hat(f),L))) +
    ggtitle(learner_id)
}

plots <- lapply(unique(df[["learner_id"]]), draw_of_heatmap)
p <- grid.arrange(grobs = plots, nrow = 1, ncol = 3)

ggsave(filename = "../figure/visualize_overfitting_plot.png", plot=p, width=11, height=3)