library(bbotk)
library(ggplot2)
library(viridis)
library(reshape2)
library(patchwork)

set.seed(7)

objective_func <- function(xs) {
  c(y = - (xs[[1]] - 2)^2 - 1e-6*xs[[2]] + 10)
}
x1_dom = c(-10, 10)
x2_dom = c(1,10)

tuning_data_generator <- function(optimizer_algorithm, n_evals=25, resolution=5) {

  # domain
  domain <- ps(
    x1 = p_dbl(x1_dom[1], x1_dom[2]),
    x2 = p_dbl(x2_dom[1], x2_dom[2])
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

step = 0.1
x1_seq = seq(from = x1_dom[1], to = x1_dom[2], by = step)
x2_seq = seq(from = x2_dom[1], to = x2_dom[2], by = step)
x_dom = expand.grid(x1_seq, x2_seq)
obj = apply(x_dom, 1, objective_func)
obj_df = data.frame(x = x_dom, obj = obj)

rs_p <- ggplot(data = rs_df, mapping = aes(x=x1, y=x2)) +
  geom_contour_filled(data = obj_df, aes(x=x.Var1, y=x.Var2, z=obj)) + 
  labs(fill=expression(g(x[1], x[2]))) +  
  geom_point(shape=21, fill=viridis(1, end=0.9)[1]) +
  geom_rug() +
  xlab(expression(x[1])) +
  ylab(expression(x[2])) + 
  ggtitle("Random Search")

gs_p <- ggplot(data = gs_df, mapping = aes(x=x1, y=x2)) +
  geom_contour_filled(data = obj_df, aes(x=x.Var1, y=x.Var2, z=obj)) +
  labs(fill=expression(g(x[1], x[2]))) +  
  geom_point(shape=21, fill=viridis(1, end=0.9)[1]) +
  geom_rug() +
  xlab(expression(x[1])) +
  ylab(expression(x[2])) + 
  ggtitle("Grid Search") 

performance_p <- ggplot(data = performance_df, mapping = aes(x=iter,y=cummax, color=optimizer)) +
  geom_line() +
  scale_color_viridis(end = 0.9, discrete = TRUE) +
  labs(y="Maximal Target") +
  ggtitle("Performance") 

combined <- rs_p + gs_p & theme(legend.position = "bottom")
p <- combined + plot_layout(guides = "collect") + performance_p

ggsave("../figure/rs_gs_simulation_plot.png", plot=p, width = 12.5, height = 4.73)
