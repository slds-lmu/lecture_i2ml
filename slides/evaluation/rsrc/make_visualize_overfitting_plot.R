library(ggplot2)
library(viridis)
library(gridExtra)

theme_set(theme_minimal())

df <- readRDS("overfitting_peak.rds")

draw_of_heatmap <- function(learner_id) {
  ggplot(df[df$learner_id==learner_id,], aes(dim, sample, fill=of)) +
    scale_x_continuous(trans = "log2") +
    scale_y_continuous(trans = "log2") +
    geom_tile() +
    scale_fill_viridis(end=0.9, name = expression(OF(hat(f),L))) +
    ggtitle(learner_id)
}

plots <- lapply(unique(df[["learner_id"]]), draw_of_heatmap)
p <- grid.arrange(grobs = plots, nrow = 1, ncol = 5)

p

ggsave(filename = "../figure/visualize_overfitting_plot_mlr.png", plot=p, width=18, height=3)