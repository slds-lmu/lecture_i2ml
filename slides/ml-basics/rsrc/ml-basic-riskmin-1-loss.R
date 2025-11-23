# Loss visualization of L2 and L1

# Libraries
library(vistool)
library(gridExtra)

# Global settings
options(vistool.theme = vistool_theme(
  palette = "plasma",
  text_size = 18,
  point_size = 3.5,
  line_width = 1.4,
  legend_position = "none",
  show_grid = FALSE,
  background = "white"
))

dir.create("figure", showWarnings = FALSE, recursive = TRUE)

# Create data
set.seed(1234)
n <- 15
sd <- 2
eps <- rnorm(n = n, mean = 0, sd = sd)
x <- seq(1, 10, length.out = n)
b0 <- 1.25
b1 <- 0.9
y <- b0 + b1 * x + eps
model_values <- b0 + b1 * x

data <- data.frame(x = x, y = y, model = model_values)
example_idx <- 4L
residuals <- data$y - data$model

model_fun <- function(x_val) b0 + b1 * x_val
model_hypothesis <- hypothesis(fun = model_fun, type = "regr", predictors = "x")

highlight_color <- "#2C7BB6"
x_limits <- range(x) + c(-0.5, 0.5)
y_limits <- range(c(data$y, data$model))
y_padding <- diff(y_limits) * 0.15
if (!is.finite(y_padding) || identical(y_padding, 0)) y_padding <- 1
y_limits <- y_limits + c(-y_padding, y_padding)

residual_limits <- range(residuals)
residual_padding <- diff(residual_limits) * 0.25
if (!is.finite(residual_padding) || identical(residual_padding, 0)) residual_padding <- 1
residual_limits <- residual_limits + c(-residual_padding, residual_padding)

abs_loss_value <- abs(residuals[example_idx])
sq_loss_value <- residuals[example_idx]^2

abs_model_label <- sprintf(
  "L(y, f(x)) = |%.2f - %.2f| = %.2f",
  data$model[example_idx], data$y[example_idx], abs_loss_value
)
sq_model_label <- sprintf(
  "L(y, f(x)) = (%.2f - %.2f)^2 = %.2f",
  data$model[example_idx], data$y[example_idx], sq_loss_value
)

abs_loss_label <- sprintf(
  "Residual r = %.2f -> L(r) = %.2f",
  residuals[example_idx], abs_loss_value
)
sq_loss_label <- sprintf(
  "Residual r = %.2f -> L(r) = %.2f",
  residuals[example_idx], sq_loss_value
)

# Helper functions
build_model_plot <- function(loss_key, annotation_text, title_text) {
  vis <- as_visualizer(
    model_hypothesis,
    domain = list(x = x_limits)
  )

  vis$add_points(
    points = data[, c("x", "y")],
    color = "#333333",
    size = 3.5,
    alpha = 0.9
  )

  if (identical(loss_key, "l2_se")) {
    vis$add_points(
      points = data[example_idx, c("x", "y"), drop = FALSE],
      color = highlight_color,
      size = 4,
      loss = loss_key,
      loss_color = highlight_color,
      loss_fill = highlight_color,
      loss_alpha = 0.25,
      loss_linetype = "solid"
    )
  } else {
    vis$add_points(
      points = data[example_idx, c("x", "y"), drop = FALSE],
      color = highlight_color,
      size = 4,
      loss = loss_key,
      loss_color = highlight_color,
      loss_linetype = "solid"
    )
  }

  x_span <- diff(x_limits)
  if (!is.finite(x_span) || identical(x_span, 0)) x_span <- 1
  y_span <- diff(y_limits)
  if (!is.finite(y_span) || identical(y_span, 0)) y_span <- 1

  annotation_x <- x_limits[1] + 0.05 * x_span
  annotation_y <- y_limits[2] - 0.12 * y_span

  vis$add_annotation(
    text = annotation_text,
    color = highlight_color,
    size = 14,
    x = annotation_x,
    y = annotation_y,
    hjust = 0
  )

  vis$plot(
    show_legend = FALSE,
    plot_title = title_text,
    x_lab = "x",
    y_lab = "y",
    x_limits = x_limits,
    y_limits = y_limits
  )
}

build_loss_plot <- function(loss_key, annotation_text, title_text) {
  loss_obj <- lss(loss_key)
  vis <- as_visualizer(
    loss_obj,
    y_pred = data$model,
    y_true = data$y,
    n_points = 4000L
  )

  vis$add_points(
    x = residuals,
    loss_id = loss_obj$id,
    color = "#444444",
    size = 3,
    alpha = 0.85,
    show_line = TRUE,
    line_color = "#B3B3B3",
    line_alpha = 0.6
  )

  vis$add_points(
    x = residuals[example_idx],
    loss_id = loss_obj$id,
    color = highlight_color,
    size = 4,
    show_line = TRUE,
    line_color = highlight_color,
    line_alpha = 0.85
  )

  loss_fun <- loss_obj$get_fun(vis$input_type)
  loss_grid <- seq(residual_limits[1], residual_limits[2], length.out = 200L)
  loss_values <- loss_fun(loss_grid)
  loss_range <- range(loss_values, na.rm = TRUE)
  if (!is.finite(loss_range[1])) loss_range[1] <- 0
  if (!is.finite(loss_range[2])) loss_range[2] <- max(loss_values, na.rm = TRUE)
  if (!is.finite(loss_range[2])) loss_range[2] <- 1
  loss_height <- diff(loss_range)
  if (!is.finite(loss_height) || identical(loss_height, 0)) loss_height <- 1

  residual_span <- diff(residual_limits)
  if (!is.finite(residual_span) || identical(residual_span, 0)) residual_span <- 1
  annotation_x <- residual_limits[1] + 0.55 * residual_span
  annotation_y <- loss_range[2] - 0.12 * loss_height

  vis$add_annotation(
    text = annotation_text,
    color = highlight_color,
    size = 14,
    x = annotation_x,
    y = annotation_y,
    hjust = 0
  )

  vis$plot(
    show_legend = FALSE,
    plot_title = title_text,
    x_limits = residual_limits
  )
}

create_combined_plot <- function(loss_key, model_label, loss_label, titles) {
  model_plot <- build_model_plot(loss_key, model_label, titles$model)
  loss_plot <- build_loss_plot(loss_key, loss_label, titles$loss)
  gridExtra::arrangeGrob(model_plot, loss_plot, ncol = 2)
}

# Build and save figures
abs_titles <- list(model = "Absolute Loss", loss = "Absolute Loss Function")
sq_titles <- list(model = "Squared Loss", loss = "Squared Loss Function")

abs_combined <- create_combined_plot("l1_ae", abs_model_label, abs_loss_label, abs_titles)
ggplot2::ggsave(
  filename = "figure/ml-basic_riskmin-1-loss_abs.png",
  plot = abs_combined,
  width = 14,
  height = 5,
  units = "in"
)

sq_combined <- create_combined_plot("l2_se", sq_model_label, sq_loss_label, sq_titles)
ggplot2::ggsave(
  filename = "figure/ml-basic_riskmin-1-loss_sqrd.png",
  plot = sq_combined,
  width = 14,
  height = 5,
  units = "in"
)
