library(shiny)
library(ggplot2)

find_app_file <- function(filename) {
  candidates <- c(file.path("shiny", "evaluation-02-shiny", filename), filename)
  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0L) {
    stop("Could not find ", filename, " in the Shiny app folder.", call. = FALSE)
  }

  existing[[1L]]
}

range_with_padding <- function(x, padding = 0.06) {
  range_values <- range(x, finite = TRUE)
  width <- diff(range_values)
  if (width == 0) {
    width <- max(abs(range_values), 1)
  }

  range_values + c(-1, 1) * padding * width
}

safe_mean <- function(x) {
  if (length(x) == 0L || all(is.na(x))) {
    return(NA_real_)
  }

  mean(x, na.rm = TRUE)
}

safe_sd <- function(x) {
  if (length(x) <= 1L || all(is.na(x))) {
    return(0)
  }

  sqrt(mean((x - mean(x, na.rm = TRUE))^2, na.rm = TRUE))
}

overfit_axis_limits <- c(-3, 3)

truth_function <- function(x, truth_type) {
  truth_type <- normalize_truth_type(truth_type)

  switch(
    truth_type,
    linear = 0.9 * x,
    nonlinear = sin(1.4 * x) + 0.35 * x,
    wiggly = sin(2.2 * x) + 0.4 * cos(4.1 * x),
    sin(1.4 * x) + 0.35 * x
  )
}

truth_label <- function(truth_type) {
  truth_type <- normalize_truth_type(truth_type)

  switch(
    truth_type,
    linear = "linear DGP",
    nonlinear = "moderately nonlinear DGP",
    wiggly = "highly nonlinear DGP",
    "moderately nonlinear DGP"
  )
}

normalize_truth_type <- function(truth_type) {
  if (
    is.null(truth_type) ||
      length(truth_type) == 0L ||
      is.na(truth_type) ||
      !truth_type %in% c("linear", "nonlinear", "wiggly")
  ) {
    return("nonlinear")
  }

  truth_type
}

normalize_degree <- function(degree) {
  if (is.null(degree) || length(degree) == 0L || is.na(degree)) {
    degree <- 3L
  }

  min(30L, max(0L, as.integer(degree)))
}

normalize_cv_folds <- function(folds) {
  if (is.null(folds) || length(folds) == 0L || is.na(folds)) {
    folds <- 3L
  }

  min(10L, max(2L, as.integer(folds)))
}

normalize_repetitions <- function(repetitions) {
  if (is.null(repetitions) || length(repetitions) == 0L || is.na(repetitions)) {
    repetitions <- 1L
  }

  min(10L, max(1L, as.integer(repetitions)))
}

normalize_count <- function(value, default, minimum, maximum) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- default
  }

  min(maximum, max(minimum, as.integer(value)))
}

normalize_noise <- function(noise) {
  if (is.null(noise) || length(noise) == 0L || is.na(noise)) {
    noise <- 0.7
  }

  min(2.5, max(0, as.numeric(noise)))
}

make_extra_features <- function(n, p) {
  if (p == 0L) {
    return(data.frame(row_id = seq_len(n))[FALSE])
  }

  extra <- as.data.frame(matrix(rnorm(n * p), nrow = n))
  names(extra) <- paste0("z", seq_len(p))
  extra
}

make_overfit_sample <- function(n, noise, p, truth_type, seed) {
  set.seed(seed)

  make_one <- function(count, role) {
    x <- sort(runif(count, min = -3, max = 3))
    signal <- truth_function(x, truth_type)
    y <- signal + rnorm(count, sd = noise)
    data.frame(role = role, x = x, y = y, make_extra_features(count, p))
  }

  list(
    train = make_one(n, "train"),
    test = make_one(800L, "test")
  )
}

polynomial_formula <- function(degree, p) {
  terms <- character()
  if (degree > 0L) {
    terms <- c(terms, paste0("poly(x, ", degree, ", raw = TRUE)"))
  }
  if (p > 0L) {
    terms <- c(terms, paste0("z", seq_len(p)))
  }

  if (length(terms) == 0L) {
    return(y ~ 1)
  }

  as.formula(paste("y ~", paste(terms, collapse = " + ")))
}

fit_overfit_model <- function(train_data, degree, p) {
  suppressWarnings(lm(polynomial_formula(degree, p), data = train_data))
}

prediction_frame <- function(x, p) {
  frame <- data.frame(x = x)
  if (p > 0L) {
    for (feature_index in seq_len(p)) {
      frame[[paste0("z", feature_index)]] <- 0
    }
  }

  frame
}

predict_overfit <- function(model, data) {
  suppressWarnings(as.numeric(predict(model, newdata = data)))
}

mse <- function(actual, predicted) {
  mean((actual - predicted)^2, na.rm = TRUE)
}

overfit_metrics <- function(model, train_data, test_data) {
  data.frame(
    Metric = c("Training MSE", "Test MSE", "Overfit gap"),
    Value = c(
      mse(train_data$y, predict_overfit(model, train_data)),
      mse(test_data$y, predict_overfit(model, test_data)),
      mse(test_data$y, predict_overfit(model, test_data)) -
        mse(train_data$y, predict_overfit(model, train_data))
    )
  )
}

underfitting_proxy <- function(model, p, truth_type) {
  grid <- prediction_frame(
    seq(overfit_axis_limits[1L], overfit_axis_limits[2L], length.out = 401),
    p
  )
  truth <- truth_function(grid$x, truth_type)

  mse(truth, predict_overfit(model, grid))
}

model_complexity_curve <- function(train_data, test_data, p, max_degree = 30L) {
  wide <- model_complexity_values(train_data, test_data, p, max_degree)
  data.frame(
    Degree = rep(wide$Degree, 2L),
    Error = pmax(c(wide$Training, wide$Test), 1e-7),
    Sample = rep(c("Training", "Test"), each = nrow(wide))
  )
}

model_complexity_values <- function(train_data, test_data, p, max_degree = 30L) {
  rows <- vector("list", max_degree + 1L)
  for (degree in 0:max_degree) {
    model <- fit_overfit_model(train_data, degree, p)
    rows[[degree + 1L]] <- data.frame(
      Degree = degree,
      Training = mse(train_data$y, predict_overfit(model, train_data)),
      Test = mse(test_data$y, predict_overfit(model, test_data))
    )
  }

  wide <- do.call(rbind, rows)
  wide$Gap <- wide$Test - wide$Training
  wide
}

overfit_line_bundle <- function(data_bundle, degree, comparison_degree, p, truth_type) {
  model <- fit_overfit_model(data_bundle$train, degree, p)
  comparison_model <- fit_overfit_model(data_bundle$train, comparison_degree, p)
  x_grid <- seq(overfit_axis_limits[1L], overfit_axis_limits[2L], length.out = 401)
  grid <- prediction_frame(x_grid, p)
  grid$truth <- truth_function(x_grid, truth_type)
  grid$fit <- predict_overfit(model, grid)
  grid$comparison_fit <- predict_overfit(comparison_model, grid)

  list(
    model = model,
    comparison_model = comparison_model,
    grid = grid
  )
}

add_overfit_lines <- function(plot, grid, show_oracle, show_blue, show_green) {
  if (isTRUE(show_oracle)) {
    plot <- plot +
      geom_line(
        data = grid,
        aes(x = x, y = truth),
        colour = "orange",
        linewidth = 1.1,
        inherit.aes = FALSE
      )
  }

  if (isTRUE(show_blue)) {
    plot <- plot +
      geom_line(
        data = grid,
        aes(x = x, y = fit),
        colour = "#3366FF",
        linewidth = 1.1,
        inherit.aes = FALSE
      )
  }

  if (isTRUE(show_green)) {
    plot <- plot +
      geom_line(
        data = grid,
        aes(x = x, y = comparison_fit),
        colour = "#00A651",
        linewidth = 1.1,
        inherit.aes = FALSE
      )
  }

  plot
}

overfit_fit_plot <- function(
  data_bundle,
  degree,
  comparison_degree,
  p,
  truth_type,
  show_oracle,
  show_blue,
  show_green
) {
  line_bundle <- overfit_line_bundle(data_bundle, degree, comparison_degree, p, truth_type)
  grid <- line_bundle$grid
  metrics <- overfit_metrics(line_bundle$model, data_bundle$train, data_bundle$test)
  metric_label <- sprintf(
    "Train MSE: %.3f\nTest MSE: %.3f\nGap: %.3f",
    metrics$Value[1L],
    metrics$Value[2L],
    metrics$Value[3L]
  )

  plot <- ggplot(data_bundle$train, aes(x = x, y = y)) +
    geom_point(colour = "black", size = 1.8, alpha = 0.85)
  plot <- add_overfit_lines(plot, grid, show_oracle, show_blue, show_green)

  plot +
    annotate(
      "text",
      x = 2.9,
      y = -2.85,
      label = metric_label,
      hjust = 1,
      vjust = 0,
      size = 3.8
    ) +
    coord_cartesian(xlim = overfit_axis_limits, ylim = overfit_axis_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = "Training data",
      subtitle = paste(
        "Truth:",
        truth_label(truth_type),
        "| blue degree",
        degree,
        "| green degree",
        comparison_degree
      )
    ) +
    theme_classic()
}

overfit_test_data_plot <- function(
  data_bundle,
  degree,
  comparison_degree,
  p,
  truth_type,
  show_oracle,
  show_blue,
  show_green
) {
  line_bundle <- overfit_line_bundle(data_bundle, degree, comparison_degree, p, truth_type)
  plot <- ggplot(data_bundle$test, aes(x = x, y = y)) +
    geom_point(colour = "gray55", size = 1.3, alpha = 0.55)
  plot <- add_overfit_lines(plot, line_bundle$grid, show_oracle, show_blue, show_green)

  plot +
    coord_cartesian(xlim = overfit_axis_limits, ylim = overfit_axis_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = "Test data"
    ) +
    theme_classic()
}

exercise2_fit_plot <- function(data_bundle, degree) {
  p <- 0L
  model <- fit_overfit_model(data_bundle$train, degree, p)
  grid <- exercise2_grid()
  grid$fit <- predict_overfit(model, grid)

  ggplot(data_bundle$train, aes(x = x, y = y)) +
    geom_point(colour = "black", size = 1.8, alpha = 0.85) +
    geom_line(
      data = grid,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = "Learner fit",
      subtitle = paste("Polynomial degree", degree)
    ) +
    theme_classic()
}

overfit_complexity_plot <- function(data_bundle, degree, p, noise) {
  curve <- model_complexity_curve(data_bundle$train, data_bundle$test, p)
  floor_line <- max(noise^2, 1e-7)

  ggplot(curve, aes(x = Degree, y = Error, colour = Sample)) +
    geom_line(linewidth = 1) +
    geom_point(size = 1.4) +
    geom_vline(xintercept = degree, linetype = 2L, colour = "gray35") +
    geom_hline(yintercept = floor_line, linetype = 3L, colour = "orange") +
    scale_y_log10() +
    scale_colour_manual(values = c(Training = "black", Test = "#3366FF")) +
    labs(
      x = "polynomial degree",
      y = "MSE (log scale)",
      colour = NULL,
      title = "Training vs test error",
      subtitle = "Low degree tends to underfit; high degree may overfit"
    ) +
    theme_classic()
}

overfit_single_error_plot <- function(data_bundle, degree, p, noise, sample_type) {
  values <- model_complexity_values(data_bundle$train, data_bundle$test, p)
  y_values <- if (sample_type == "Training") values$Training else values$Test
  plot_data <- data.frame(
    Degree = values$Degree,
    Error = pmax(y_values, 1e-7)
  )
  selected_error <- plot_data$Error[plot_data$Degree == degree]

  ggplot(plot_data, aes(x = Degree, y = Error)) +
    geom_line(colour = "black", linewidth = 1) +
    geom_point(colour = "black", size = 1.4) +
    geom_point(
      data = data.frame(Degree = degree, Error = selected_error),
      aes(x = Degree, y = Error),
      colour = "orange",
      size = 2.6,
      inherit.aes = FALSE
    ) +
    geom_vline(xintercept = degree, linetype = 2L, colour = "gray35") +
    geom_hline(yintercept = max(noise^2, 1e-7), linetype = 3L, colour = "orange") +
    scale_y_log10() +
    labs(
      x = "degree",
      y = "MSE (log scale)",
      title = paste(sample_type, "error")
    ) +
    theme_classic()
}

overfit_gap_plot <- function(data_bundle, degree, p) {
  values <- model_complexity_values(data_bundle$train, data_bundle$test, p)
  plot_data <- data.frame(
    Degree = values$Degree,
    Gap = values$Gap
  )
  selected_gap <- plot_data$Gap[plot_data$Degree == degree]

  ggplot(plot_data, aes(x = Degree, y = Gap)) +
    geom_hline(yintercept = 0, colour = "gray70") +
    geom_line(colour = "black", linewidth = 1) +
    geom_point(colour = "black", size = 1.4) +
    geom_point(
      data = data.frame(Degree = degree, Gap = selected_gap),
      aes(x = Degree, y = Gap),
      colour = "orange",
      size = 2.6,
      inherit.aes = FALSE
    ) +
    geom_vline(xintercept = degree, linetype = 2L, colour = "gray35") +
    labs(
      x = "degree",
      y = "test MSE - training MSE",
      title = "Overfit gap"
    ) +
    theme_classic()
}

overfit_underfitting_plot <- function(data_bundle, degree, p, truth_type, max_degree = 30L) {
  rows <- vector("list", max_degree + 1L)
  for (current_degree in 0:max_degree) {
    model <- fit_overfit_model(data_bundle$train, current_degree, p)
    rows[[current_degree + 1L]] <- data.frame(
      Degree = current_degree,
      Underfitting = pmax(underfitting_proxy(model, p, truth_type), 1e-7)
    )
  }

  plot_data <- do.call(rbind, rows)
  selected_underfitting <- plot_data$Underfitting[plot_data$Degree == degree]

  ggplot(plot_data, aes(x = Degree, y = Underfitting)) +
    geom_line(colour = "black", linewidth = 1) +
    geom_point(colour = "black", size = 1.4) +
    geom_point(
      data = data.frame(Degree = degree, Underfitting = selected_underfitting),
      aes(x = Degree, y = Underfitting),
      colour = "orange",
      size = 2.6,
      inherit.aes = FALSE
    ) +
    geom_vline(xintercept = degree, linetype = 2L, colour = "gray35") +
    scale_y_log10() +
    labs(
      x = "degree",
      y = "mean squared bias (log scale)",
      title = "UF proxy"
    ) +
    theme_classic()
}

overfit_sensitivity_values <- function(variable, degree, n, noise, p, truth_type, seed) {
  x_values <- switch(
    variable,
    n = seq(15L, 300L, by = 5L),
    noise = seq(0, 2.5, by = 0.1),
    p = 0:20,
    stop("Unknown sensitivity variable: ", variable, call. = FALSE)
  )
  selected_value <- switch(variable, n = n, noise = noise, p = p)
  x_values <- sort(unique(c(x_values, selected_value)))

  rows <- lapply(x_values, function(x_value) {
    current_n <- n
    current_noise <- noise
    current_p <- p

    if (variable == "n") {
      current_n <- as.integer(x_value)
    } else if (variable == "noise") {
      current_noise <- as.numeric(x_value)
    } else if (variable == "p") {
      current_p <- as.integer(x_value)
    }

    data_bundle <- make_overfit_sample(
      n = current_n,
      noise = current_noise,
      p = current_p,
      truth_type = truth_type,
      seed = seed
    )
    model <- fit_overfit_model(data_bundle$train, degree, current_p)
    metrics <- overfit_metrics(model, data_bundle$train, data_bundle$test)

    data.frame(
      Parameter = as.numeric(x_value),
      Training = metrics$Value[1L],
      Test = metrics$Value[2L],
      Gap = metrics$Value[3L],
      Underfitting = underfitting_proxy(model, current_p, truth_type)
    )
  })

  do.call(rbind, rows)
}

overfit_sensitivity_pair_values <- function(
  variable,
  degree,
  comparison_degree,
  n,
  noise,
  p,
  truth_type,
  seed
) {
  primary_values <- overfit_sensitivity_values(variable, degree, n, noise, p, truth_type, seed)
  comparison_values <- overfit_sensitivity_values(
    variable,
    comparison_degree,
    n,
    noise,
    p,
    truth_type,
    seed
  )

  rbind(
    data.frame(Model = "Blue", primary_values, check.names = FALSE),
    data.frame(Model = "Green", comparison_values, check.names = FALSE)
  )
}

overfit_sensitivity_plot <- function(values, x_label, selected_value, metric) {
  plot_data <- data.frame(
    Model = values$Model,
    Parameter = values$Parameter,
    Value = values[[metric]]
  )
  use_log_scale <- metric %in% c("Training", "Test", "Underfitting")
  if (use_log_scale) {
    plot_data$Value <- pmax(plot_data$Value, 1e-7)
  }

  selected_data <- do.call(
    rbind,
    lapply(split(plot_data, plot_data$Model), function(model_data) {
      selected_index <- which.min(abs(model_data$Parameter - selected_value))
      model_data[selected_index, , drop = FALSE]
    })
  )
  title <- if (metric == "Gap") {
    "Overfit gap"
  } else if (metric == "Underfitting") {
    "UF proxy"
  } else {
    paste(metric, "error")
  }
  y_label <- if (metric == "Underfitting") {
    "mean squared bias (log scale)"
  } else if (use_log_scale) {
    "MSE (log scale)"
  } else {
    "test MSE - training MSE"
  }

  plot <- ggplot(plot_data, aes(x = Parameter, y = Value, colour = Model)) +
    geom_line(linewidth = 1) +
    geom_point(size = 1.3) +
    geom_point(
      data = selected_data,
      aes(x = Parameter, y = Value, colour = Model),
      size = 2.6,
      inherit.aes = FALSE
    ) +
    geom_vline(xintercept = selected_value, linetype = 2L, colour = "gray35") +
    scale_colour_manual(values = c(Blue = "#3366FF", Green = "#00A651")) +
    labs(
      x = x_label,
      y = y_label,
      colour = NULL,
      title = title
    ) +
    theme_classic()

  if (use_log_scale) {
    plot <- plot + scale_y_log10()
  }

  plot
}

interpretation_table <- function(metrics, comparison_metrics, n, degree, comparison_degree, p, noise) {
  rows <- data.frame(
    Quantity = c(
      "Polynomial degree",
      "Training MSE",
      "Test MSE",
      "Overfit gap"
    ),
    Blue = c(
      degree,
      sprintf("%.3f", metrics$Value[1L]),
      sprintf("%.3f", metrics$Value[2L]),
      sprintf("%.3f", metrics$Value[3L])
    ),
    Green = c(
      comparison_degree,
      sprintf("%.3f", comparison_metrics$Value[1L]),
      sprintf("%.3f", comparison_metrics$Value[2L]),
      sprintf("%.3f", comparison_metrics$Value[3L])
    )
  )

  tagList(
    div(class = "summary-context", paste0("n=", n, ", noise=", noise, ", extra p=", p)),
    tags$table(
      class = "table table-condensed",
      tags$thead(tags$tr(
        tags$th("Quantity"),
        tags$th("Blue fit"),
        tags$th("Green fit")
      )),
      tags$tbody(lapply(seq_len(nrow(rows)), function(i) {
        tags$tr(tags$td(rows$Quantity[i]), tags$td(rows$Blue[i]), tags$td(rows$Green[i]))
      }))
    )
  )
}

exercise2_default_degree <- 12L
exercise2_subsample_train_share <- 2 / 3
exercise2_x_limits <- c(-3, 3)
exercise2_y_limits <- c(-3, 3)

exercise2_grid <- function() {
  prediction_frame(seq(exercise2_x_limits[1L], exercise2_x_limits[2L], length.out = 401), 0L)
}

exercise2_cv_split <- function(data_bundle, folds, rep_index = 1L) {
  folds <- normalize_cv_folds(folds)
  data <- data_bundle$train
  set.seed(9000 + 101L * rep_index + nrow(data) + folds)
  data$Rep <- rep_index
  data$fold <- sample(rep(seq_len(folds), length.out = nrow(data)))
  data
}

exercise2_cv_splits <- function(data_bundle, folds, repetitions) {
  repetitions <- normalize_repetitions(repetitions)

  do.call(rbind, lapply(seq_len(repetitions), function(rep_index) {
    exercise2_cv_split(data_bundle, folds, rep_index)
  }))
}

exercise2_cv_rep_data <- function(split_data, rep_index) {
  split_data[split_data$Rep == rep_index, , drop = FALSE]
}

exercise2_subsample_split <- function(data_bundle, rep_index = 1L) {
  data <- data_bundle$train
  train_n <- min(nrow(data) - 1L, max(2L, floor(exercise2_subsample_train_share * nrow(data))))
  set.seed(11000 + 101L * rep_index + nrow(data))
  train_ids <- sort(sample(seq_len(nrow(data)), train_n))
  data$Rep <- rep_index
  data$sample_role <- ifelse(seq_len(nrow(data)) %in% train_ids, "train", "test")
  data
}

exercise2_subsample_splits <- function(data_bundle, repetitions) {
  repetitions <- normalize_repetitions(repetitions)

  do.call(rbind, lapply(seq_len(repetitions), function(rep_index) {
    exercise2_subsample_split(data_bundle, rep_index)
  }))
}

exercise2_subsample_rep_data <- function(split_data, rep_index) {
  split_data[split_data$Rep == rep_index, , drop = FALSE]
}

exercise2_bootstrap_split <- function(data_bundle, rep_index = 1L) {
  data <- data_bundle$train
  n <- nrow(data)
  set.seed(12000 + 101L * rep_index + n)
  sampled_ids <- sample(seq_len(n), size = n, replace = TRUE)
  oob_ids <- setdiff(seq_len(n), unique(sampled_ids))

  train_data <- data[sampled_ids, , drop = FALSE]
  train_data$original_id <- sampled_ids
  train_data$Rep <- rep_index
  train_data$sample_role <- "train"

  test_data <- data[oob_ids, , drop = FALSE]
  test_data$original_id <- oob_ids
  test_data$Rep <- rep_index
  test_data$sample_role <- "test"

  rbind(train_data, test_data)
}

exercise2_bootstrap_splits <- function(data_bundle, repetitions) {
  repetitions <- normalize_repetitions(repetitions)

  do.call(rbind, lapply(seq_len(repetitions), function(rep_index) {
    exercise2_bootstrap_split(data_bundle, rep_index)
  }))
}

exercise2_bootstrap_rep_data <- function(split_data, rep_index) {
  split_data[split_data$Rep == rep_index, , drop = FALSE]
}

exercise2_fold_plot <- function(split_data, fold_index, test_fold) {
  fold_data <- split_data[split_data$fold == fold_index, , drop = FALSE]
  point_colour <- if (fold_index == test_fold) "gray55" else "black"

  ggplot(fold_data, aes(x = x, y = y)) +
    geom_point(colour = point_colour, size = 1.8, alpha = 0.85) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste("Fold", fold_index)
    ) +
    theme_classic()
}

exercise2_fold_output_id <- function(rep_index, test_fold, fold_index) {
  paste0("exercise2_fold_plot_rep_", rep_index, "_test_", test_fold, "_fold_", fold_index)
}

exercise2_train_output_id <- function(rep_index, test_fold) {
  paste0("exercise2_cv_train_plot_rep_", rep_index, "_test_", test_fold)
}

exercise2_test_output_id <- function(rep_index, test_fold) {
  paste0("exercise2_cv_test_plot_rep_", rep_index, "_test_", test_fold)
}

exercise2_subsample_train_output_id <- function(rep_index) {
  paste0("exercise2_subsample_train_plot_rep_", rep_index)
}

exercise2_subsample_test_output_id <- function(rep_index) {
  paste0("exercise2_subsample_test_plot_rep_", rep_index)
}

exercise2_bootstrap_train_output_id <- function(rep_index) {
  paste0("exercise2_bootstrap_train_plot_rep_", rep_index)
}

exercise2_bootstrap_test_output_id <- function(rep_index) {
  paste0("exercise2_bootstrap_test_plot_rep_", rep_index)
}

exercise2_fit_line_from_train <- function(train_data, degree) {
  model <- fit_overfit_model(train_data, degree, 0L)
  grid <- exercise2_grid()
  grid$fit <- predict_overfit(model, grid)
  grid
}

exercise2_cv_train_plot <- function(split_data, test_fold, degree) {
  train_data <- split_data[split_data$fold != test_fold, , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)

  ggplot(train_data, aes(x = x, y = y)) +
    geom_point(colour = "black", size = 1.8, alpha = 0.85) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste("Training data: folds !=", test_fold)
    ) +
    theme_classic()
}

exercise2_cv_test_plot <- function(split_data, test_fold, degree) {
  train_data <- split_data[split_data$fold != test_fold, , drop = FALSE]
  test_data <- split_data[split_data$fold == test_fold, , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)

  ggplot(test_data, aes(x = x, y = y)) +
    geom_point(colour = "gray55", size = 1.8, alpha = 0.85) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste("Test data: fold", test_fold)
    ) +
    theme_classic()
}

exercise2_subsample_train_plot <- function(split_data, degree) {
  train_data <- split_data[split_data$sample_role == "train", , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)

  ggplot(train_data, aes(x = x, y = y)) +
    geom_point(colour = "black", size = 1.8, alpha = 0.85) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste0("Subsample training data (", nrow(train_data), " obs.)")
    ) +
    theme_classic()
}

exercise2_subsample_test_plot <- function(split_data, degree) {
  train_data <- split_data[split_data$sample_role == "train", , drop = FALSE]
  test_data <- split_data[split_data$sample_role == "test", , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)

  ggplot(test_data, aes(x = x, y = y)) +
    geom_point(colour = "gray55", size = 1.8, alpha = 0.85) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste0("Subsample test data (", nrow(test_data), " obs.)")
    ) +
    theme_classic()
}

exercise2_bootstrap_train_plot <- function(split_data, degree) {
  train_data <- split_data[split_data$sample_role == "train", , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)
  point_data <- aggregate(
    list(Count = train_data$y),
    by = list(x = train_data$x, y = train_data$y),
    FUN = length
  )

  ggplot(point_data, aes(x = x, y = y)) +
    geom_point(aes(size = Count), colour = "black", alpha = 0.7) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    scale_size_continuous(range = c(1.6, 5), breaks = sort(unique(point_data$Count))) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      size = "draws",
      title = paste0("Bootstrap training sample (", nrow(train_data), " draws)")
    ) +
    theme_classic()
}

exercise2_bootstrap_test_plot <- function(split_data, degree) {
  train_data <- split_data[split_data$sample_role == "train", , drop = FALSE]
  test_data <- split_data[split_data$sample_role == "test", , drop = FALSE]
  fit_line <- exercise2_fit_line_from_train(train_data, degree)

  ggplot(test_data, aes(x = x, y = y)) +
    geom_point(colour = "gray55", size = 1.8, alpha = 0.85) +
    geom_line(
      data = fit_line,
      aes(x = x, y = fit),
      colour = "#3366FF",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(xlim = exercise2_x_limits, ylim = exercise2_y_limits, expand = FALSE) +
    labs(
      x = "x",
      y = "y",
      title = paste0("Out-of-bag test data (", nrow(test_data), " obs.)")
    ) +
    theme_classic()
}

exercise2_cv_error_rows <- function(split_data, degree) {
  rows <- lapply(sort(unique(split_data$Rep)), function(rep_index) {
    rep_data <- exercise2_cv_rep_data(split_data, rep_index)

    lapply(rev(sort(unique(rep_data$fold))), function(test_fold) {
      train_data <- rep_data[rep_data$fold != test_fold, , drop = FALSE]
      test_data <- rep_data[rep_data$fold == test_fold, , drop = FALSE]
      model <- fit_overfit_model(train_data, degree, 0L)

      data.frame(
        `Rep.` = rep_index,
        Fold = paste("Fold", test_fold),
        `Train MSE` = mse(train_data$y, predict_overfit(model, train_data)),
        `Test MSE` = mse(test_data$y, predict_overfit(model, test_data)),
        check.names = FALSE
      )
    })
  })

  do.call(rbind, unlist(rows, recursive = FALSE))
}

exercise2_subsample_error_rows <- function(split_data, degree) {
  rows <- lapply(sort(unique(split_data$Rep)), function(rep_index) {
    rep_data <- exercise2_subsample_rep_data(split_data, rep_index)
    train_data <- rep_data[rep_data$sample_role == "train", , drop = FALSE]
    test_data <- rep_data[rep_data$sample_role == "test", , drop = FALSE]
    model <- fit_overfit_model(train_data, degree, 0L)

    data.frame(
      `Rep.` = rep_index,
      Split = paste0("Subsample ", round(100 * exercise2_subsample_train_share), "% train"),
      `Train MSE` = mse(train_data$y, predict_overfit(model, train_data)),
      `Test MSE` = mse(test_data$y, predict_overfit(model, test_data)),
      check.names = FALSE
    )
  })

  do.call(rbind, rows)
}

exercise2_bootstrap_error_rows <- function(split_data, degree) {
  rows <- lapply(sort(unique(split_data$Rep)), function(rep_index) {
    rep_data <- exercise2_bootstrap_rep_data(split_data, rep_index)
    train_data <- rep_data[rep_data$sample_role == "train", , drop = FALSE]
    test_data <- rep_data[rep_data$sample_role == "test", , drop = FALSE]
    model <- fit_overfit_model(train_data, degree, 0L)

    data.frame(
      `Rep.` = rep_index,
      Split = paste0("Bootstrap / OOB (", nrow(test_data), " OOB)"),
      `Train MSE` = mse(train_data$y, predict_overfit(model, train_data)),
      `Test MSE` = mse(test_data$y, predict_overfit(model, test_data)),
      check.names = FALSE
    )
  })

  do.call(rbind, rows)
}

exercise2_error_table <- function(rows) {
  display_rows <- rows
  display_rows$`Train MSE` <- sprintf("%.3f", display_rows$`Train MSE`)
  display_rows$`Test MSE` <- sprintf("%.3f", display_rows$`Test MSE`)

  summary_rows <- as.data.frame(
    matrix("", nrow = 2L, ncol = ncol(display_rows)),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  names(summary_rows) <- names(display_rows)
  summary_rows[[1L]] <- c("Average", "SD")
  summary_rows$`Train MSE` <- sprintf(
    "%.3f",
    c(safe_mean(rows$`Train MSE`), safe_sd(rows$`Train MSE`))
  )
  summary_rows$`Test MSE` <- sprintf(
    "%.3f",
    c(safe_mean(rows$`Test MSE`), safe_sd(rows$`Test MSE`))
  )

  display_rows <- rbind(display_rows, summary_rows)

  tags$table(
    class = "table table-condensed",
    tags$thead(tags$tr(lapply(names(display_rows), tags$th))),
    tags$tbody(lapply(seq_len(nrow(display_rows)), function(i) {
      values <- as.character(display_rows[i, , drop = TRUE])
      if (i > nrow(rows)) {
        return(tags$tr(lapply(values, function(value) tags$td(tags$strong(value)))))
      }

      tags$tr(lapply(values, tags$td))
    }))
  )
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .top-panel-row {
        display: flex;
        align-items: stretch;
      }

      .top-panel-row > [class*='col-'] {
        display: flex;
      }

      .panel-fill {
        width: 100%;
      }

      .control-summary-row {
        margin-top: 16px;
      }

      .settings-column {
        display: flex;
        justify-content: flex-end;
      }

      .summary-column {
        display: flex;
        justify-content: flex-start;
      }

      .settings-panel {
        width: 340px;
        max-width: 100%;
      }

      .summary-panel {
        width: 620px;
        max-width: 100%;
      }

      .summary-panel h3 {
        text-align: left;
        margin-top: 0;
      }

      .summary-context {
        color: #555;
        margin: 0 0 6px 0;
        text-align: left;
      }

      .summary-panel .table {
        width: auto;
        max-width: 100%;
        margin-left: 0;
        margin-right: auto;
      }

      .compact-row {
        display: flex;
        flex-wrap: wrap;
        gap: 10px 14px;
        align-items: flex-end;
      }

      .compact-row .form-group {
        margin-bottom: 0;
      }

      .toggle-box {
        background-color: #fff;
        border: 1px solid #d8dde6;
        padding: 8px 10px;
        margin: 0 0 12px 0;
      }

      .toggle-box .checkbox {
        margin: 0;
      }

      .line-toggle-row {
        align-items: center;
      }

      .line-toggle-row .shiny-input-container {
        width: auto;
      }

      .section-gap {
        height: 216px;
      }

      .cv-fold-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        width: 100%;
      }

      .cv-fold-plot {
        flex: 1 1 160px;
        min-width: 150px;
      }

      .cv-row {
        margin-top: 14px;
      }

      .cv-row-label {
        width: 100%;
        margin: 0 0 4px 0;
        font-weight: 600;
      }

      .resample-repetition-group {
        display: flex;
        align-items: stretch;
        margin-top: 18px;
      }

      .rep-label {
        width: 64px;
        min-width: 64px;
        padding-top: 44px;
        text-align: right;
        font-weight: 700;
      }

      .rep-left-separator {
        border-left: 2px solid #777;
        margin: 0 14px 0 10px;
      }

      .rep-rows {
        flex: 1;
        min-width: 0;
      }

      .cv-separator {
        border-left: 2px solid #b8b8b8;
        height: 316px;
        margin: 30px auto 0 auto;
      }

      @media (max-width: 767px) {
        .top-panel-row {
          display: block;
        }

        .top-panel-row > [class*='col-'] {
          display: block;
        }

        .settings-column,
        .summary-column {
          display: block;
        }

        .settings-panel,
        .summary-panel {
          width: auto;
        }

        .resample-repetition-group {
          display: block;
        }

        .rep-label {
          width: auto;
          min-width: 0;
          padding-top: 0;
          text-align: left;
        }

        .rep-left-separator {
          border-left: 0;
          border-top: 2px solid #777;
          height: 0;
          margin: 8px 0 12px 0;
        }

        .cv-separator {
          border-left: 0;
          border-top: 2px solid #b8b8b8;
          height: 0;
          width: 100%;
          margin: 12px 0;
        }
      }
    "))
  ),
  h2("Exercise 1: Overfitting and underfitting"),
  fluidRow(
    class = "top-panel-row",
    column(
      width = 6,
      plotOutput("overfit_fit_plot", height = "430px")
    ),
    column(
      width = 6,
      plotOutput("overfit_test_data_plot", height = "430px")
    )
  ),
  fluidRow(
    class = "control-summary-row",
    column(
      width = 6,
      class = "settings-column",
      div(
        class = "well settings-panel",
        sliderInput("overfit_degree", "Polynomial degree", min = 0, max = 30, value = 3, step = 1),
        sliderInput(
          "overfit_comparison_degree",
          "Second polynomial degree",
          min = 0,
          max = 30,
          value = 12,
          step = 1
        ),
        sliderInput("overfit_n", "Training observations n", min = 15, max = 300, value = 60, step = 5),
        sliderInput("overfit_noise", "Noise level", min = 0, max = 2.5, value = 0.7, step = 0.1),
        sliderInput("overfit_p", "Irrelevant features p", min = 0, max = 20, value = 0, step = 1),
        selectInput(
          "overfit_truth",
          "Data generating process (DGP)",
          choices = c(
            "linear DGP" = "linear",
            "moderately nonlinear DGP" = "nonlinear",
            "highly nonlinear DGP" = "wiggly"
          ),
          selected = "nonlinear"
        ),
        div(
          class = "toggle-box",
          div(
            class = "compact-row line-toggle-row",
            checkboxInput("overfit_show_oracle", "Oracle", value = TRUE),
            checkboxInput("overfit_show_blue", "Blue", value = TRUE),
            checkboxInput("overfit_show_green", "Green", value = TRUE)
          )
        ),
        actionButton("overfit_resample", "Sample new data")
      )
    ),
    column(
      width = 6,
      class = "summary-column",
      div(
        class = "summary-panel",
        h3("Current model summary"),
        uiOutput("overfit_metrics_table")
      )
    )
  ),
  fluidRow(
    column(
      width = 3,
      plotOutput("overfit_training_error_plot", height = "300px")
    ),
    column(
      width = 3,
      plotOutput("overfit_test_error_plot", height = "300px")
    ),
    column(
      width = 3,
      plotOutput("overfit_gap_plot", height = "300px")
    ),
    column(
      width = 3,
      plotOutput("overfit_underfitting_plot", height = "300px")
    )
  ),
  fluidRow(
    column(
      width = 3,
      plotOutput("overfit_n_training_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_n_test_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_n_gap_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_n_underfitting_plot", height = "260px")
    )
  ),
  fluidRow(
    column(
      width = 3,
      plotOutput("overfit_noise_training_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_noise_test_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_noise_gap_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_noise_underfitting_plot", height = "260px")
    )
  ),
  fluidRow(
    column(
      width = 3,
      plotOutput("overfit_p_training_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_p_test_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_p_gap_plot", height = "260px")
    ),
    column(
      width = 3,
      plotOutput("overfit_p_underfitting_plot", height = "260px")
    )
  ),

  div(class = "section-gap"),

  h2("Exercise 2: Resampling strategies"),
  fluidRow(
    class = "top-panel-row",
    column(
      width = 4,
      div(
        class = "well panel-fill",
        sliderInput(
          "exercise2_sample_size",
          "Sample size",
          min = 15,
          max = 300,
          value = 60,
          step = 5
        ),
        sliderInput(
          "exercise2_degree",
          "Polynomial degree",
          min = 0,
          max = 30,
          value = exercise2_default_degree,
          step = 1
        ),
        selectInput(
          "exercise2_strategy",
          "Resampling strategy",
          choices = c("CV" = "cv", "subsampling" = "subsampling", "Bootstrap" = "bootstrap"),
          selected = "cv"
        ),
        selectInput(
          "exercise2_repetitions",
          "Repetitions",
          choices = as.character(seq_len(10L)),
          selected = "1"
        ),
        conditionalPanel(
          condition = "input.exercise2_strategy == 'cv'",
          numericInput(
            "exercise2_cv_folds",
            "CV folds",
            value = 3,
            min = 2,
            max = 10,
            step = 1,
            width = "100px"
          )
        )
      )
    ),
    column(
      width = 4,
      plotOutput("exercise2_fit_plot", height = "430px")
    ),
    column(
      width = 4,
      uiOutput("exercise2_error_table")
    )
  ),
  conditionalPanel(
    condition = "input.exercise2_strategy == 'cv'",
    uiOutput("exercise2_cv_rows")
  ),
  conditionalPanel(
    condition = "input.exercise2_strategy == 'subsampling'",
    uiOutput("exercise2_subsample_rows")
  ),
  conditionalPanel(
    condition = "input.exercise2_strategy == 'bootstrap'",
    uiOutput("exercise2_bootstrap_rows")
  )
)

server <- function(input, output, session) {
  overfit_seed <- reactiveVal(1L)

  observeEvent(input$overfit_resample, {
    overfit_seed(overfit_seed() + 1L)
  })

  overfit_data <- reactive({
    make_overfit_sample(
      n = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      noise = normalize_noise(input$overfit_noise),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      seed = overfit_seed()
    )
  })

  current_overfit_model <- reactive({
    fit_overfit_model(
      overfit_data()$train,
      degree = normalize_degree(input$overfit_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L)
    )
  })

  output$overfit_fit_plot <- renderPlot({
    overfit_fit_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      comparison_degree = normalize_degree(input$overfit_comparison_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      show_oracle = isTRUE(input$overfit_show_oracle),
      show_blue = isTRUE(input$overfit_show_blue),
      show_green = isTRUE(input$overfit_show_green)
    )
  })

  output$overfit_test_data_plot <- renderPlot({
    overfit_test_data_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      comparison_degree = normalize_degree(input$overfit_comparison_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      show_oracle = isTRUE(input$overfit_show_oracle),
      show_blue = isTRUE(input$overfit_show_blue),
      show_green = isTRUE(input$overfit_show_green)
    )
  })

  output$overfit_training_error_plot <- renderPlot({
    overfit_single_error_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      noise = normalize_noise(input$overfit_noise),
      sample_type = "Training"
    )
  })

  output$overfit_test_error_plot <- renderPlot({
    overfit_single_error_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      noise = normalize_noise(input$overfit_noise),
      sample_type = "Test"
    )
  })

  output$overfit_gap_plot <- renderPlot({
    overfit_gap_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L)
    )
  })

  output$overfit_underfitting_plot <- renderPlot({
    overfit_underfitting_plot(
      overfit_data(),
      degree = normalize_degree(input$overfit_degree),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth
    )
  })

  overfit_n_sensitivity <- reactive({
    overfit_sensitivity_pair_values(
      variable = "n",
      degree = normalize_degree(input$overfit_degree),
      comparison_degree = normalize_degree(input$overfit_comparison_degree),
      n = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      noise = normalize_noise(input$overfit_noise),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      seed = overfit_seed()
    )
  })

  overfit_noise_sensitivity <- reactive({
    overfit_sensitivity_pair_values(
      variable = "noise",
      degree = normalize_degree(input$overfit_degree),
      comparison_degree = normalize_degree(input$overfit_comparison_degree),
      n = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      noise = normalize_noise(input$overfit_noise),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      seed = overfit_seed()
    )
  })

  overfit_p_sensitivity <- reactive({
    overfit_sensitivity_pair_values(
      variable = "p",
      degree = normalize_degree(input$overfit_degree),
      comparison_degree = normalize_degree(input$overfit_comparison_degree),
      n = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      noise = normalize_noise(input$overfit_noise),
      p = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      truth_type = input$overfit_truth,
      seed = overfit_seed()
    )
  })

  output$overfit_n_training_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_n_sensitivity(),
      x_label = "training observations n",
      selected_value = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      metric = "Training"
    )
  })

  output$overfit_n_test_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_n_sensitivity(),
      x_label = "training observations n",
      selected_value = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      metric = "Test"
    )
  })

  output$overfit_n_gap_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_n_sensitivity(),
      x_label = "training observations n",
      selected_value = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      metric = "Gap"
    )
  })

  output$overfit_n_underfitting_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_n_sensitivity(),
      x_label = "training observations n",
      selected_value = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      metric = "Underfitting"
    )
  })

  output$overfit_noise_training_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_noise_sensitivity(),
      x_label = "noise level",
      selected_value = normalize_noise(input$overfit_noise),
      metric = "Training"
    )
  })

  output$overfit_noise_test_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_noise_sensitivity(),
      x_label = "noise level",
      selected_value = normalize_noise(input$overfit_noise),
      metric = "Test"
    )
  })

  output$overfit_noise_gap_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_noise_sensitivity(),
      x_label = "noise level",
      selected_value = normalize_noise(input$overfit_noise),
      metric = "Gap"
    )
  })

  output$overfit_noise_underfitting_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_noise_sensitivity(),
      x_label = "noise level",
      selected_value = normalize_noise(input$overfit_noise),
      metric = "Underfitting"
    )
  })

  output$overfit_p_training_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_p_sensitivity(),
      x_label = "irrelevant features p",
      selected_value = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      metric = "Training"
    )
  })

  output$overfit_p_test_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_p_sensitivity(),
      x_label = "irrelevant features p",
      selected_value = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      metric = "Test"
    )
  })

  output$overfit_p_gap_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_p_sensitivity(),
      x_label = "irrelevant features p",
      selected_value = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      metric = "Gap"
    )
  })

  output$overfit_p_underfitting_plot <- renderPlot({
    overfit_sensitivity_plot(
      overfit_p_sensitivity(),
      x_label = "irrelevant features p",
      selected_value = normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L),
      metric = "Underfitting"
    )
  })

  exercise2_data <- reactive({
    make_overfit_sample(
      n = normalize_count(input$exercise2_sample_size, default = 60L, minimum = 15L, maximum = 300L),
      noise = 0.7,
      p = 0L,
      truth_type = "nonlinear",
      seed = 2026L
    )
  })

  exercise2_cv_data <- reactive({
    exercise2_cv_splits(
      exercise2_data(),
      normalize_cv_folds(input$exercise2_cv_folds),
      normalize_repetitions(input$exercise2_repetitions)
    )
  })

  exercise2_subsample_data <- reactive({
    exercise2_subsample_splits(
      exercise2_data(),
      normalize_repetitions(input$exercise2_repetitions)
    )
  })

  exercise2_bootstrap_data <- reactive({
    exercise2_bootstrap_splits(
      exercise2_data(),
      normalize_repetitions(input$exercise2_repetitions)
    )
  })

  exercise2_degree_value <- reactive({
    normalize_degree(input$exercise2_degree)
  })

  exercise2_strategy_value <- reactive({
    if (identical(input$exercise2_strategy, "bootstrap")) {
      return("bootstrap")
    }

    if (identical(input$exercise2_strategy, "subsampling")) {
      return("subsampling")
    }

    "cv"
  })

  output$exercise2_fit_plot <- renderPlot({
    exercise2_fit_plot(exercise2_data(), exercise2_degree_value())
  })

  output$exercise2_error_table <- renderUI({
    rows <- if (identical(exercise2_strategy_value(), "bootstrap")) {
      exercise2_bootstrap_error_rows(exercise2_bootstrap_data(), exercise2_degree_value())
    } else if (identical(exercise2_strategy_value(), "subsampling")) {
      exercise2_subsample_error_rows(exercise2_subsample_data(), exercise2_degree_value())
    } else {
      exercise2_cv_error_rows(exercise2_cv_data(), exercise2_degree_value())
    }

    exercise2_error_table(rows)
  })

  output$exercise2_cv_rows <- renderUI({
    folds <- normalize_cv_folds(input$exercise2_cv_folds)
    repetitions <- normalize_repetitions(input$exercise2_repetitions)

    tagList(lapply(seq_len(repetitions), function(rep_index) {
      div(
        class = "resample-repetition-group",
        div(class = "rep-label", paste("Rep.", rep_index)),
        div(class = "rep-left-separator"),
        div(
          class = "rep-rows",
          lapply(rev(seq_len(folds)), function(test_fold) {
            fluidRow(
              class = "top-panel-row cv-row",
              column(
                width = 7,
                div(
                  class = "cv-fold-grid",
                  div(class = "cv-row-label", paste("Held-out fold", test_fold)),
                  lapply(seq_len(folds), function(fold_index) {
                    div(
                      class = "cv-fold-plot",
                      plotOutput(
                        exercise2_fold_output_id(rep_index, test_fold, fold_index),
                        height = "300px"
                      )
                    )
                  })
                )
              ),
              column(
                width = 1,
                div(class = "cv-separator")
              ),
              column(
                width = 2,
                plotOutput(exercise2_train_output_id(rep_index, test_fold), height = "300px")
              ),
              column(
                width = 2,
                plotOutput(exercise2_test_output_id(rep_index, test_fold), height = "300px")
              )
            )
          })
        )
      )
    }))
  })

  output$exercise2_subsample_rows <- renderUI({
    repetitions <- normalize_repetitions(input$exercise2_repetitions)

    tagList(lapply(seq_len(repetitions), function(rep_index) {
      div(
        class = "resample-repetition-group",
        div(class = "rep-label", paste("Rep.", rep_index)),
        div(class = "rep-left-separator"),
        div(
          class = "rep-rows",
          fluidRow(
            class = "top-panel-row cv-row",
            column(
              width = 6,
              plotOutput(exercise2_subsample_train_output_id(rep_index), height = "330px")
            ),
            column(
              width = 6,
              plotOutput(exercise2_subsample_test_output_id(rep_index), height = "330px")
            )
          )
        )
      )
    }))
  })

  output$exercise2_bootstrap_rows <- renderUI({
    repetitions <- normalize_repetitions(input$exercise2_repetitions)

    tagList(lapply(seq_len(repetitions), function(rep_index) {
      div(
        class = "resample-repetition-group",
        div(class = "rep-label", paste("Rep.", rep_index)),
        div(class = "rep-left-separator"),
        div(
          class = "rep-rows",
          fluidRow(
            class = "top-panel-row cv-row",
            column(
              width = 6,
              plotOutput(exercise2_bootstrap_train_output_id(rep_index), height = "330px")
            ),
            column(
              width = 6,
              plotOutput(exercise2_bootstrap_test_output_id(rep_index), height = "330px")
            )
          )
        )
      )
    }))
  })

  for (rep_index in seq_len(10L)) {
    local({
      current_rep <- rep_index

      output[[exercise2_bootstrap_train_output_id(current_rep)]] <- renderPlot({
        repetitions <- normalize_repetitions(input$exercise2_repetitions)
        validate(need(current_rep <= repetitions, ""))

        exercise2_bootstrap_train_plot(
          exercise2_bootstrap_rep_data(exercise2_bootstrap_data(), current_rep),
          exercise2_degree_value()
        )
      })

      output[[exercise2_bootstrap_test_output_id(current_rep)]] <- renderPlot({
        repetitions <- normalize_repetitions(input$exercise2_repetitions)
        validate(need(current_rep <= repetitions, ""))

        exercise2_bootstrap_test_plot(
          exercise2_bootstrap_rep_data(exercise2_bootstrap_data(), current_rep),
          exercise2_degree_value()
        )
      })
    })
  }

  for (rep_index in seq_len(10L)) {
    local({
      current_rep <- rep_index

      output[[exercise2_subsample_train_output_id(current_rep)]] <- renderPlot({
        repetitions <- normalize_repetitions(input$exercise2_repetitions)
        validate(need(current_rep <= repetitions, ""))

        exercise2_subsample_train_plot(
          exercise2_subsample_rep_data(exercise2_subsample_data(), current_rep),
          exercise2_degree_value()
        )
      })

      output[[exercise2_subsample_test_output_id(current_rep)]] <- renderPlot({
        repetitions <- normalize_repetitions(input$exercise2_repetitions)
        validate(need(current_rep <= repetitions, ""))

        exercise2_subsample_test_plot(
          exercise2_subsample_rep_data(exercise2_subsample_data(), current_rep),
          exercise2_degree_value()
        )
      })
    })
  }

  for (rep_index in seq_len(10L)) {
    for (test_fold in seq_len(10L)) {
      local({
        current_rep <- rep_index
        current_test_fold <- test_fold

        output[[exercise2_train_output_id(current_rep, current_test_fold)]] <- renderPlot({
          folds <- normalize_cv_folds(input$exercise2_cv_folds)
          repetitions <- normalize_repetitions(input$exercise2_repetitions)
          validate(need(current_rep <= repetitions && current_test_fold <= folds, ""))

          exercise2_cv_train_plot(
            exercise2_cv_rep_data(exercise2_cv_data(), current_rep),
            current_test_fold,
            exercise2_degree_value()
          )
        })

        output[[exercise2_test_output_id(current_rep, current_test_fold)]] <- renderPlot({
          folds <- normalize_cv_folds(input$exercise2_cv_folds)
          repetitions <- normalize_repetitions(input$exercise2_repetitions)
          validate(need(current_rep <= repetitions && current_test_fold <= folds, ""))

          exercise2_cv_test_plot(
            exercise2_cv_rep_data(exercise2_cv_data(), current_rep),
            current_test_fold,
            exercise2_degree_value()
          )
        })
      })
    }
  }

  for (rep_index in seq_len(10L)) {
    for (test_fold in seq_len(10L)) {
      for (fold_index in seq_len(10L)) {
        local({
          current_rep <- rep_index
          current_test_fold <- test_fold
          current_fold <- fold_index

          output[[exercise2_fold_output_id(current_rep, current_test_fold, current_fold)]] <- renderPlot({
            folds <- normalize_cv_folds(input$exercise2_cv_folds)
            repetitions <- normalize_repetitions(input$exercise2_repetitions)
            validate(need(
              current_rep <= repetitions && current_test_fold <= folds && current_fold <= folds,
              ""
            ))

            exercise2_fold_plot(
              exercise2_cv_rep_data(exercise2_cv_data(), current_rep),
              current_fold,
              current_test_fold
            )
          })
        })
      }
    }
  }

  output$overfit_metrics_table <- renderUI({
    data_bundle <- overfit_data()
    degree <- normalize_degree(input$overfit_degree)
    comparison_degree <- normalize_degree(input$overfit_comparison_degree)
    p <- normalize_count(input$overfit_p, default = 0L, minimum = 0L, maximum = 20L)

    comparison_model <- fit_overfit_model(
      data_bundle$train,
      degree = comparison_degree,
      p = p
    )

    interpretation_table(
      overfit_metrics(current_overfit_model(), data_bundle$train, data_bundle$test),
      overfit_metrics(comparison_model, data_bundle$train, data_bundle$test),
      n = normalize_count(input$overfit_n, default = 60L, minimum = 15L, maximum = 300L),
      degree = degree,
      comparison_degree = comparison_degree,
      p = p,
      noise = normalize_noise(input$overfit_noise)
    )
  })
}

shinyApp(ui = ui, server = server)
