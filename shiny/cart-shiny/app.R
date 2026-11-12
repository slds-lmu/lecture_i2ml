library(shiny)
library(rpart)
library(rpart.plot)

find_app_file <- function(filename) {
  candidates <- c(file.path("shiny", "cart-shiny", filename), filename)
  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0L) {
    stop("Could not find ", filename, " in the Shiny app folder.", call. = FALSE)
  }

  existing[[1L]]
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

normalize_cp <- function(value) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- 0.01
  }

  min(0.05, max(0.001, as.numeric(value)))
}

normalize_numeric <- function(value, default, minimum, maximum) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- default
  }

  min(maximum, max(minimum, as.numeric(value)))
}

load_bike_sharing <- function() {
  data <- read.csv(find_app_file("bike_sharing.csv"), stringsAsFactors = FALSE)

  data$date <- NULL
  data$season <- factor(
    data$season,
    levels = c("winter", "spring", "summer", "fall")
  )
  data$weather <- factor(
    data$weather,
    levels = c(1, 2, 3, 4),
    labels = c("clear", "misty", "light_rain_snow", "heavy_rain_snow")
  )
  data$holiday <- factor(
    data$holiday,
    levels = c(FALSE, TRUE),
    labels = c("no_holiday", "holiday")
  )
  data$working_day <- factor(
    data$working_day,
    levels = c(FALSE, TRUE),
    labels = c("no", "yes")
  )

  data
}

bike_data <- load_bike_sharing()
target_name <- "count"
max_readable_leaves <- 80L
green_palette <- c("#f7fcf5", "#c7e9c0", "#74c476", "#238b45", "#00441b")
minsplit_choices <- c(2L, 5L, 100L, 1000L, 10000L)
minbucket_choices <- c(1L, 5L, 100L, 1000L, 5000L)

fit_cart <- function(data, minsplit, minbucket, maxdepth, cp) {
  rpart(
    count ~ .,
    data = data,
    method = "anova",
    control = rpart.control(
      minsplit = minsplit,
      minbucket = minbucket,
      maxdepth = maxdepth,
      cp = cp,
      xval = 10L
    )
  )
}

tree_depth <- function(fit) {
  nodes <- as.integer(row.names(fit$frame))
  max(floor(log(nodes, base = 2)), na.rm = TRUE)
}

tree_stats <- function(fit, data) {
  predictions <- predict(fit, newdata = data)
  residuals <- data[[target_name]] - predictions
  response_variance <- stats::var(data[[target_name]])
  mse <- mean(residuals^2)

  data.frame(
    Quantity = c(
      "Terminal nodes",
      "Internal splits",
      "Observed depth",
      "Training RMSE",
      "Training MAE",
      "Training R-squared"
    ),
    Value = c(
      sum(fit$frame$var == "<leaf>"),
      sum(fit$frame$var != "<leaf>"),
      tree_depth(fit),
      sprintf("%.1f", sqrt(mse)),
      sprintf("%.1f", mean(abs(residuals))),
      sprintf("%.3f", 1 - mse / response_variance)
    ),
    check.names = FALSE
  )
}

stats_table <- function(rows) {
  tags$table(
    class = "table table-condensed stats-table",
    tags$tbody(lapply(seq_len(nrow(rows)), function(i) {
      tags$tr(
        tags$td(rows$Quantity[[i]]),
        tags$td(rows$Value[[i]])
      )
    }))
  )
}

plot_cart <- function(fit, minsplit, minbucket, maxdepth, cp, use_cp, text_scale) {
  leaves <- sum(fit$frame$var == "<leaf>")
  splits <- sum(fit$frame$var != "<leaf>")

  if (leaves > max_readable_leaves) {
    plot.new()
    text(
      x = 0.5,
      y = 0.58,
      labels = sprintf("Tree has %i terminal nodes.", leaves),
      cex = 1.7 * text_scale,
      font = 2
    )
    text(
      x = 0.5,
      y = 0.46,
      labels = "Increase cp or minsplit, or lower maxdepth, to make the plot readable.",
      cex = 1.35 * text_scale
    )
    return(invisible(NULL))
  }

  rpart.plot(
    fit,
    type = 4,
    extra = 101,
    fallen.leaves = TRUE,
    branch.lty = 1,
    box.palette = green_palette,
    shadow.col = "gray80",
    roundint = FALSE,
    under = TRUE,
    tweak = (if (leaves > 45L) 0.55 else if (leaves > 25L) 0.72 else 0.9) * text_scale
  )
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .top-panel-row {
        align-items: stretch;
        display: flex;
      }

      .top-panel-row > [class*='col-'] {
        display: flex;
      }

      .control-panel {
        display: grid;
        gap: 12px 18px;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        width: 100%;
      }

      .control-panel .form-group {
        margin-bottom: 0;
      }

      .control-panel .btn {
        width: auto;
      }

      .control-actions {
        align-items: flex-end;
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
      }

      .settings-column {
        display: flex;
        flex-direction: column;
        gap: 12px;
        min-width: 0;
      }

      .zoom-control {
        align-items: center;
        display: flex;
        gap: 8px;
      }

      .zoom-control .btn {
        min-width: 42px;
      }

      .zoom-label {
        color: #555;
        font-size: 12px;
        min-width: 44px;
      }

      .stats-table {
        margin-bottom: 0;
        width: 100%;
      }

      .stats-table td:first-child {
        color: #555;
        width: 58%;
      }

      .stats-table td:last-child {
        font-weight: 600;
        text-align: right;
      }

      .doc-info-box {
        background-color: #fff4cc;
        border: 1px solid #e6c35c;
        border-radius: 4px;
        color: #4f3b00;
        margin-top: 18px;
        padding: 14px 16px;
      }

      .doc-info-box a {
        color: #23527c;
        font-weight: 600;
      }

      .plot-heading {
        font-size: 16px;
        font-weight: 600;
        margin: 14px 0 8px 0;
      }

      .plot-heading-bar {
        align-items: center;
        display: flex;
        justify-content: space-between;
        margin-top: 14px;
      }

      .plot-heading-bar .plot-heading {
        margin: 0;
      }

      @media (max-width: 767px) {
        .top-panel-row {
          display: block;
        }

        .top-panel-row > [class*='col-'] {
          display: block;
        }

        .control-panel {
          grid-template-columns: 1fr;
        }
      }
    "))
  ),
  titlePanel("Exercise 2: CART splitting criteria"),
  fluidRow(
    column(
      width = 4,
      offset = 4,
      div(
        class = "well control-panel",
        div(
          class = "settings-column",
          sliderInput(
            inputId = "maxdepth",
          label = "Maximum depth",
          min = 1,
          max = 10,
          value = 4,
          step = 1
          ),
          selectInput(
            inputId = "minsplit",
            label = "Minimum observations to split",
            choices = minsplit_choices,
            selected = 2
          ),
          div(
            class = "control-actions",
            actionButton(
              inputId = "reset",
              label = "Reset to defaults"
            )
          )
        ),
        div(
          class = "settings-column",
          checkboxInput(
            inputId = "use_minbucket",
            label = "Terminal node size",
            value = TRUE
          ),
          conditionalPanel(
            condition = "input.use_minbucket",
            selectInput(
              inputId = "minbucket",
              label = "Minimum observations in terminal node",
              choices = minbucket_choices,
              selected = 1
            )
          ),
          checkboxInput(
            inputId = "use_cp",
            label = "Complexity parameter",
            value = TRUE
          ),
          conditionalPanel(
            condition = "input.use_cp",
            sliderInput(
              inputId = "cp",
              label = "Complexity parameter",
              min = 0.001,
              max = 0.05,
              value = 0.01,
              step = 0.001
            )
          )
        )
      )
    )
  ),
  fluidRow(
    column(
      width = 10,
      offset = 1,
      div(
        class = "plot-heading-bar",
        div(class = "plot-heading", "Tree structure"),
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
        )
      ),
      plotOutput("tree_plot", height = "720px")
    )
  ),
  fluidRow(
    column(
      width = 4,
      offset = 4,
      uiOutput("tree_stats")
    )
  ),
  fluidRow(
    column(
      width = 4,
      offset = 4,
      uiOutput("tree_note")
    )
  ),
  fluidRow(
    column(
      width = 4,
      offset = 4,
      div(
        class = "doc-info-box",
        strong("Documentation: "),
        "The app fits CARTs with ",
        code("rpart::rpart()"),
        ". See the CRAN package page for function documentation and package references: ",
        tags$a(
          href = "https://cran.r-project.org/web/packages/rpart/index.html",
          target = "_blank",
          "rpart on CRAN"
        ),
        "."
      )
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

  observeEvent(input$reset, {
    updateSliderInput(session, "maxdepth", value = 4)
    updateSelectInput(session, "minsplit", selected = 2)
    updateCheckboxInput(session, "use_minbucket", value = TRUE)
    updateSelectInput(session, "minbucket", selected = 1)
    updateCheckboxInput(session, "use_cp", value = TRUE)
    updateSliderInput(session, "cp", value = 0.01)
    tree_text_scale(1)
  })

  controls <- reactive({
    minsplit <- normalize_integer(input$minsplit, default = 2L, minimum = 2L, maximum = 10000L)
    use_minbucket <- is.null(input$use_minbucket) || isTRUE(input$use_minbucket)
    minbucket <- if (isTRUE(use_minbucket)) {
      normalize_integer(input$minbucket, default = 1L, minimum = 1L, maximum = 5000L)
    } else {
      max(1L, round(minsplit / 3))
    }

    list(
      maxdepth = normalize_integer(input$maxdepth, default = 4L, minimum = 1L, maximum = 10L),
      minsplit = minsplit,
      minbucket = minbucket,
      use_minbucket = use_minbucket,
      cp = if (isTRUE(input$use_cp)) normalize_cp(input$cp) else 0,
      use_cp = isTRUE(input$use_cp),
      tree_text_scale = tree_text_scale()
    )
  })

  current_fit <- reactive({
    values <- controls()
    fit_cart(
      bike_data,
      minsplit = values$minsplit,
      minbucket = values$minbucket,
      maxdepth = values$maxdepth,
      cp = values$cp
    )
  })

  output$tree_plot <- renderPlot({
    values <- controls()
    plot_cart(
      current_fit(),
      minsplit = values$minsplit,
      minbucket = values$minbucket,
      maxdepth = values$maxdepth,
      cp = values$cp,
      use_cp = values$use_cp,
      text_scale = values$tree_text_scale
    )
  })

  output$tree_zoom_label <- renderText({
    paste0(round(100 * tree_text_scale()), "%")
  })

  output$tree_stats <- renderUI({
    stats_table(tree_stats(current_fit(), bike_data))
  })

  output$tree_note <- renderUI({
    values <- controls()
    if (isTRUE(values$use_minbucket) && values$minbucket > floor(values$minsplit / 2)) {
      return(div(
        class = "alert alert-warning",
        "`minbucket` is larger than half of `minsplit`; rpart can still fit the tree, but this setting is restrictive."
      ))
    }

    NULL
  })
}

shinyApp(ui = ui, server = server)
