# ------------------------------------------------------------------------------
# FIG: COMPBOOST ILLUSTRATION
# ------------------------------------------------------------------------------

# Purpose: visualize base learner selection in compboost for Boston housing

if (FALSE) devtools::install_github("schalkdaniel/compboost")
library(mlbench)

# DATA -------------------------------------------------------------------------

# Get data

data(BostonHousing)
data_bh <- data.table::as.data.table(na.omit(BostonHousing))

# Re-encode chas as binary variable (bc compboost currently one-hot encodes
# categorical vars, such that we would have a dummy for both levels)

data_bh[, chas := as.numeric(chas) - 1L]

# TRAINING ---------------------------------------------------------------------

# Instantiate & train models - one with linare base learners only, one with both 
# linear and splines (separately bc clones are shallow)

n_iters <- 100L

# Only linear base learners

set.seed(1L)
cwb_linear_bl <- compboost::boostLinear(
  data = data_bh,
  target = "medv",
  loss = compboost::LossQuadratic$new(),
  intercept = TRUE,
  oob_fraction = 0.3,
  iterations = n_iters)

# Flexible base learners

cwb_flexible_bl <- compboost::Compboost$new(
  data = data_bh,
  target = "medv",
  loss = compboost::LossQuadratic$new(),
  oob_fraction = 0.3)

for (i in names(data_bh)[names(data_bh) != "medv"]) {
  cwb_flexible_bl$addBaselearner(
    i, "linear", compboost::BaselearnerPolynomial)
  cwb_flexible_bl$addBaselearner(
    i, "spline", compboost::BaselearnerPSpline, degree = 3L)}

set.seed(2L)
cwb_flexible_bl$train(n_iters)

# PLOTS ------------------------------------------------------------------------

# Get traces of parameter values for linear base learners (slope only)

slopes <- lapply(
  seq_len(n_iters),
  function(i) {
    params <- cwb_linear_bl$model$getParameterAtIteration(i)
    lapply(params, function(j) j[2L, ])})

slopes_unlisted <- lapply(slopes, unlist)
slopes_dt <- lapply(slopes_unlisted, function(i) as.data.frame(t(i)))

slopes_all <- data.table::as.data.table(
  do.call(dplyr::bind_rows, slopes_dt))
slopes_all[, iteration := .I]

slopes_long <- data.table::melt(slopes_all, id = "iteration")
slopes_long[, value := ifelse(is.na(value), 0L, value)]

# Plot development of slopes over time

p_1 <- ggplot2::ggplot(
  slopes_long, 
  ggplot2::aes(x = iteration, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_brewer(palette = "Dark2", name = "base learner") +
  ggplot2::xlab("m") +
  ggplot2::ylab("slope")

# Mark number of selected base learners for 2 different iterations

markers <- c(30L, 90L)

p_2 <- p_1 + 
  ggplot2::geom_vline(xintercept = markers[1L], linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = %i: %i base learners selected",
    markers[1L],
    sum(slopes_long[iteration == markers[1L]]$value != 0)))

p_3 <- p_1 + 
  ggplot2::geom_vline(xintercept = markers[2L], linetype = "dashed") +
  ggplot2::ggtitle(sprintf(
    "mstop = %i: %i base learners selected",
    markers[2L],
    sum(slopes_long[iteration == markers[2L]]$value != 0)))

p_4 <- ggpubr::ggarrange(
  p_2, p_3, ncol = 1L, common.legend = TRUE, legend = "right")

# ------------------------------------------------------------------------------

cwb_flexible_selected <- 
  names(cwb_flexible_bl$model$getParameterAtIteration(n_iters))

pdp <- lapply(
  cwb_flexible_selected,
  function(i) {
    steps <- seq(0L, n_iters, by = 10L)
    cwb_flexible_bl$plot(i, iters = steps) +
      ggplot2::theme_minimal() +
      ggplot2::scale_color_viridis_d(
        end = 0.9, direction = -1L, labels = steps) +
      ggplot2::labs(
        subtitle = "", 
        title = i,
        y = "")})

p_5 <- do.call(
  ggpubr::ggarrange, 
  args = list(
    plotlist = pdp, 
    common.legend = TRUE, 
    legend = "right"))

# ------------------------------------------------------------------------------

ggplot2::ggsave(
  "../figure/compboost-illustration-1.png", p_1, height = 2.2, width = 7L)
ggplot2::ggsave(
  "../figure/compboost-illustration-2.png", p_4, height = 4L, width = 8L)
ggplot2::ggsave(
  "../figure/compboost-illustration-3.png", p_5, height = 4.5, width = 10L)
