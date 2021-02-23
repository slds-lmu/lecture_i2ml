library(ggplot2)
library(gridExtra)
library(bbotk)
library(paradox)
library(mlr3mbo)
library(mlr3)
library(mlr3learners)

## problem setup

branin <- function(xs) c(y = (xs[[2]] - 5.1/(4*pi^2)*xs[[1]]^2 + 5/pi*xs[[1]] - 6)^2 + 
                         10*(1-1/(8*pi))*cos(xs[[1]]) + 10)

domain_names <- c("x1", "x2")

domain <- ParamSet$new(list(
  ParamDbl$new(domain_names[1], -5, 10),
  ParamDbl$new(domain_names[2], 0, 15)
))

plot_res <- 200
x1 <- seq(domain$lower[[1]], domain$upper[[1]], length.out = plot_res)
x2 <- seq(domain$lower[[2]], domain$upper[[2]], length.out = plot_res)

x <- expand.grid(x1, x2)

values <- apply(x, 1, branin)

branin_df <- data.frame(x = x, values = values)
global_mins <- data.frame(x = c(-pi, pi, 9.42478), y = c(12.275, 2.275, 2.475))

bg_plot <- ggplot(branin_df, aes(x = x.Var1, y = x.Var2)) +
  geom_raster(aes(fill=values)) + 
  geom_contour(aes(z=values), bins=25, colour="white", alpha=0.5) +
  geom_point(data = global_mins, aes(x=x, y=y), colour="red", shape=17, size=2) +
  xlab(expression(x[1])) +
  ylab(expression(x[2])) +
  theme(legend.position = "none") 

codomain <- ParamSet$new(list(
  ParamDbl$new("y", tags = "minimize")
))

obfun = ObjectiveRFun$new(
  fun = branin,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

terminator = trm("evals", n_evals = 25)

plots <- list()

## random search

set.seed(123)
instance = OptimInstanceSingleCrit$new(
  objective = obfun,
  terminator = terminator
)
optimizer <- opt("random_search")
optimizer$optimize(instance)
plots[[1]] <- bg_plot +
  geom_point(data=instance$archive$data[, ..domain_names], aes(x=x1, y=x2), colour = "white")  +
  ggtitle("Random search")

## grid search

optimizer <- opt("grid_search", resolution = 5)
instance = OptimInstanceSingleCrit$new(
  objective = obfun,
  terminator = terminator
)
optimizer$optimize(instance)
plots[[2]] <-bg_plot +
  geom_point(data=instance$archive$data[, ..domain_names], aes(x=x1, y=x2), colour = "white") +
  ggtitle("Grid search")

## BO

instance = OptimInstanceSingleCrit$new(
  objective = obfun,
  terminator = terminator
)
design = generate_design_lhs(obfun$domain, 4)$data
instance$eval_batch(design)

surrogate = SurrogateSingleCritLearner$new(learner = lrn("regr.km"))
acqfun = AcqFunctionCB$new(surrogate = surrogate)
acqopt = AcqOptimizer$new(opt("random_search", batch_size = 21), trm("evals", n_evals = 21))
optim <- OptimizerMbo$new(acq_function = acqfun, 
                 loop_function = bayesopt_soo,
                 acq_optimizer = acqopt
                 )
optim$optimize(instance)
plots[[3]] <- bg_plot +
  geom_point(data=instance$archive$data[, ..domain_names], aes(x=x1, y=x2), colour = "white") +
  ggtitle("Bayesian optimization")

bb_cmp <- grid.arrange(grobs = plots, nrow = 1)
ggsave("bb_cmp.pdf", plot = bb_cmp, width = 8, height = 4, units = "in")
