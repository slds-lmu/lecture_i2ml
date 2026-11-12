library(shiny)
library(ggplot2)

find_app_file <- function(filename) {
  candidates <- c(file.path("shiny", "evaluation-01-shiny", filename), filename)
  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0L) {
    stop("Could not find ", filename, " in the Shiny app folder.", call. = FALSE)
  }

  existing[[1L]]
}

range_with_padding <- function(x, padding = 0.05) {
  range_values <- range(x, finite = TRUE)
  width <- diff(range_values)
  if (width == 0) {
    width <- max(abs(range_values), 1)
  }

  range_values + c(-1, 1) * padding * width
}

set.seed(123)
x_train <- seq(10, 15, length.out = 50)
y_train <- 10 + 3 * sin(0.15 * pi * x_train) + rnorm(length(x_train), sd = 0.5)
data_train <- data.frame(x = x_train, y = y_train)
x_center <- mean(range(x_train))
x_scale <- diff(range(x_train)) / 2
x_plot_limits <- c(9.75, 15.25)
y_plot_limits <- c(4.95, 12.9)
prediction_grid <- data.frame(x = seq(min(x_train), max(x_train), length.out = 401))
prediction_grid$oracle <- 10 + 3 * sin(0.15 * pi * prediction_grid$x)
california_data <- read.csv(find_app_file("california_housing.csv"))
california_x_limits <- range_with_padding(california_data$MedInc)
california_y_limits <- range_with_padding(california_data$MedValue)
california_prediction_grid <- data.frame(
  MedInc = seq(
    min(california_data$MedInc),
    max(california_data$MedInc),
    length.out = 401
  )
)
test_point_colour <- "#00A651"
cali_split_size_values <- seq(0.1, 0.9, by = 0.1)
cali_split_size_labels <- sprintf("%.1f", cali_split_size_values)
normalize_cali_split_size <- function(split_size) {
  if (is.null(split_size) || length(split_size) == 0L || is.na(split_size)) {
    split_size <- 0.1
  }

  split_size <- round(as.numeric(split_size) * 10) / 10
  min(0.9, max(0.1, split_size))
}
empty_results <- data.frame(
  Count = integer(),
  `MAE linear` = numeric(),
  `MAE polynomial` = numeric(),
  `MSE linear` = numeric(),
  `MSE polynomial` = numeric(),
  check.names = FALSE
)
empty_cali_split_results <- data.frame(
  Count = integer(),
  `Split size` = numeric(),
  `Train n` = integer(),
  `Test n` = integer(),
  `Test MSE` = numeric(),
  check.names = FALSE
)

sample_test_data <- function(n) {
  if (is.null(n) || length(n) == 0L || is.na(n)) {
    n <- 50L
  }
  n <- max(1L, min(500L, as.integer(n)))
  x <- runif(n, min = min(x_train), max = max(x_train))
  y <- 10 + 3 * sin(0.15 * pi * x) + rnorm(n, sd = 0.5)

  data.frame(x = x, y = y)
}

fit_models <- function(degree) {
  polynomial_formula <- y ~ poly((x - x_center) / x_scale, degree, raw = TRUE)

  list(
    linear_fit = lm(y ~ x, data = data_train),
    polynomial_fit = lm(polynomial_formula, data = data_train)
  )
}

fit_lines <- function(models) {
  data.frame(
    x = prediction_grid$x,
    oracle = prediction_grid$oracle,
    polynomial = suppressWarnings(
      predict(models$polynomial_fit, newdata = prediction_grid)
    ),
    linear = predict(models$linear_fit, newdata = prediction_grid)
  )
}

compute_errors <- function(models, data) {
  linear_residuals <- data$y - predict(models$linear_fit, newdata = data)
  polynomial_residuals <- data$y - suppressWarnings(
    predict(models$polynomial_fit, newdata = data)
  )

  data.frame(
    `MAE linear` = mean(abs(linear_residuals)),
    `MAE polynomial` = mean(abs(polynomial_residuals)),
    `MSE linear` = mean(linear_residuals^2),
    `MSE polynomial` = mean(polynomial_residuals^2),
    check.names = FALSE
  )
}

add_training_mse_label <- function(plot, models) {
  errors <- compute_errors(models, data_train)
  label_text <- sprintf(
    "MSE linear: %.3f\nMSE polynomial: %.3f",
    errors[["MSE linear"]],
    errors[["MSE polynomial"]]
  )

  plot +
    annotate(
      "text",
      x = x_plot_limits[2L] - 0.04 * diff(x_plot_limits),
      y = y_plot_limits[1L] + 0.04 * diff(y_plot_limits),
      label = label_text,
      hjust = 1,
      vjust = 0,
      size = 4
    )
}

add_fitted_lines <- function(
    plot,
    line_data,
    show_oracle = TRUE,
    show_linear = TRUE,
    show_polynomial = TRUE) {
  if (isTRUE(show_oracle)) {
    plot <- plot +
      geom_line(
        data = line_data,
        aes(x = x, y = oracle),
        colour = "orange",
        linewidth = 1,
        inherit.aes = FALSE
      )
  }

  if (isTRUE(show_polynomial)) {
    plot <- plot +
      geom_line(
        data = line_data,
        aes(x = x, y = polynomial),
        colour = "#3366FF",
        linewidth = 1,
        inherit.aes = FALSE
      )
  }

  if (isTRUE(show_linear)) {
    plot <- plot +
      geom_line(
        data = line_data,
        aes(x = x, y = linear),
        colour = "darkgray",
        linetype = 2L,
        linewidth = 1,
        inherit.aes = FALSE
      )
  }

  plot +
    coord_cartesian(
      xlim = x_plot_limits,
      ylim = y_plot_limits,
      expand = FALSE
    ) +
    labs(
      x = "average number of indictments per month",
      y = "legal expenses in million EUR"
    ) +
    theme_classic()
}

blank_test_plot <- function() {
  ggplot(
    data.frame(
      x = x_plot_limits,
      y = y_plot_limits
    ),
    aes(x = x, y = y)
  ) +
    geom_blank() +
    coord_cartesian(
      xlim = x_plot_limits,
      ylim = y_plot_limits,
      expand = FALSE
    ) +
    labs(
      x = "average number of indictments per month",
      y = "legal expenses in million EUR"
    ) +
    theme_classic()
}

add_polynomial_line <- function(plot, line_data, show_polynomial = TRUE) {
  if (isTRUE(show_polynomial)) {
    plot <- plot +
      geom_line(
        data = line_data,
        aes(x = x, y = polynomial),
        colour = "#3366FF",
        linewidth = 1,
        inherit.aes = FALSE
      )
  }

  plot +
    coord_cartesian(
      xlim = x_plot_limits,
      ylim = y_plot_limits,
      expand = FALSE
    ) +
    labs(
      x = "average number of indictments per month",
      y = "legal expenses in million EUR"
    ) +
    theme_classic()
}

unknown_test_plot <- function() {
  ggplot() +
    annotate(
      "text",
      x = mean(x_plot_limits),
      y = mean(y_plot_limits),
      label = "?",
      colour = "gray50",
      fontface = "bold",
      size = 18
    ) +
    coord_cartesian(
      xlim = x_plot_limits,
      ylim = y_plot_limits,
      expand = FALSE
    ) +
    labs(
      x = "average number of indictments per month",
      y = "legal expenses in million EUR"
    ) +
    theme_classic()
}

cali_line_data <- function() {
  linear_fit <- lm(MedValue ~ MedInc, data = california_data)

  data.frame(
    MedInc = california_prediction_grid$MedInc,
    MedValue = predict(linear_fit, newdata = california_prediction_grid)
  )
}

cali_scatter_plot <- function(show_linear = TRUE, split = NULL, split_enabled = TRUE) {
  plot <- ggplot(california_data, aes(x = MedInc, y = MedValue)) +
    geom_point(alpha = 0.35, size = 0.8)

  if (isTRUE(split_enabled) && !is.null(split)) {
    plot <- plot +
      geom_point(
        data = split$test_data,
        aes(x = MedInc, y = MedValue),
        colour = test_point_colour,
        alpha = 0.75,
        size = 0.9,
        inherit.aes = FALSE
      )
  }

  if (isTRUE(show_linear)) {
    plot <- plot +
      geom_line(
        data = cali_line_data(),
        aes(x = MedInc, y = MedValue),
        colour = "#3366FF",
        linewidth = 1,
        inherit.aes = FALSE
      )
  }

  plot +
    coord_cartesian(
      xlim = california_x_limits,
      ylim = california_y_limits,
      expand = FALSE
    ) +
    labs(
      x = "median income in neighborhood",
      y = "median house value in 100,000 USD"
    ) +
    theme_classic()
}

cali_unknown_test_plot <- function() {
  ggplot() +
    annotate(
      "text",
      x = mean(california_x_limits),
      y = mean(california_y_limits),
      label = "?",
      colour = "gray50",
      fontface = "bold",
      size = 18
    ) +
    coord_cartesian(
      xlim = california_x_limits,
      ylim = california_y_limits,
      expand = FALSE
    ) +
    labs(
      x = "median income in neighborhood",
      y = "median house value in 100,000 USD"
    ) +
    theme_classic()
}

cali_base_split_plot <- function() {
  ggplot(
    data.frame(
      MedInc = california_x_limits,
      MedValue = california_y_limits
    ),
    aes(x = MedInc, y = MedValue)
  ) +
    geom_blank() +
    coord_cartesian(
      xlim = california_x_limits,
      ylim = california_y_limits,
      expand = FALSE
    ) +
    labs(
      x = "median income in neighborhood",
      y = "median house value in 100,000 USD"
    ) +
    theme_classic()
}

cali_blank_split_plot <- function() {
  cali_base_split_plot()
}

cali_empty_split_plot <- function() {
  cali_blank_split_plot()
}

cali_make_split <- function(split_size, sample_random = TRUE) {
  split_size <- normalize_cali_split_size(split_size)
  n_train <- floor(split_size * nrow(california_data))

  if (isTRUE(sample_random)) {
    train_ids <- sort(sample(seq_len(nrow(california_data)), n_train))
  } else {
    train_ids <- order(california_data$MedInc)[seq_len(n_train)]
  }

  test_ids <- setdiff(seq_len(nrow(california_data)), train_ids)

  train_data <- california_data[train_ids, , drop = FALSE]
  test_data <- california_data[test_ids, , drop = FALSE]
  linear_fit <- lm(MedValue ~ MedInc, data = train_data)
  test_predictions <- predict(linear_fit, newdata = test_data)
  test_mse <- mean((test_data$MedValue - test_predictions)^2)

  list(
    split_size = split_size,
    train_ids = train_ids,
    test_ids = test_ids,
    train_data = train_data,
    test_data = test_data,
    linear_fit = linear_fit,
    test_mse = test_mse
  )
}

cali_split_line_data <- function(split) {
  data.frame(
    MedInc = california_prediction_grid$MedInc,
    MedValue = predict(split$linear_fit, newdata = california_prediction_grid)
  )
}

cali_split_plot <- function(data, split, point_colour = "gray50") {
  ggplot(data, aes(x = MedInc, y = MedValue)) +
    geom_point(colour = point_colour, alpha = 0.75, size = 0.8) +
    geom_line(
      data = cali_split_line_data(split),
      aes(x = MedInc, y = MedValue),
      colour = "#3366FF",
      linewidth = 1,
      inherit.aes = FALSE
    ) +
    coord_cartesian(
      xlim = california_x_limits,
      ylim = california_y_limits,
      expand = FALSE
    ) +
    labs(
      x = "median income in neighborhood",
      y = "median house value in 100,000 USD"
    ) +
    theme_classic()
}

cali_split_boxplot <- function(history) {
  plot_data <- data.frame(
    split_size = factor(character(), levels = cali_split_size_labels),
    test_mse = numeric()
  )
  axis_data <- NULL

  if (nrow(history) > 0L) {
    plot_data <- data.frame(
      split_size = factor(
        sprintf("%.1f", round(history$`Split size`, 1)),
        levels = cali_split_size_labels
      ),
      test_mse = history$`Test MSE`
    )
  } else {
    axis_data <- data.frame(
      split_size = factor(
        c(cali_split_size_labels[1L], cali_split_size_labels[length(cali_split_size_labels)]),
        levels = cali_split_size_labels
      ),
      test_mse = c(0, 1)
    )
  }

  ggplot(plot_data, aes(x = split_size, y = test_mse)) +
    geom_blank(data = axis_data, aes(x = split_size, y = test_mse)) +
    geom_boxplot(
      fill = "white",
      colour = "gray35",
      outlier.shape = NA,
      width = 0.5,
      na.rm = TRUE
    ) +
    geom_point(
      colour = "#3366FF",
      alpha = 0.8,
      size = 1.8,
      position = position_jitter(width = 0.08, height = 0),
      na.rm = TRUE
    ) +
    scale_x_discrete(limits = cali_split_size_labels, drop = FALSE) +
    labs(
      x = "split size s",
      y = "test MSE"
    ) +
    theme_classic()
}

styled_history_table <- function(table_data, bold_rows = integer()) {
  row_tags <- vector("list", nrow(table_data))
  for (row_index in seq_len(nrow(table_data))) {
    row_class <- if (row_index %in% bold_rows) "summary-table-row" else NULL
    row_tags[[row_index]] <- tags$tr(
      class = row_class,
      lapply(table_data[row_index, , drop = FALSE], tags$td)
    )
  }

  tags$table(
    class = "table shiny-table table- spacing-s",
    style = "width:auto;",
    tags$thead(
      tags$tr(lapply(names(table_data), tags$th))
    ),
    tags$tbody(row_tags)
  )
}

mse_history_table <- function(history) {
  if (nrow(history) == 0L) {
    return(styled_history_table(history))
  }

  numeric_columns <- names(history)[-1L]
  table_data <- transform(history, Count = as.character(Count))
  table_data[numeric_columns] <- lapply(table_data[numeric_columns], function(x) {
    sprintf("%.3f", as.numeric(x))
  })

  average_row <- data.frame(
    Count = "Average",
    t(colMeans(history[numeric_columns])),
    check.names = FALSE
  )
  names(average_row) <- names(history)
  average_row[numeric_columns] <- lapply(average_row[numeric_columns], function(x) {
    sprintf("%.3f", as.numeric(x))
  })

  blank_row <- as.data.frame(
    as.list(setNames(rep("", ncol(table_data)), names(table_data))),
    check.names = FALSE
  )
  table_data <- rbind(table_data, blank_row, average_row)

  styled_history_table(table_data, bold_rows = nrow(table_data))
}

cali_split_history_table <- function(history) {
  if (nrow(history) == 0L) {
    return(styled_history_table(data.frame(Count = character())))
  }

  split_sizes <- sort(unique(round(history$`Split size`, 1)))
  max_count <- max(vapply(split_sizes, function(split_size) {
    sum(round(history$`Split size`, 1) == split_size)
  }, integer(1)))
  table_data <- data.frame(Count = as.character(seq_len(max_count)))
  average_row <- data.frame(Count = "Average")
  sd_row <- data.frame(Count = "Std. dev.")

  for (split_size in split_sizes) {
    split_values <- history$`Test MSE`[round(history$`Split size`, 1) == split_size]
    column_name <- paste0("Test MSE (s=", sprintf("%.1f", split_size), ")")
    display_values <- rep("", max_count)
    display_values[seq_along(split_values)] <- sprintf("%.3f", split_values)

    table_data[[column_name]] <- display_values
    average_row[[column_name]] <- sprintf("%.3f", mean(split_values))
    split_sd <- sqrt(mean((split_values - mean(split_values))^2))
    sd_row[[column_name]] <- sprintf("%.3f", split_sd)
  }

  blank_row <- as.data.frame(
    as.list(setNames(rep("", ncol(table_data)), names(table_data))),
    check.names = FALSE
  )
  table_data <- rbind(table_data, blank_row, average_row, sd_row)

  styled_history_table(
    table_data,
    bold_rows = c(nrow(table_data) - 1L, nrow(table_data))
  )
}

unknown_error_table <- function() {
  tags$table(
    class = "table shiny-table table- spacing-s",
    style = "width:auto;",
    tags$thead(
      tags$tr(
        tags$th("Count"),
        tags$th("MAE"),
        tags$th("MSE")
      )
    ),
    tags$tbody(
      tags$tr(
        tags$td(class = "unknown-table-cell", "?"),
        tags$td(class = "unknown-table-cell", "?"),
        tags$td(class = "unknown-table-cell", "?")
      )
    )
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

      .top-panel {
        width: 100%;
      }

      .sample-control-row {
        align-items: flex-end;
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 10px;
      }

      .sample-size-control {
        flex: 0 0 92px;
        width: 92px;
      }

      .sample-size-control .form-group {
        margin-bottom: 0;
        width: 92px !important;
      }

      .sample-size-control input {
        width: 92px;
      }

      .sample-action-row {
        display: flex;
        gap: 8px;
        padding-bottom: 1px;
      }

      .split-size-control {
        flex: 1 1 190px;
        min-width: 190px;
      }

      .split-size-control .form-group {
        margin-bottom: 0;
      }

      .toggle-row {
        align-items: center;
        display: flex;
        flex-wrap: wrap;
        gap: 10px 16px;
      }

      .toggle-row .form-group {
        margin-bottom: 0;
      }

      .toggle-row .checkbox {
        margin-bottom: 0;
        margin-top: 0;
      }

      .boxplot-control-row {
        align-items: flex-start;
        display: flex;
        gap: 12px;
      }

      .boxplot-mini-panel {
        flex: 0 0 112px;
        margin-top: 42px;
        width: 112px;
      }

      .boxplot-mini-panel .form-group {
        margin-bottom: 0;
        width: 112px !important;
      }

      .boxplot-mini-panel input {
        width: 112px;
      }

      .boxplot-mini-panel .btn {
        margin-top: 8px;
        width: 112px;
      }

      .boxplot-panel {
        flex: 1 1 auto;
        min-width: 0;
      }

      .dgp-panel {
        align-items: center;
        background-color: #fff3dc;
        border-color: #f0ad4e;
        display: flex;
        flex-direction: column;
        justify-content: center;
      }

      .dgp-title {
        color: #a86400;
        font-size: 16px;
        font-weight: 600;
        margin: 0 0 4px 0;
        text-align: center;
      }

      .dgp-description {
        color: #8a5a12;
        font-size: 12px;
        margin: 0 0 12px 0;
        text-align: center;
      }

      .dgp-formula {
        color: #d98200;
        font-size: 22px;
        text-align: center;
        width: 100%;
      }

      .dgp-question {
        color: #d98200;
        font-size: 52px;
        font-weight: 700;
        line-height: 1;
        text-align: center;
        width: 100%;
      }

      .unknown-table-cell {
        color: gray;
        font-weight: 700;
        text-align: center;
      }

      .summary-table-row {
        font-weight: 700;
      }

      .exercise-separator {
        height: 240px;
      }

      @media (max-width: 767px) {
        .top-panel-row {
          display: block;
        }

        .top-panel-row > [class*='col-'] {
          display: block;
        }
      }
    "))
  ),
  titlePanel("Exercise 1: Evaluating regression learners"),
  fluidRow(
    class = "top-panel-row",
    column(
      width = 4,
      offset = 2,
      div(
        class = "well top-panel dgp-panel",
        div(class = "dgp-title", "Oracle DGP"),
        withMathJax(
          div(
            class = "dgp-formula",
            "\\[f(x) = 10 + 3\\sin(0.15\\pi x)\\]"
          )
        )
      )
    ),
    column(
      width = 4,
      div(
        class = "well top-panel",
        sliderInput(
          inputId = "degree",
          label = "Polynomial degree",
          min = 1,
          max = 60,
          value = 21,
          step = 1
        ),
        div(
          class = "sample-control-row",
          div(
            class = "sample-size-control",
            numericInput(
              inputId = "sample_size",
              label = "Sample size",
              value = 50,
              min = 1,
              max = 500,
              step = 1,
              width = "92px"
            )
          ),
          div(
            class = "sample-action-row",
            actionButton(
              inputId = "sample",
              label = "Sample"
            ),
            actionButton(
              inputId = "reset",
              label = "Reset"
            )
          )
        ),
        div(
          class = "toggle-row",
          checkboxInput(
            inputId = "show_oracle",
            label = "Oracle DGP",
            value = TRUE
          ),
          checkboxInput(
            inputId = "show_linear",
            label = "Linear fit",
            value = TRUE
          ),
          checkboxInput(
            inputId = "show_polynomial",
            label = "Polynomial fit",
            value = TRUE
          ),
          checkboxInput(
            inputId = "show_test_plot",
            label = "Show test plot",
            value = TRUE
          )
        )
      )
    )
  ),
  fluidRow(
    column(
      width = 4,
      h3("Training data"),
      plotOutput("regression_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Test data"),
      plotOutput("test_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Error history"),
      uiOutput("mse_table")
    )
  ),
  div(class = "exercise-separator"),
  h2("Exercise 2: Importance of train-test split"),
  fluidRow(
    class = "top-panel-row",
    column(
      width = 4,
      offset = 2,
      div(
        class = "well top-panel dgp-panel",
        div(class = "dgp-title", "Oracle DGP"),
        div(class = "dgp-question", "?")
      )
    ),
    column(
      width = 4,
      div(
        class = "well top-panel",
        div(
          class = "sample-control-row",
          div(
            class = "split-size-control",
            sliderInput(
              inputId = "cali_split_size",
              label = "Split size",
              min = 0.1,
              max = 0.9,
              value = 0.1,
              step = 0.1
            )
          ),
          div(
            class = "sample-action-row",
            actionButton(
              inputId = "cali_sample",
              label = "Sample"
            ),
            actionButton(
              inputId = "cali_reset",
              label = "Reset"
            )
          )
        ),
        div(
          class = "toggle-row",
          checkboxInput(
            inputId = "cali_show_linear",
            label = "Linear fit",
            value = TRUE
          ),
          checkboxInput(
            inputId = "cali_split_enabled",
            label = "Split data",
            value = TRUE
          ),
          checkboxInput(
            inputId = "cali_sample_random",
            label = "Sample at random",
            value = TRUE
          )
        )
      )
    )
  ),
  fluidRow(
    column(
      width = 4,
      h3("Training data"),
      plotOutput("unknown_regression_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Test data"),
      plotOutput("unknown_test_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Error history"),
      uiOutput("unknown_error_table")
    )
  ),
  fluidRow(
    column(
      width = 4,
      h3("Train split"),
      plotOutput("cali_train_split_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Test split"),
      plotOutput("cali_test_split_plot", height = "420px")
    ),
    column(
      width = 4,
      h3("Split history"),
      uiOutput("cali_split_table")
    )
  ),
  fluidRow(
    column(
      width = 8,
      offset = 2,
      div(
        class = "boxplot-control-row",
        div(
          class = "boxplot-mini-panel",
          numericInput(
            inputId = "cali_split_size_mini",
            label = "Sample size",
            value = 0.1,
            min = 0.1,
            max = 0.9,
            step = 0.1,
            width = "112px"
          ),
          actionButton(
            inputId = "cali_sample_mini",
            label = "Sample"
          )
        ),
        div(
          class = "boxplot-panel",
          h3("Test MSE by split size"),
          plotOutput("cali_split_boxplot", height = "420px")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  test_data <- reactiveVal(sample_test_data(50))
  mse_history <- reactiveVal(empty_results)
  cali_current_split <- reactiveVal(NULL)
  cali_split_history <- reactiveVal(empty_cali_split_results)
  cali_selected_split_size <- reactiveVal(0.1)

  models <- reactive({
    degree <- input$degree
    if (is.null(degree) || length(degree) == 0L || is.na(degree)) {
      degree <- 21L
    }

    fit_models(degree)
  })

  observeEvent(input$sample, {
    new_test_data <- sample_test_data(input$sample_size)
    test_data(new_test_data)

    new_row <- data.frame(
      Count = nrow(mse_history()) + 1L,
      compute_errors(models(), new_test_data),
      check.names = FALSE
    )
    mse_history(rbind(mse_history(), new_row))
  })

  line_data <- reactive({
    fit_lines(models())
  })

  line_visibility <- reactive({
    list(
      show_oracle = is.null(input$show_oracle) || isTRUE(input$show_oracle),
      show_linear = is.null(input$show_linear) || isTRUE(input$show_linear),
      show_polynomial = is.null(input$show_polynomial) || isTRUE(input$show_polynomial)
    )
  })

  observeEvent(input$reset, {
    mse_history(empty_results)
  })

  observeEvent(input$cali_split_size, {
    split_size <- normalize_cali_split_size(input$cali_split_size)
    cali_selected_split_size(split_size)
    updateNumericInput(session, "cali_split_size_mini", value = split_size)
  }, ignoreInit = FALSE)

  observeEvent(input$cali_split_size_mini, {
    split_size <- normalize_cali_split_size(input$cali_split_size_mini)
    cali_selected_split_size(split_size)
    updateNumericInput(session, "cali_split_size_mini", value = split_size)
    updateSliderInput(session, "cali_split_size", value = split_size)
  }, ignoreInit = FALSE)

  sample_cali_split <- function() {
    if (!isTRUE(input$cali_split_enabled)) {
      return(NULL)
    }

    sample_random <- is.null(input$cali_sample_random) || isTRUE(input$cali_sample_random)
    split <- cali_make_split(cali_selected_split_size(), sample_random = sample_random)
    cali_current_split(split)

    new_row <- data.frame(
      Count = nrow(cali_split_history()) + 1L,
      `Split size` = split$split_size,
      `Train n` = nrow(split$train_data),
      `Test n` = nrow(split$test_data),
      `Test MSE` = split$test_mse,
      check.names = FALSE
    )
    cali_split_history(rbind(cali_split_history(), new_row))
  }

  observeEvent(input$cali_sample, {
    sample_cali_split()
  })

  observeEvent(input$cali_sample_mini, {
    sample_cali_split()
  })

  observeEvent(input$cali_reset, {
    cali_current_split(NULL)
    cali_split_history(empty_cali_split_results)
  })

  observeEvent(input$cali_split_enabled, {
    if (!isTRUE(input$cali_split_enabled)) {
      cali_current_split(NULL)
      cali_split_history(empty_cali_split_results)
    }
  })

  output$regression_plot <- renderPlot({
    visibility <- line_visibility()

    add_training_mse_label(
      add_fitted_lines(
        ggplot(data_train, aes(x = x, y = y)) +
          geom_point(),
        line_data(),
        show_oracle = visibility$show_oracle,
        show_linear = visibility$show_linear,
        show_polynomial = visibility$show_polynomial
      ),
      models()
    )
  })

  output$test_plot <- renderPlot({
    if (!is.null(input$show_test_plot) && !isTRUE(input$show_test_plot)) {
      return(blank_test_plot())
    }

    visibility <- line_visibility()

    add_fitted_lines(
      ggplot(test_data(), aes(x = x, y = y)) +
        geom_point(colour = "gray50"),
      line_data(),
      show_oracle = visibility$show_oracle,
      show_linear = visibility$show_linear,
      show_polynomial = visibility$show_polynomial
    )
  })

  output$unknown_regression_plot <- renderPlot({
    show_linear <- is.null(input$cali_show_linear) || isTRUE(input$cali_show_linear)
    split_enabled <- is.null(input$cali_split_enabled) || isTRUE(input$cali_split_enabled)
    split <- if (split_enabled) cali_current_split() else NULL

    cali_scatter_plot(
      show_linear = show_linear,
      split = split,
      split_enabled = split_enabled
    )
  })

  output$unknown_test_plot <- renderPlot({
    cali_unknown_test_plot()
  })

  output$unknown_error_table <- renderUI({
    unknown_error_table()
  })

  output$cali_train_split_plot <- renderPlot({
    if (!isTRUE(input$cali_split_enabled)) {
      return(cali_blank_split_plot())
    }

    split <- cali_current_split()
    if (is.null(split)) {
      return(cali_empty_split_plot())
    }

    cali_split_plot(split$train_data, split, point_colour = "black")
  })

  output$cali_test_split_plot <- renderPlot({
    if (!isTRUE(input$cali_split_enabled)) {
      return(cali_blank_split_plot())
    }

    split <- cali_current_split()
    if (is.null(split)) {
      return(cali_empty_split_plot())
    }

    cali_split_plot(split$test_data, split, point_colour = test_point_colour)
  })

  output$cali_split_table <- renderUI({
    if (!isTRUE(input$cali_split_enabled)) {
      return(cali_split_history_table(empty_cali_split_results))
    }

    cali_split_history_table(cali_split_history())
  })

  output$cali_split_boxplot <- renderPlot({
    if (!isTRUE(input$cali_split_enabled)) {
      return(cali_split_boxplot(empty_cali_split_results))
    }

    cali_split_boxplot(cali_split_history())
  })

  output$mse_table <- renderUI({
    mse_history_table(mse_history())
  })
}

shinyApp(ui = ui, server = server)
