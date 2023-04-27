# ------------------------------------------------------------------------------
# VISUALIZATIONS FOR GAM SLIDES
# ------------------------------------------------------------------------------

library(OpenML)
library(ggplot2)
library(data.table)
library(dplyr)
library(mlr3verse)
if (FALSE) remotes::install_github("mlr-org/mlr3extralearners@*release")
if (FALSE) install.packages("gratia")
library(gratia)

# DATA -------------------------------------------------------------------------

bike_data = as.data.table(getOMLDataSet(data.id = 45103)$data)
keep_cols = c("season", "temp", "hum", "windspeed", "rentals")
bike_data = bike_data[, ..keep_cols]
bike_data$rentals = as.numeric(bike_data$rentals)
task = TaskRegr$new("bike", backend = bike_data, target = "rentals")

# MODEL ------------------------------------------------------------------------

mlr3extralearners::install_learners("regr.gam")
learner = lrn("regr.gam")
fml = rentals ~ s(hum, bs = "bs", k = 10) + temp 
learner$param_set$values$formula = fml
learner$train(task)

# PLOTS ------------------------------------------------------------------------

make_theme <- function(p, xlab = "humidity", ylab) {
  p +
    theme_bw() +
    labs(title = "", x = xlab, y = ylab, caption = "")
}

# effect plot

p_smooth = make_theme(draw(learner$model), ylab = "partial effect")
# 
# # basis functions
# 
# x <- seq(0L, 1L, length.out = 50L)
# df <- learner$model$smooth[[1]]$df
# bf_splines = matrix(splines::bs(x, df = df), ncol = df)
# bf_coeffs = learner$model$coefficients[
#   startsWith(names(learner$model$coefficients), "s(hum)")
# ]
# bf_coeffs_mat = matrix(
#   rep(bf_coeffs, length(x)), nrow = length(x), byrow = TRUE
# )
# bf_splines_weighted = bf_splines * bf_coeffs_mat
# dt_splines = data.table(x, bf_splines)
# setnames(dt_splines, c("x", sprintf("b_%s", seq_len(df))))
# dt_splines_long <- data.table::melt(
#   dt_splines, id = "x", measure = sprintf("b_%s", seq_len(df))
# )
# dt_splines_weighted = data.table(x, bf_splines_weighted)
# setnames(dt_splines_weighted, c("x", sprintf("b_%s", seq_len(df))))
# dt_splines_weighted[
#   , y := sum(.SD),
#   .SDcols = sprintf("b_%s", seq_len(df)),
#   by = seq_len(nrow(dt_splines_weighted))
# ]
# dt_splines_long_weighted <- data.table::melt(
#   dt_splines_weighted, id = c("x", "y"), measure = sprintf("b_%s", seq_len(df))
# )
# 
# p_basis = ggplot2::ggplot(
#   dt_splines_long, 
#   ggplot2::aes(x = x, y = value, col = variable)) +
#   ggplot2::geom_line() +
#   ggplot2::ggtitle("cubic B-spline basis") +
#   ggplot2::theme_minimal() +
#   ggplot2::scale_color_viridis_d(end = 0.8) +
#   # ggplot2::guides(col = FALSE) +
#   ggplot2::xlab("") + 
#   ggplot2::ylab("")
# p_basis_weighted = ggplot2::ggplot(
#   dt_splines_long_weighted, 
#   ggplot2::aes(x = x, y = value, col = variable)) +
#   ggplot2::geom_line() +
#   ggplot2::theme_minimal() +
#   ggplot2::scale_color_viridis_d(end = 0.8) +
#   # ggplot2::guides(col = FALSE) + 
#   ggplot2::ggtitle("cubic B-spline basis weighted with coefficients") +
#   ggplot2::xlab("") + 
#   ggplot2::ylab("")
# p_basis_sum = ggplot2::ggplot(
#   dt_splines_long_weighted, 
#   ggplot2::aes(x = x, y = y)) +
#   ggplot2::geom_line() +
#   ggplot2::theme_minimal() +
#   ggplot2::ggtitle("sum of weighted cubic B-splines") + 
#   ggplot2::xlab("") + 
#   ggplot2::ylab("")
# 
# gridExtra::grid.arrange(p_effect, p_basis_sum)
# plot(learner$model$smooth[[1]])
# 
# set.seed(123)
# x = runif(20)
# y = x**3 + rnorm(length(x), sd = 0.1)
# plot(y ~ x)
# mod = mgcv::gam(y ~ s(x, k = 3))
# plot(mod, shade = TRUE)
# mod$coefficients
# mod$smooth
# model_matrix = predict(mod, type = "lpmatrix")
# gratia::basis(mod)
# 
# 
# 
# 
# library("mgcv")
# library("gratia")
# library("dplyr")
# dat <- data_sim("eg1", seed = 4)
# m <- gam(y ~ s(x0) + s(x1) + s(x2, bs = "bs") + s(x3),
#          data = dat, method = "REML")
# ds <- data_slice(m, x2 = evenly(x2, n = 200))
# x2_bs <- basis(m, term = "s(x2)", data = ds)
# 
# # compute values of the spline by summing basis functions at each x2
# x2_spl <- x2_bs |>
#   group_by(x2) |>
#   summarise(spline = sum(value))
# 
# # now plot
# x2_bs |> 
#   ggplot(aes(x = x2, y = value, colour = bf, group = bf)) +
#   geom_line(show.legend = FALSE) +
#   geom_line(aes(x = x2, y = spline), data = x2_spl, linewidth = 1.5,
#             inherit.aes = FALSE) +
#   labs(y = expression(f(x2)), x = "x2")
# draw(x2_bs)

x <- seq(0L, 1L, length.out = 50L)
dgf <- learner$model$smooth[[1]]$df
basis_nodata = basis(s(x, bs = "bs"), data = data.table(x = x, y = 1))
p_basis = make_theme(draw(basis_nodata), xlab = "x", ylab = "B-splines") +
  scale_color_viridis_d() 

p_basis_weighted = make_theme(
  draw(basis(learner$model)), ylab = "weighted B-splines"
) +
  scale_color_viridis_d()
# 
# ds_hum = data_slice(learner$model, hum = evenly(hum, n = 1000))
# bs_hum = basis(learner$model, term = "s(hum)", data = bike_data)
# spline_hum = as.data.table(bs_hum)[
#   , spline := sum(value), by = hum
#   ][, .(hum, spline)]
# spline_hum = unique(spline_hum)
spline_data = as.data.table(ggplot_build(p_basis_weighted)$data)
spline_data = spline_data[, fit := sum(y), by = x][, .(x, fit)]
p_fit = p_basis_weighted +
  geom_line(
    spline_data, 
    mapping = aes(x = x, y = fit), 
    inherit.aes = FALSE,
    linewidth = 1.1
  )
# 
# p_fit = ggplot(bs_hum, aes(x = hum, y = value, col = bf, group = bf)) +
#   geom_line() +
#   geom_line(
#     spline_hum, mapping = aes(x = hum, y = spline), inherit.aes = FALSE
#   )
# p_fit = make_theme(p_fit, ylab = "basis functions / fit")
  
gridExtra::grid.arrange(p_basis, p_basis_weighted, p_fit, ncol = 3)
p_smooth
