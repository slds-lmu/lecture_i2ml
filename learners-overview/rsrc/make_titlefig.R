# ------------------------------------------------------------------------------
# TITLE FIGURE
# ------------------------------------------------------------------------------

library(OpenML)
library(ggplot2)
library(data.table)
library(mlr3verse)
if (FALSE) remotes::install_github("mlr-org/mlr3extralearners@*release")

if (FALSE) {
  install.packages("reticulate")
  reticulate::install_miniconda()
  reticulate::conda_install("r-reticulate", "python-kaleido")
  reticulate::conda_install("r-reticulate", "plotly", channel = "plotly")
  reticulate::use_miniconda("r-reticulate")
}
library(plotly)
# R might throw an error about not finding the `sys` library -- circumvent with
if (FALSE) reticulate::py_run_string("import sys")

# DATA -------------------------------------------------------------------------

dataset = as.data.table(getOMLDataSet(data.id = 8)$data)
feature_1 = "alkphos"
feature_2 = "gammagt"
keep_cols = c(feature_1, feature_2, "drinks")
dataset = dataset[, ..keep_cols]
task = TaskRegr$new("alcohol_abuse", backend = dataset, target = "drinks")

# MODELS -----------------------------------------------------------------------

learner_cart = lrn("regr.rpart", id = "cart")
learner_nn = lrn("regr.nnet", id = "nn")
learner_nn$param_set$values$size = 50
learners = list(cart = learner_cart, nn = learner_nn)
lapply(learners, function(i) i$train(task))

# PRED SURFACES ----------------------------------------------------------------

x_1 = dataset[, feature_1, with = F]
x_2 = dataset[, feature_2, with = F]
dt = data.table(
  x = dataset[, feature_1, with = F],
  y = dataset[, feature_2, with = F],
  z = dataset[, drinks]
)
setnames(dt, c("x", "y", "z"))

# Prepare base plot
p_pred = plotly_empty(dt, x = ~x, y = ~y, z = ~z) %>%
  add_markers(
    marker = list(
      symbol = "circle", color = "black", showscale = FALSE, size = 1
    )
  )
axis_x1 <- seq(min(x_1), max(x_1), length.out = 500)
axis_x2 <- seq(min(x_2), max(x_2), length.out = 500)

# Add function to plot prediction surface
add_pred_surface <- function(p, pred, my_color, eye) {
  p %>%
    add_trace(
      z = pred,
      x = axis_x1,
      y = axis_x2,
      type = "surface",
      colorbar = list(title = "", ticks = "", nticks = 1),
      colorscale = list(c(0, 1), rep(my_color, 2)),
      opacity = 0.7
    ) %>% 
    hide_colorbar() %>% 
    hide_legend() %>%
    layout(
      scene = list(
        xaxis = list(title = ""), 
        yaxis = list(title = ""),
        zaxis = list(title = ""),
        showlegend = FALSE,
        camera = list(eye = eye)
      )
    )
}

# Prepare plots
mapply(
  function(i, j) {
    surface = expand.grid(x_1 = axis_x1, x_2 = axis_x2, KEEP.OUT.ATTRS = FALSE)
    pred_data = data.table(surface$x_1, surface$x_2)
    setnames(pred_data, c(feature_1, feature_2))
    surface$y = i$predict_newdata(pred_data)$response
    surface = reshape2::acast(surface, x_2 ~ x_1, value.var = "y")
    p = add_pred_surface(p_pred, surface, j, list(x = -1.5, y = -1.5, z = 0.3))
    save_image(p, sprintf("../figure/titlefig_%s.svg", i$id))
  },
  learners,
  c("blue", "orange")
)
