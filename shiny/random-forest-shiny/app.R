library(shiny)
library(ggplot2)
library(mlr3)
library(mlr3data)
library(rpart)
library(rpart.plot)
library(ranger)

target_name <- "type"
default_feature <- "charDollar"
max_readable_leaves <- 85L
tree_palette <- c("#f7fcf5", "#c7e9c0", "#74c476", "#238b45", "#00441b")
rf_bar_colour <- "#3366FF"

load_spam_data <- function() {
  task <- mlr3::tsk("spam")
  data <- as.data.frame(task$data())
  data[[target_name]] <- factor(data[[target_name]], levels = c("spam", "nonspam"))
  data
}

normalize_integer <- function(value, default, minimum, maximum) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- default
  }

  value <- suppressWarnings(as.numeric(value))
  if (is.na(value)) {
    value <- default
  }

  min(maximum, max(minimum, as.integer(round(value))))
}

normalize_numeric <- function(value, default, minimum, maximum) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- default
  }

  value <- suppressWarnings(as.numeric(value))
  if (is.na(value)) {
    value <- default
  }

  min(maximum, max(minimum, value))
}

normalize_choice <- function(value, choices, default) {
  if (is.null(value) || length(value) == 0L || is.na(value) || !value %in% choices) {
    return(default)
  }

  value
}

format_percent <- function(value, digits = 1L) {
  sprintf(paste0("%.", digits, "f%%"), 100 * value)
}

spam_data <- load_spam_data()
feature_names <- setdiff(names(spam_data), target_name)
default_mtry <- min(8L, length(feature_names))

class_balance_rows <- function(data) {
  counts <- as.data.frame(table(data[[target_name]]), stringsAsFactors = FALSE)
  names(counts) <- c("Class", "Count")
  counts$Share <- counts$Count / sum(counts$Count)
  counts
}

feature_plot_data <- function(data, feature, log_scale) {
  values <- data[[feature]]
  y_label <- feature
  if (isTRUE(log_scale)) {
    values <- log1p(values)
    y_label <- paste0("log1p(", feature, ")")
  }

  list(
    data = data.frame(
      type = data[[target_name]],
      value = values
    ),
    y_label = y_label
  )
}

class_balance_plot <- function(data) {
  counts <- class_balance_rows(data)

  ggplot(counts, aes(x = Class, y = Count, fill = Class)) +
    geom_col(width = 0.62, colour = "white", linewidth = 0.4) +
    geom_text(
      aes(label = paste0(Count, "\n", format_percent(Share))),
      vjust = -0.25,
      size = 4
    ) +
    scale_fill_manual(values = c(spam = "#d95f02", nonspam = "#1b9e77")) +
    labs(
      x = NULL,
      y = "emails",
      title = "Class balance"
    ) +
    expand_limits(y = max(counts$Count) * 1.12) +
    theme_classic() +
    theme(legend.position = "none")
}

feature_distribution_plot <- function(data, feature, mode, log_scale) {
  plot_data <- feature_plot_data(data, feature, log_scale)
  values <- plot_data$data$value
  x_label <- plot_data$y_label
  mode <- normalize_choice(mode, c("histogram", "density", "boxplot"), "histogram")

  if (identical(mode, "boxplot")) {
    return(
      ggplot(plot_data$data, aes(x = type, y = value, fill = type)) +
        geom_boxplot(width = 0.65, alpha = 0.82, outlier.alpha = 0.28) +
        scale_fill_manual(values = c(spam = "#d95f02", nonspam = "#1b9e77")) +
        labs(
          x = NULL,
          y = x_label,
          title = paste("Distribution of", feature)
        ) +
        theme_classic() +
        theme(legend.position = "none")
    )
  }

  plot <- ggplot(plot_data$data, aes(x = value, fill = type, colour = type))

  if (identical(mode, "density")) {
    plot <- plot +
      geom_density(alpha = 0.25, linewidth = 1, adjust = 1.1)
  } else {
    plot <- plot +
      geom_histogram(
        aes(y = after_stat(density)),
        bins = 35,
        alpha = 0.38,
        position = "identity",
        linewidth = 0.2
      )
  }

  plot +
    scale_fill_manual(values = c(spam = "#d95f02", nonspam = "#1b9e77")) +
    scale_colour_manual(values = c(spam = "#d95f02", nonspam = "#1b9e77")) +
    coord_cartesian(xlim = range(values, finite = TRUE), expand = TRUE) +
    labs(
      x = x_label,
      y = if (identical(mode, "density")) "density" else "density-scaled count",
      fill = NULL,
      colour = NULL,
      title = paste("Distribution of", feature)
    ) +
    theme_classic() +
    theme(legend.position = "top")
}

fit_cart <- function(data, row_ids = NULL, maxdepth, minsplit, minbucket, cp) {
  train_data <- if (is.null(row_ids)) data else data[row_ids, , drop = FALSE]

  rpart::rpart(
    type ~ .,
    data = train_data,
    method = "class",
    control = rpart::rpart.control(
      maxdepth = maxdepth,
      minsplit = minsplit,
      minbucket = minbucket,
      cp = cp,
      xval = 0L
    )
  )
}

make_subset_ids <- function(data, share, seed) {
  set.seed(seed)
  sample.int(nrow(data), size = floor(share * nrow(data)), replace = FALSE)
}

tree_depth <- function(fit) {
  nodes <- as.integer(row.names(fit$frame))
  max(floor(log(nodes, base = 2)), na.rm = TRUE)
}

tree_accuracy <- function(fit, data) {
  predictions <- predict(fit, newdata = data, type = "class")
  mean(predictions == data[[target_name]])
}

tree_stats_row <- function(label, fit, train_rows, train_data) {
  data.frame(
    Model = label,
    `Training rows` = train_rows,
    `Root split` = as.character(fit$frame$var[[1L]]),
    `Terminal nodes` = sum(fit$frame$var == "<leaf>"),
    `Internal splits` = sum(fit$frame$var != "<leaf>"),
    `Observed depth` = tree_depth(fit),
    `Training accuracy` = format_percent(tree_accuracy(fit, train_data), digits = 1L),
    check.names = FALSE
  )
}

fit_tree_bundle <- function(data, subset_share, seed_one, seed_two, maxdepth, minsplit, minbucket, cp) {
  subset_one <- make_subset_ids(data, subset_share, seed_one)
  subset_two <- make_subset_ids(data, subset_share, seed_two)

  full_fit <- fit_cart(
    data,
    maxdepth = maxdepth,
    minsplit = minsplit,
    minbucket = minbucket,
    cp = cp
  )
  subset_one_fit <- fit_cart(
    data,
    row_ids = subset_one,
    maxdepth = maxdepth,
    minsplit = minsplit,
    minbucket = minbucket,
    cp = cp
  )
  subset_two_fit <- fit_cart(
    data,
    row_ids = subset_two,
    maxdepth = maxdepth,
    minsplit = minsplit,
    minbucket = minbucket,
    cp = cp
  )

  list(
    full = list(fit = full_fit, rows = seq_len(nrow(data)), train_data = data),
    subset_one = list(
      fit = subset_one_fit,
      rows = subset_one,
      train_data = data[subset_one, , drop = FALSE]
    ),
    subset_two = list(
      fit = subset_two_fit,
      rows = subset_two,
      train_data = data[subset_two, , drop = FALSE]
    )
  )
}

tree_bundle_stats <- function(bundle) {
  rbind(
    tree_stats_row("Full data", bundle$full$fit, length(bundle$full$rows), bundle$full$train_data),
    tree_stats_row("Subset 1", bundle$subset_one$fit, length(bundle$subset_one$rows), bundle$subset_one$train_data),
    tree_stats_row("Subset 2", bundle$subset_two$fit, length(bundle$subset_two$rows), bundle$subset_two$train_data)
  )
}

stats_table <- function(rows, class = "table table-condensed stats-table") {
  tags$table(
    class = class,
    tags$thead(tags$tr(lapply(names(rows), tags$th))),
    tags$tbody(lapply(seq_len(nrow(rows)), function(i) {
      tags$tr(lapply(rows[i, , drop = FALSE], tags$td))
    }))
  )
}

plot_tree_or_message <- function(fit, text_scale = 1) {
  leaves <- sum(fit$frame$var == "<leaf>")
  if (leaves > max_readable_leaves) {
    plot.new()
    text(
      x = 0.5,
      y = 0.58,
      labels = sprintf("Tree has %i terminal nodes.", leaves),
      cex = 1.5 * text_scale,
      font = 2
    )
    text(
      x = 0.5,
      y = 0.46,
      labels = "Increase cp or minsplit, or lower maxdepth, to make the plot readable.",
      cex = 1.15 * text_scale
    )
    return(invisible(NULL))
  }

  rpart.plot::rpart.plot(
    fit,
    type = 4,
    extra = 104,
    fallen.leaves = TRUE,
    branch.lty = 1,
    box.palette = tree_palette,
    shadow.col = "gray80",
    roundint = FALSE,
    under = TRUE,
    tweak = (if (leaves > 45L) 0.55 else if (leaves > 25L) 0.72 else 0.88) * text_scale
  )
}

fit_rf <- function(data, num_trees, mtry, min_node_size, sample_fraction, seed) {
  ranger::ranger(
    type ~ .,
    data = data,
    num.trees = num_trees,
    mtry = mtry,
    min.node.size = min_node_size,
    sample.fraction = sample_fraction,
    replace = TRUE,
    importance = "permutation",
    oob.error = TRUE,
    seed = seed
  )
}

importance_rows <- function(fit, top_k) {
  scores <- sort(fit$variable.importance, decreasing = TRUE)
  top_k <- min(top_k, length(scores))
  data.frame(
    Feature = names(scores)[seq_len(top_k)],
    Importance = as.numeric(scores[seq_len(top_k)]),
    check.names = FALSE
  )
}

importance_plot <- function(rows) {
  plot_rows <- rows
  plot_rows$Feature <- factor(plot_rows$Feature, levels = rev(plot_rows$Feature))

  ggplot(plot_rows, aes(x = Feature, y = Importance)) +
    geom_col(fill = rf_bar_colour, width = 0.72) +
    coord_flip() +
    labs(
      x = NULL,
      y = "permutation importance",
      title = "Top permutation importance scores"
    ) +
    theme_classic()
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background: #f6f8fb;
        color: #172033;
      }

      .app-shell {
        max-width: 1500px;
        margin: 0 auto;
        padding: 18px 16px 32px;
      }

      .app-title {
        margin: 0 0 14px;
        font-size: 26px;
        font-weight: 650;
        letter-spacing: 0;
      }

      .section-title {
        margin: 24px 0 12px;
        font-size: 21px;
        font-weight: 650;
        letter-spacing: 0;
      }

      .panel-grid {
        display: grid;
        gap: 16px;
        grid-template-columns: 320px minmax(0, 1fr);
        align-items: start;
      }

      .three-plot-grid {
        display: grid;
        gap: 16px;
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }

      .two-plot-grid {
        display: grid;
        gap: 16px;
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .control-panel,
      .plot-panel,
      .table-panel {
        background: #ffffff;
        border: 1px solid #dce3ec;
        border-radius: 8px;
        box-shadow: 0 1px 2px rgba(17, 24, 39, 0.06);
      }

      .control-panel {
        padding: 16px;
      }

      .plot-panel,
      .table-panel {
        padding: 10px 12px 12px;
        min-width: 0;
      }

      .panel-title {
        margin: 0 0 8px;
        font-size: 16px;
        font-weight: 650;
      }

      .control-panel h3 {
        margin: 0 0 12px;
        font-size: 17px;
        font-weight: 650;
      }

      .control-separator {
        border-top: 1px solid #e3e8f0;
        margin: 10px 0 16px;
      }

      .control-row {
        display: flex;
        align-items: flex-end;
        flex-wrap: wrap;
        gap: 8px;
      }

      .control-row .form-group {
        margin-bottom: 0;
      }

      .seed-input {
        flex: 1 1 120px;
        min-width: 120px;
      }

      .seed-input input {
        width: 100% !important;
      }

      .zoom-control {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 2px;
      }

      .zoom-control .btn {
        min-width: 42px;
      }

      .zoom-label {
        color: #5b6472;
        font-size: 12px;
        min-width: 44px;
      }

      .stats-table {
        margin-bottom: 0;
        width: 100%;
      }

      .stats-table th,
      .stats-table td {
        white-space: nowrap;
      }

      .stats-table td:last-child {
        font-weight: 600;
      }

      .context-card {
        background: #f8fafc;
        border: 1px solid #e3e8f0;
        border-radius: 6px;
        color: #344054;
        margin-bottom: 12px;
        padding: 10px 12px;
      }

      .context-card strong {
        color: #172033;
      }

      .doc-info-box {
        background-color: #fff4cc;
        border: 1px solid #e6c35c;
        border-radius: 6px;
        color: #4f3b00;
        margin-top: 18px;
        padding: 14px 16px;
      }

      .doc-info-box a {
        color: #23527c;
        font-weight: 600;
      }

      @media (max-width: 1050px) {
        .panel-grid,
        .three-plot-grid,
        .two-plot-grid {
          grid-template-columns: 1fr;
        }
      }
    "))
  ),
  div(
    class = "app-shell",
    h1(class = "app-title", "Exercise 2: Classifying spam"),

    h2(class = "section-title", "a) Inspect the spam task"),
    div(
      class = "panel-grid",
      div(
        class = "control-panel",
        h3("Data controls"),
        selectInput(
          inputId = "feature",
          label = "Feature",
          choices = feature_names,
          selected = default_feature
        ),
        selectInput(
          inputId = "feature_mode",
          label = "Distribution view",
          choices = c("Histogram" = "histogram", "Density" = "density", "Boxplot" = "boxplot"),
          selected = "histogram"
        ),
        checkboxInput(
          inputId = "feature_log_scale",
          label = "Use log1p scale",
          value = TRUE
        ),
        uiOutput("data_context")
      ),
      div(
        class = "two-plot-grid",
        div(
          class = "plot-panel",
          div(class = "panel-title", "Class balance"),
          plotOutput("class_balance_plot", height = "360px")
        ),
        div(
          class = "plot-panel",
          div(class = "panel-title", "Feature distribution"),
          plotOutput("feature_distribution_plot", height = "360px")
        )
      )
    ),

    h2(class = "section-title", "b) Decision tree stability"),
    div(
      class = "panel-grid",
      div(
        class = "control-panel",
        h3("CART controls"),
        sliderInput(
          inputId = "subset_share",
          label = "Subset share",
          min = 0.1,
          max = 0.9,
          value = 0.6,
          step = 0.05
        ),
        div(
          class = "control-row",
          div(
            class = "seed-input",
            numericInput(
              inputId = "seed_one",
              label = "Seed subset 1",
              value = 456,
              min = 1,
              step = 1
            )
          ),
          div(
            class = "seed-input",
            numericInput(
              inputId = "seed_two",
              label = "Seed subset 2",
              value = 789,
              min = 1,
              step = 1
            )
          )
        ),
        div(class = "control-separator"),
        sliderInput(
          inputId = "maxdepth",
          label = "Maximum depth",
          min = 1,
          max = 12,
          value = 5,
          step = 1
        ),
        numericInput(
          inputId = "minsplit",
          label = "Minimum observations to split",
          value = 20,
          min = 2,
          max = 500,
          step = 1
        ),
        numericInput(
          inputId = "minbucket",
          label = "Minimum observations in terminal node",
          value = 7,
          min = 1,
          max = 250,
          step = 1
        ),
        sliderInput(
          inputId = "cp",
          label = "Complexity parameter",
          min = 0,
          max = 0.05,
          value = 0.01,
          step = 0.001
        ),
        div(
          class = "control-row",
          actionButton(
            inputId = "reset_tree",
            label = "Reset tree controls"
          )
        ),
        div(class = "control-separator"),
        div(
          class = "zoom-control",
          actionButton(
            inputId = "tree_zoom_out",
            label = NULL,
            icon = icon("search-minus"),
            title = "Decrease tree label size"
          ),
          actionButton(
            inputId = "tree_zoom_in",
            label = NULL,
            icon = icon("search-plus"),
            title = "Increase tree label size"
          ),
          span(class = "zoom-label", textOutput("tree_zoom_label", inline = TRUE))
        ),
        uiOutput("tree_note")
      ),
      div(
        div(
          class = "three-plot-grid",
          div(
            class = "plot-panel",
            div(class = "panel-title", "Full data tree"),
            plotOutput("tree_full_plot", height = "520px")
          ),
          div(
            class = "plot-panel",
            div(class = "panel-title", "Subset 1 tree"),
            plotOutput("tree_subset_one_plot", height = "520px")
          ),
          div(
            class = "plot-panel",
            div(class = "panel-title", "Subset 2 tree"),
            plotOutput("tree_subset_two_plot", height = "520px")
          )
        ),
        div(
          class = "table-panel",
          style = "margin-top: 16px;",
          div(class = "panel-title", "Tree comparison"),
          uiOutput("tree_stats_table")
        )
      )
    ),

    h2(class = "section-title", "d) Permutation feature importance"),
    div(
      class = "panel-grid",
      div(
        class = "control-panel",
        h3("Random forest controls"),
        sliderInput(
          inputId = "rf_num_trees",
          label = "Number of trees",
          min = 50,
          max = 1000,
          value = 200,
          step = 50
        ),
        sliderInput(
          inputId = "rf_mtry",
          label = "mtry",
          min = 1,
          max = length(feature_names),
          value = default_mtry,
          step = 1
        ),
        sliderInput(
          inputId = "rf_min_node_size",
          label = "Minimum terminal node size",
          min = 1,
          max = 50,
          value = 1,
          step = 1
        ),
        sliderInput(
          inputId = "rf_sample_fraction",
          label = "Bootstrap sample fraction",
          min = 0.1,
          max = 1,
          value = 1,
          step = 0.05
        ),
        sliderInput(
          inputId = "rf_top_k",
          label = "Top features",
          min = 5,
          max = 25,
          value = 10,
          step = 1
        ),
        numericInput(
          inputId = "rf_seed",
          label = "Forest seed",
          value = 2026,
          min = 1,
          step = 1
        ),
        actionButton(
          inputId = "fit_rf",
          label = "Fit forest",
          class = "btn-primary"
        )
      ),
      div(
        div(
          class = "plot-panel",
          div(class = "panel-title", "Permutation importance"),
          uiOutput("rf_context"),
          plotOutput("importance_plot", height = "520px")
        ),
        div(
          class = "table-panel",
          style = "margin-top: 16px;",
          div(class = "panel-title", "Importance scores"),
          uiOutput("importance_table")
        )
      )
    ),

    div(
      class = "doc-info-box",
      strong("Documentation: "),
      "The app uses ",
      code("mlr3::tsk(\"spam\")"),
      ", ",
      code("rpart::rpart()"),
      ", and ",
      code("ranger::ranger()"),
      ". The random forest importance plot uses permutation importance and displays OOB error only as model context."
    )
  )
)

server <- function(input, output, session) {
  tree_text_scale <- reactiveVal(1)

  observeEvent(input$tree_zoom_out, {
    tree_text_scale(max(0.6, tree_text_scale() - 0.1))
  })

  observeEvent(input$tree_zoom_in, {
    tree_text_scale(min(2, tree_text_scale() + 0.1))
  })

  observeEvent(input$reset_tree, {
    updateSliderInput(session, "subset_share", value = 0.6)
    updateNumericInput(session, "seed_one", value = 456)
    updateNumericInput(session, "seed_two", value = 789)
    updateSliderInput(session, "maxdepth", value = 5)
    updateNumericInput(session, "minsplit", value = 20)
    updateNumericInput(session, "minbucket", value = 7)
    updateSliderInput(session, "cp", value = 0.01)
    tree_text_scale(1)
  })

  output$data_context <- renderUI({
    rows <- class_balance_rows(spam_data)
    tagList(
      div(class = "control-separator"),
      div(
        class = "context-card",
        strong("Task: "),
        nrow(spam_data),
        " emails, ",
        length(feature_names),
        " predictors, target ",
        code(target_name),
        ".",
        tags$br(),
        strong("Classes: "),
        paste0(rows$Class, " = ", rows$Count, collapse = ", "),
        "."
      )
    )
  })

  output$class_balance_plot <- renderPlot({
    class_balance_plot(spam_data)
  })

  output$feature_distribution_plot <- renderPlot({
    feature <- normalize_choice(input$feature, feature_names, default_feature)
    feature_distribution_plot(
      spam_data,
      feature = feature,
      mode = input$feature_mode,
      log_scale = isTRUE(input$feature_log_scale)
    )
  })

  tree_controls <- reactive({
    minsplit <- normalize_integer(input$minsplit, default = 20L, minimum = 2L, maximum = 500L)
    minbucket <- normalize_integer(input$minbucket, default = 7L, minimum = 1L, maximum = 250L)

    list(
      subset_share = normalize_numeric(input$subset_share, default = 0.6, minimum = 0.1, maximum = 0.9),
      seed_one = normalize_integer(input$seed_one, default = 456L, minimum = 1L, maximum = .Machine$integer.max),
      seed_two = normalize_integer(input$seed_two, default = 789L, minimum = 1L, maximum = .Machine$integer.max),
      maxdepth = normalize_integer(input$maxdepth, default = 5L, minimum = 1L, maximum = 12L),
      minsplit = minsplit,
      minbucket = minbucket,
      cp = normalize_numeric(input$cp, default = 0.01, minimum = 0, maximum = 0.05),
      text_scale = tree_text_scale()
    )
  })

  tree_bundle <- reactive({
    controls <- tree_controls()
    fit_tree_bundle(
      spam_data,
      subset_share = controls$subset_share,
      seed_one = controls$seed_one,
      seed_two = controls$seed_two,
      maxdepth = controls$maxdepth,
      minsplit = controls$minsplit,
      minbucket = controls$minbucket,
      cp = controls$cp
    )
  })

  output$tree_full_plot <- renderPlot({
    plot_tree_or_message(tree_bundle()$full$fit, text_scale = tree_controls()$text_scale)
  })

  output$tree_subset_one_plot <- renderPlot({
    plot_tree_or_message(tree_bundle()$subset_one$fit, text_scale = tree_controls()$text_scale)
  })

  output$tree_subset_two_plot <- renderPlot({
    plot_tree_or_message(tree_bundle()$subset_two$fit, text_scale = tree_controls()$text_scale)
  })

  output$tree_zoom_label <- renderText({
    paste0(round(100 * tree_text_scale()), "%")
  })

  output$tree_stats_table <- renderUI({
    stats_table(tree_bundle_stats(tree_bundle()))
  })

  output$tree_note <- renderUI({
    controls <- tree_controls()
    notes <- list()

    if (controls$seed_one == controls$seed_two) {
      notes <- c(notes, list(div(
        class = "alert alert-warning",
        "Both subset seeds are identical; the two subset trees will use the same sample."
      )))
    }

    if (controls$minbucket > floor(controls$minsplit / 2)) {
      notes <- c(notes, list(div(
        class = "alert alert-warning",
        "`minbucket` is larger than half of `minsplit`; this makes the split rule restrictive."
      )))
    }

    if (length(notes) == 0L) {
      return(NULL)
    }

    tagList(notes)
  })

  rf_controls <- reactive({
    list(
      num_trees = normalize_integer(input$rf_num_trees, default = 200L, minimum = 50L, maximum = 1000L),
      mtry = normalize_integer(input$rf_mtry, default = default_mtry, minimum = 1L, maximum = length(feature_names)),
      min_node_size = normalize_integer(input$rf_min_node_size, default = 1L, minimum = 1L, maximum = 50L),
      sample_fraction = normalize_numeric(input$rf_sample_fraction, default = 1, minimum = 0.1, maximum = 1),
      seed = normalize_integer(input$rf_seed, default = 2026L, minimum = 1L, maximum = .Machine$integer.max)
    )
  })

  rf_fit_result <- eventReactive(input$fit_rf, {
    controls <- rf_controls()
    withProgress(message = "Fitting random forest", value = 0.35, {
      fit <- fit_rf(
        spam_data,
        num_trees = controls$num_trees,
        mtry = controls$mtry,
        min_node_size = controls$min_node_size,
        sample_fraction = controls$sample_fraction,
        seed = controls$seed
      )
      incProgress(0.65)
      list(fit = fit, controls = controls, fitted_at = Sys.time())
    })
  }, ignoreNULL = FALSE)

  output$rf_context <- renderUI({
    result <- rf_fit_result()
    controls <- result$controls

    div(
      class = "context-card",
      strong("Last fit: "),
      controls$num_trees,
      " trees, mtry = ",
      controls$mtry,
      ", min.node.size = ",
      controls$min_node_size,
      ", sample.fraction = ",
      sprintf("%.2f", controls$sample_fraction),
      ", seed = ",
      controls$seed,
      ". ",
      strong("OOB error: "),
      format_percent(result$fit$prediction.error, digits = 2L),
      "."
    )
  })

  output$importance_plot <- renderPlot({
    rows <- importance_rows(
      rf_fit_result()$fit,
      top_k = normalize_integer(input$rf_top_k, default = 10L, minimum = 5L, maximum = 25L)
    )
    importance_plot(rows)
  })

  output$importance_table <- renderUI({
    rows <- importance_rows(
      rf_fit_result()$fit,
      top_k = normalize_integer(input$rf_top_k, default = 10L, minimum = 5L, maximum = 25L)
    )
    rows$Importance <- sprintf("%.5f", rows$Importance)
    stats_table(rows)
  })
}

shinyApp(ui = ui, server = server)
