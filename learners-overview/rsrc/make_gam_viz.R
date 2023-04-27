# ------------------------------------------------------------------------------
# VISUALIZATIONS FOR GAM SLIDES
# ------------------------------------------------------------------------------

library(OpenML)
library(ggplot2)
library(data.table)
library(mlr3verse)
if (FALSE) remotes::install_github("mlr-org/mlr3extralearners@*release")
if (FALSE) install.packages("gratia")
library(gratia)

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

source("libfuns_lm.R")

# DATA -------------------------------------------------------------------------

bike_data = as.data.table(getOMLDataSet(data.id = 45103)$data)
keep_cols = c("temp", "hum", "rentals")
bike_data = bike_data[, ..keep_cols]
bike_data$rentals = as.numeric(bike_data$rentals)
task = TaskRegr$new("bike", backend = bike_data, target = "rentals")

# MODEL ------------------------------------------------------------------------

mlr3extralearners::install_learners("regr.gam")
learner = lrn("regr.gam")
fml = rentals ~ s(hum, bs = "bs", k = 10) + temp 
learner$param_set$values$formula = fml
learner$train(task)

# UNIVARIATE PLOTS -------------------------------------------------------------

make_theme <- function(p, xlab = "humidity", ylab) {
  p +
    theme_bw() +
    labs(title = "", x = xlab, y = ylab, caption = "")
}

# effect plot
p_smooth = make_theme(draw(learner$model), ylab = "partial effect")
ggsave(
  "../figure/gam_bike_partial_effect.pdf", p_smooth, height = 3, width = 4
)

# basis functions
x = seq(0L, 1L, length.out = 50L)
basis_nodata = basis(mgcv::s(x, bs = "bs"), data = data.table(x = x, y = 1))
p_basis = make_theme(draw(basis_nodata), xlab = "x", ylab = "B-splines") +
  scale_color_viridis_d() 

# weighted basis functions
p_basis_weighted = make_theme(
  draw(basis(learner$model)), ylab = "weighted B-splines"
) +
  scale_color_viridis_d()

# weighted basis functions + model fit
spline_data = as.data.table(ggplot_build(p_basis_weighted)$data)
spline_data = spline_data[, fit := sum(y), by = x][, .(x, fit)]
p_fit = p_basis_weighted +
  geom_line(
    spline_data, 
    mapping = aes(x = x, y = fit), 
    inherit.aes = FALSE,
    linewidth = 1.1
  )

p_splines = gridExtra::grid.arrange(p_basis, p_basis_weighted, p_fit, ncol = 3)
ggsave(
  "../figure/gam_bike_spline_basis.pdf", p_splines, height = 2, width = 8
)

# BIVARIATE PLOT ---------------------------------------------------------------

p_pred = plotly_empty(bike_data, x = ~temp, y = ~hum, z = ~rentals) %>%
  add_markers(
    marker = list(
      symbol = "circle", color = "black", showscale = FALSE, size = 1
    )
  )

axis_x1 <- seq(min(bike_data$temp), max(bike_data$temp), length.out = 100)
axis_x2 <- seq(min(bike_data$hum), max(bike_data$hum), length.out = 100)
lm_surface <- expand.grid(
  x_1 = axis_x1, x_2 = axis_x2, KEEP.OUT.ATTRS = F
)
lm_surface$y = predict(
  learner$model, data.frame(temp = lm_surface$x_1, hum = lm_surface$x_2)
)
lm_surface = reshape2::acast(lm_surface, x_2 ~ x_1, value.var = "y")

lm_surface_wiggly = expand.grid(
  x_1 = axis_x1, x_2 = axis_x2, KEEP.OUT.ATTRS = F
)
learner$param_set$values$formula = rentals ~ s(hum, bs = "bs", k = 501) + temp
learner$train(task)
lm_surface_wiggly$y = predict(
  learner$model, 
  data.frame(temp = lm_surface_wiggly$x_1, hum = lm_surface_wiggly$x_2)
)
lm_surface_wiggly = reshape2::acast(
  lm_surface_wiggly, x_2 ~ x_1, value.var = "y"
)

add_hyperplane <- function(p, pred, eye) {
  p %>%
    add_trace(
      z = pred,
      x = axis_x1,
      y = axis_x2,
      type = "surface",
      colorbar = list(
        title = "", 
        ticks = "", 
        nticks = 1
      ),
      colorscale = list(c(0, 1), rep("black", 2)),
      opacity = 0.7
    ) %>% 
    hide_colorbar() %>% 
    hide_legend() %>%
    layout(
      scene = list(
        xaxis = list(title = "temperature"), 
        yaxis = list(title = "humidity"),
        zaxis = list(title = "rentals"),
        showlegend = FALSE,
        camera = list(eye = eye)
      )
    )
}

p_pred_smooth = add_hyperplane(
  p_pred, lm_surface, list(x = -1.5, y = -1.5, z = 0.3)
)
p_pred_wiggly = add_hyperplane(
  p_pred, lm_surface_wiggly, list(x = -2, y = -1, z = 0.4)
)
save_image(p_pred_smooth, "../figure/gam_bike_pred.pdf")
save_image(p_pred_wiggly, "../figure/gam_bike_pred_wiggly.pdf")
