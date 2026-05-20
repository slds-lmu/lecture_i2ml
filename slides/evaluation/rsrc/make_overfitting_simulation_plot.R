library(ggplot2)
library(viridis)
library(gridExtra)
library(scales)

theme_set(theme_minimal())

df <- readRDS("overfitting_peak.rds")

draw_heatmap <- function(learner_id, legend_name=expression(OF(hat(f), L)), fill_col="of") {
  ggplot(df[df$learner_id==learner_id,], aes_string("dim", "sample", fill=fill_col)) +
    scale_x_continuous(trans = "log2",
                       breaks = trans_breaks("log2", function(x) 2^x),
                       labels = trans_format("log2", math_format(2^.x))) +
    scale_y_continuous(trans = "log2",
                       breaks = trans_breaks("log2", function(x) 2^x),
                       labels = trans_format("log2", math_format(2^.x))) +
    geom_tile() +
    xlab("p") +
    ylab("n") +
    scale_fill_viridis(end=0.9, name = legend_name) +
    ggtitle(learner_id)
}

plots_of <- lapply(unique(df[["learner_id"]])[1:5], function(learner_id) draw_heatmap(learner_id))
plots_train_error <- lapply(unique(df[["learner_id"]])[1:5],
                            function(learner_id) draw_heatmap(learner_id, legend_name = expression(R[emp](hat(f), L)), fill_col = "train_error"))
plots_test_error <- lapply(unique(df[["learner_id"]])[1:5],
                            function(learner_id) draw_heatmap(learner_id, legend_name = expression(GE(hat(f), L)), fill_col = "test_error"))
p <- grid.arrange(grobs = c(plots_of, plots_train_error, plots_test_error), nrow = 3, ncol = 5)

ggsave(filename = "../figure/overfitting_simulation_plot.png", plot=p, width=14, height=6.5)

