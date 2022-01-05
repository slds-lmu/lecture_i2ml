library(bbotk)
library(ggplot2)
library(viridis)
library(gridExtra)
library(reshape2)

set.seed(0)

tuning_data_generator <- function(optimizer_algorithm, n_evals=25, resolution=5) {
  objective_func <- function(xs) {
    c(y = - (xs[[1]] - 2)^2 - 1e-6*xs[[2]] + 10)
  }

  # domain
  domain <- ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(1, 10)
  )

  codomain <- ps(
    y = p_dbl(tags = "maximize")
  )

  objective <- ObjectiveRFun$new(
    fun = objective_func,
    domain = domain,
    codomain = codomain,
    properties = "deterministic"
  )

  terminators <- list(
    evals = trm("evals", n_evals = n_evals)
  )

  term_combo <- TerminatorCombo$new(terminators = terminators)

  instance <- OptimInstanceSingleCrit$new(objective=objective, terminator=term_combo)
  instance

  if (optimizer_algorithm == "grid_search") {
    optimizer <- opt(optimizer_algorithm, resolution=resolution)
  } else {
    optimizer <- opt(optimizer_algorithm)
  }

  optimizer$optimize(instance)
  archive <- instance$archive$data
  archive$cummax <- cummax(archive$y)
  archive
}

rs_df <- tuning_data_generator(optimizer_algorithm = "random_search")
gs_df <- tuning_data_generator(optimizer_algorithm = "grid_search")
performance_df <- melt(data.frame(iter=rs_df$batch_nr, random_search=rs_df$cummax, grid_search=gs_df$cummax),
                       measure.vars = c("random_search", "grid_search"),
                       variable.name = "optimizer",
                       value.name = "cummax"
)

rs_p <- ggplot(data = rs_df, mapping = aes(x=x1, y=x2)) +
  geom_point(shape=21, fill=viridis(1, end=0.9)[1]) +
  geom_rug() +
  ggtitle("Random Search")

gs_p <- ggplot(data = gs_df, mapping = aes(x=x1, y=x2)) +
  geom_point(shape=21, fill=viridis(1, end=0.9)[1]) +
  geom_rug() +
  ggtitle("Grid Search")

performance_p <- ggplot(data = performance_df, mapping = aes(x=iter,y=cummax, color=optimizer)) +
  geom_line() +
  scale_color_viridis(end = 0.9, discrete = TRUE) +
  labs(y="Maximal Target") +
  ggtitle("Performance")

p <- grid.arrange(rs_p, gs_p, performance_p, nrow=1, ncol=3)

ggsave("../figure/rs_gs_simulation_plot.png", plot=p, width = 15, height = 5)