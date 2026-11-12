library(shiny)
library(plotly)

x_limits <- c(-10, 10)
z_limits <- c(0, 1)
grid_size <- 81
sample_size <- 20
eps <- 1e-9

set.seed(20260506)
sample_points <- data.frame(
  id = seq_len(sample_size),
  x1 = runif(sample_size, min = x_limits[1], max = x_limits[2]),
  x2 = runif(sample_size, min = x_limits[1], max = x_limits[2])
)

set.seed(20260507)
sample_points_1d <- data.frame(
  id = seq_len(sample_size),
  x = runif(sample_size, min = x_limits[1], max = x_limits[2])
)

logit <- function(p) {
  log(p / (1 - p))
}

logistic_surface <- function(beta0, beta1, beta2) {
  x1 <- seq(x_limits[1], x_limits[2], length.out = grid_size)
  x2 <- seq(x_limits[1], x_limits[2], length.out = grid_size)
  z <- outer(
    x2,
    x1,
    FUN = function(x2_value, x1_value) {
      plogis(beta0 + beta1 * x1_value + beta2 * x2_value)
    }
  )

  list(x1 = x1, x2 = x2, z = z)
}

logistic_curve_1d <- function(theta0, theta1) {
  x <- seq(x_limits[1], x_limits[2], length.out = grid_size)
  probability <- plogis(theta0 + theta1 * x)

  data.frame(x = x, probability = probability)
}

decision_point_1d <- function(theta0, theta1, threshold) {
  if (abs(theta1) < eps) {
    return(NULL)
  }

  (logit(threshold) - theta0) / theta1
}

threshold_segment <- function(beta0, beta1, beta2, threshold) {
  if (abs(beta1) < eps && abs(beta2) < eps) {
    return(NULL)
  }

  rhs <- logit(threshold) - beta0
  candidates <- matrix(numeric(0), ncol = 2)

  if (abs(beta2) >= eps) {
    for (x1_value in x_limits) {
      x2_value <- (rhs - beta1 * x1_value) / beta2
      if (x2_value >= x_limits[1] - eps && x2_value <= x_limits[2] + eps) {
        candidates <- rbind(
          candidates,
          c(x1_value, min(max(x2_value, x_limits[1]), x_limits[2]))
        )
      }
    }
  }

  if (abs(beta1) >= eps) {
    for (x2_value in x_limits) {
      x1_value <- (rhs - beta2 * x2_value) / beta1
      if (x1_value >= x_limits[1] - eps && x1_value <= x_limits[2] + eps) {
        candidates <- rbind(
          candidates,
          c(min(max(x1_value, x_limits[1]), x_limits[2]), x2_value)
        )
      }
    }
  }

  if (nrow(candidates) == 0) {
    return(NULL)
  }

  rounded <- round(candidates, digits = 8)
  candidates <- candidates[!duplicated(as.data.frame(rounded)), , drop = FALSE]

  if (nrow(candidates) < 2) {
    return(NULL)
  }

  distances <- as.matrix(dist(candidates))
  endpoints <- arrayInd(which.max(distances), dim(distances))
  segment <- candidates[endpoints[1, ], , drop = FALSE]

  list(
    x1 = segment[, 1],
    x2 = segment[, 2],
    z = rep(threshold, 2)
  )
}

format_number <- function(value, digits = 2) {
  formatC(value, format = "f", digits = digits)
}

format_signed_term <- function(coefficient, variable) {
  sign <- if (coefficient >= 0) "+" else "-"
  paste(sign, format_number(abs(coefficient)), "*", variable)
}

format_signed_latex_term <- function(coefficient, variable) {
  sign <- if (coefficient >= 0) "+" else "-"
  paste0(sign, " ", format_number(abs(coefficient)), "\\,", variable)
}

classify_points <- function(points, beta0, beta1, beta2, threshold) {
  probability <- plogis(beta0 + beta1 * points$x1 + beta2 * points$x2)
  data.frame(
    points,
    probability = probability,
    class = ifelse(probability >= threshold, "Class 1", "Class 0"),
    class_z = ifelse(probability >= threshold, 1, 0)
  )
}

classify_points_1d <- function(points, theta0, theta1, threshold) {
  probability <- plogis(theta0 + theta1 * points$x)
  data.frame(
    points,
    probability = probability,
    class = ifelse(probability >= threshold, "Class 1", "Class 0"),
    class_y = ifelse(probability >= threshold, 1, 0)
  )
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
        padding: 18px 16px 28px;
      }

      .app-title {
        margin: 0 0 14px;
        font-size: 25px;
        font-weight: 650;
        letter-spacing: 0;
      }

      .row-title {
        margin: 10px 0 10px;
        font-size: 19px;
        font-weight: 650;
        letter-spacing: 0;
      }

      .main-grid {
        display: grid;
        grid-template-columns: 320px minmax(360px, 1fr) minmax(360px, 1fr);
        gap: 18px;
        align-items: start;
      }

      .main-grid + .main-grid {
        margin-top: 18px;
      }

      .plot-panel,
      .control-panel {
        background: #ffffff;
        border: 1px solid #dce3ec;
        border-radius: 8px;
        box-shadow: 0 1px 2px rgba(17, 24, 39, 0.06);
      }

      .plot-panel {
        padding: 8px;
      }

      .panel-section-title {
        margin: 6px 8px 6px;
        font-size: 16px;
        font-weight: 650;
      }

      .control-panel {
        padding: 16px;
      }

      .control-panel h3 {
        margin: 0 0 12px;
        font-size: 17px;
        font-weight: 650;
      }

      .control-separator {
        border-top: 1px solid #e3e8f0;
        margin: 8px 0 16px;
      }

      .latex-formula {
        margin: 6px 0 12px;
        padding: 8px;
        background: #f3f5f8;
        border-radius: 6px;
        overflow-x: auto;
      }

      .plot-formula {
        margin: 8px 8px 4px;
        font-size: 14px;
      }

      .plot-formula .panel-section-title {
        margin: 0 0 6px;
      }

      .status-note {
        margin-top: 8px;
        color: #5b6472;
      }

      .shiny-input-container {
        margin-bottom: 18px;
      }

      @media (max-width: 900px) {
        .main-grid {
          grid-template-columns: 1fr;
        }

        .control-panel {
          order: -1;
        }
      }
    "))
  ),
  div(
    class = "app-shell",
    h1(class = "app-title", "Logistic Regression"),
    h2(class = "row-title", "2D Logistic Regression Case"),
    div(
      class = "main-grid",
      div(
        class = "control-panel",
        h3("Parameters"),
        sliderInput(
          "beta0",
          HTML("&beta;<sub>0</sub>"),
          min = -10,
          max = 10,
          value = 0,
          step = 0.1
        ),
        sliderInput(
          "beta1",
          HTML("&beta;<sub>1</sub>"),
          min = -3,
          max = 3,
          value = 1,
          step = 0.05
        ),
        sliderInput(
          "beta2",
          HTML("&beta;<sub>2</sub>"),
          min = -3,
          max = 3,
          value = 1,
          step = 0.05
        ),
        div(class = "control-separator"),
        sliderInput(
          "threshold",
          HTML("Decision threshold (&alpha;)"),
          min = 0.01,
          max = 0.99,
          value = 0.5,
          step = 0.01
        ),
        checkboxInput(
          "show_3d_class_projection",
          "Apply threshold rule",
          value = TRUE
        )
      ),
      div(
        class = "plot-panel",
        div(
          class = "plot-formula",
          div(class = "panel-section-title", "Decision boundary"),
          htmlOutput("boundary_formula")
        ),
        div(class = "panel-section-title", "Decision boundary"),
        plotlyOutput("decision_plot", height = "640px")
      ),
      div(
        class = "plot-panel",
        div(
          class = "plot-formula",
          div(class = "panel-section-title", "Logistic model"),
          htmlOutput("model_formula")
        ),
        div(class = "panel-section-title", "Probability surface"),
        plotlyOutput("logistic_plot", height = "640px")
      )
    ),
    h2(class = "row-title", "1D Logistic Regression Case"),
    div(
      class = "main-grid",
      div(
        class = "control-panel",
        h3("Parameters"),
        sliderInput(
          "theta0_1d",
          HTML("&theta;<sub>0</sub>"),
          min = -10,
          max = 10,
          value = 0,
          step = 0.1
        ),
        sliderInput(
          "theta1_1d",
          HTML("&theta;<sub>1</sub>"),
          min = -3,
          max = 3,
          value = 1,
          step = 0.05
        ),
        div(class = "control-separator"),
        sliderInput(
          "threshold_1d",
          HTML("Decision threshold (&alpha;)"),
          min = 0.01,
          max = 0.99,
          value = 0.5,
          step = 0.01
        ),
        checkboxInput(
          "show_1d_threshold_rule",
          "Apply threshold rule",
          value = TRUE
        )
      ),
      div(
        class = "plot-panel",
        div(
          class = "plot-formula",
          div(class = "panel-section-title", "Decision point formula"),
          htmlOutput("decision_formula_1d")
        ),
        div(class = "panel-section-title", "Decision point plot"),
        plotlyOutput("decision_plot_1d", height = "640px")
      ),
      div(
        class = "plot-panel",
        div(
          class = "plot-formula",
          div(class = "panel-section-title", "Logistic model"),
          htmlOutput("model_formula_1d")
        ),
        div(class = "panel-section-title", "Probability curve"),
        plotlyOutput("logistic_plot_1d", height = "640px")
      )
    )
  )
)

server <- function(input, output, session) {
  surface_data <- reactive({
    logistic_surface(input$beta0, input$beta1, input$beta2)
  })

  segment_data <- reactive({
    threshold_segment(input$beta0, input$beta1, input$beta2, input$threshold)
  })

  point_data <- reactive({
    classify_points(
      sample_points,
      input$beta0,
      input$beta1,
      input$beta2,
      input$threshold
    )
  })

  curve_data_1d <- reactive({
    logistic_curve_1d(input$theta0_1d, input$theta1_1d)
  })

  decision_point_data_1d <- reactive({
    decision_point_1d(input$theta0_1d, input$theta1_1d, input$threshold_1d)
  })

  point_data_1d <- reactive({
    classify_points_1d(
      sample_points_1d,
      input$theta0_1d,
      input$theta1_1d,
      input$threshold_1d
    )
  })

  output$logistic_plot <- renderPlotly({
    surface <- surface_data()
    segment <- segment_data()
    points <- point_data()

    plot <- plot_ly() %>%
      add_surface(
        x = surface$x1,
        y = surface$x2,
        z = surface$z,
        colorscale = list(
          c(0, "#6ea8fe"),
          c(0.5, "#315ddc"),
          c(1, "#17158f")
        ),
        name = "Probability",
        showlegend = TRUE,
        showscale = TRUE,
        colorbar = list(
          title = "Probability",
          len = 0.5,
          thickness = 12
        ),
        hovertemplate = paste(
          "x1: %{x:.2f}<br>",
          "x2: %{y:.2f}<br>",
          "p: %{z:.3f}",
          "<extra></extra>"
        )
      ) %>%
      add_trace(
        type = "scatter3d",
        mode = "markers",
        x = points$x1,
        y = points$x2,
        z = points$probability,
        marker = list(
          color = "#6f7785",
          size = 4,
          opacity = 0.88,
          line = list(color = "#ffffff", width = 0.5)
        ),
        name = "Observations",
        customdata = cbind(points$id, points$class),
        hovertemplate = paste(
          "point: %{customdata[0]}<br>",
          "x1: %{x:.2f}<br>",
          "x2: %{y:.2f}<br>",
          "p: %{z:.3f}<br>",
          "%{customdata[1]}",
          "<extra></extra>"
        ),
        showlegend = !isTRUE(input$show_3d_class_projection)
      )

    if (isTRUE(input$show_3d_class_projection)) {
      class_zero <- points[points$class == "Class 0", , drop = FALSE]
      class_one <- points[points$class == "Class 1", , drop = FALSE]
      connector_x <- as.vector(rbind(points$x1, points$x1, NA_real_))
      connector_y <- as.vector(rbind(points$x2, points$x2, NA_real_))
      connector_z <- as.vector(rbind(points$probability, points$class_z, NA_real_))

      plot <- plot %>%
        add_trace(
          type = "scatter3d",
          mode = "lines",
          x = connector_x,
          y = connector_y,
          z = connector_z,
          line = list(color = "rgba(95, 102, 115, 0.62)", width = 2),
          name = "Point projection",
          hoverinfo = "skip",
          showlegend = FALSE
        ) %>%
        add_trace(
          type = "scatter3d",
          mode = "markers",
          x = class_zero$x1,
          y = class_zero$x2,
          z = rep(0, nrow(class_zero)),
          marker = list(
            color = "#d32f2f",
            size = 5,
            line = list(color = "#ffffff", width = 0.7)
          ),
          name = "Class 0",
          customdata = cbind(class_zero$id, class_zero$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 0",
            "<extra></extra>"
          )
        ) %>%
        add_trace(
          type = "scatter3d",
          mode = "markers",
          x = class_one$x1,
          y = class_one$x2,
          z = rep(1, nrow(class_one)),
          marker = list(
            color = "#2e7d32",
            size = 5,
            line = list(color = "#ffffff", width = 0.7)
          ),
          name = "Class 1",
          customdata = cbind(class_one$id, class_one$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 1",
            "<extra></extra>"
          )
        )
    }

    if (!is.null(segment)) {
      curtain_x <- c(segment$x1[1], segment$x1[2], segment$x1[2], segment$x1[1])
      curtain_y <- c(segment$x2[1], segment$x2[2], segment$x2[2], segment$x2[1])
      curtain_z <- c(input$threshold, input$threshold, 0, 0)

      plot <- plot %>%
        add_trace(
          type = "scatter3d",
          mode = "lines",
          x = segment$x1,
          y = segment$x2,
          z = segment$z,
          line = list(color = "#ff7a1a", width = 8),
          name = "Boundary",
          showlegend = TRUE,
          hovertemplate = paste(
            "threshold: %{z:.2f}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}",
            "<extra></extra>"
          )
        ) %>%
        add_trace(
          type = "mesh3d",
          x = curtain_x,
          y = curtain_y,
          z = curtain_z,
          i = c(0, 0),
          j = c(1, 2),
          k = c(2, 3),
          color = "#ff7a1a",
          opacity = 0.28,
          name = "Decision curtain",
          hoverinfo = "skip",
          showlegend = FALSE,
          showscale = FALSE
        )
    }

    plot %>%
      layout(
        margin = list(l = 0, r = 0, b = 0, t = 12),
        scene = list(
          xaxis = list(title = "x1", range = x_limits, zeroline = FALSE),
          yaxis = list(title = "x2", range = x_limits, zeroline = FALSE),
          zaxis = list(title = "p(x1, x2)", range = z_limits),
          camera = list(
            eye = list(x = 1.55, y = -1.65, z = 1.15)
          ),
          aspectratio = list(x = 1, y = 1, z = 0.72)
        ),
        legend = list(
          orientation = "h",
          x = 0.02,
          y = 0.98
        )
      ) %>%
      config(displaylogo = FALSE)
  })

  output$decision_plot <- renderPlotly({
    segment <- segment_data()
    points <- point_data()

    if (isTRUE(input$show_3d_class_projection)) {
      class_zero <- points[points$class == "Class 0", , drop = FALSE]
      class_one <- points[points$class == "Class 1", , drop = FALSE]

      plot <- plot_ly() %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_zero$x1,
          y = class_zero$x2,
          marker = list(
            color = "#d32f2f",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 0",
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p: %{customdata[1]:.3f}",
            "<extra></extra>"
          ),
          customdata = cbind(class_zero$id, class_zero$probability)
        ) %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_one$x1,
          y = class_one$x2,
          marker = list(
            color = "#2e7d32",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 1",
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p: %{customdata[1]:.3f}",
            "<extra></extra>"
          ),
          customdata = cbind(class_one$id, class_one$probability)
        )
    } else {
      plot <- plot_ly() %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = points$x1,
          y = points$x2,
          marker = list(
            color = "#6f7785",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Observations",
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "%{customdata[2]}",
            "<extra></extra>"
          ),
          customdata = cbind(points$id, points$probability, points$class)
        )
    }

    if (!is.null(segment)) {
      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "lines",
          x = segment$x1,
          y = segment$x2,
          line = list(color = "#ff7a1a", width = 4),
          name = "Boundary",
          showlegend = TRUE,
          hovertemplate = paste(
            "x1: %{x:.2f}<br>",
            "x2: %{y:.2f}<br>",
            "p = ",
            format_number(input$threshold, digits = 2),
            "<extra></extra>"
          )
        )
    }

    plot %>%
      layout(
        margin = list(l = 52, r = 18, b = 48, t = 12),
        xaxis = list(
          title = "x1",
          range = x_limits,
          zeroline = TRUE,
          zerolinecolor = "#8993a4",
          gridcolor = "#e3e8f0"
        ),
        yaxis = list(
          title = "x2",
          range = x_limits,
          zeroline = TRUE,
          zerolinecolor = "#8993a4",
          gridcolor = "#e3e8f0",
          scaleanchor = "x",
          scaleratio = 1
        ),
        legend = list(
          orientation = "h",
          x = 0,
          y = 1.08
        ),
        plot_bgcolor = "#ffffff",
        paper_bgcolor = "#ffffff"
      ) %>%
      config(displaylogo = FALSE)
  })

  output$decision_plot_1d <- renderPlotly({
    points <- point_data_1d()
    decision_x <- decision_point_data_1d()
    show_decision <- !is.null(decision_x) &&
      decision_x >= x_limits[1] &&
      decision_x <= x_limits[2]

    plot <- plot_ly() %>%
      add_trace(
        type = "scatter",
        mode = "lines",
        x = x_limits,
        y = c(0, 0),
        line = list(color = "#8993a4", width = 2),
        name = "feature axis",
        hoverinfo = "skip",
        showlegend = FALSE
      )

    if (isTRUE(input$show_1d_threshold_rule)) {
      class_zero <- points[points$class == "Class 0", , drop = FALSE]
      class_one <- points[points$class == "Class 1", , drop = FALSE]

      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_zero$x,
          y = rep(0, nrow(class_zero)),
          marker = list(
            color = "#d32f2f",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 0",
          customdata = cbind(class_zero$id, class_zero$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x: %{x:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 0",
            "<extra></extra>"
          )
        ) %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_one$x,
          y = rep(0, nrow(class_one)),
          marker = list(
            color = "#2e7d32",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 1",
          customdata = cbind(class_one$id, class_one$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x: %{x:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 1",
            "<extra></extra>"
          )
        )
    } else {
      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = points$x,
          y = rep(0, nrow(points)),
          marker = list(
            color = "#6f7785",
            size = 10,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Observations",
          customdata = cbind(points$id, points$probability, points$class),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x: %{x:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "%{customdata[2]}",
            "<extra></extra>"
          )
        )
    }

    if (show_decision) {
      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "lines",
          x = c(decision_x, decision_x),
          y = c(-0.1, 0.1),
          line = list(color = "#ff7a1a", width = 4),
          name = "Decision",
          showlegend = TRUE,
          hovertemplate = paste(
            "x*: %{x:.3f}",
            "<extra></extra>"
          )
        )
    }

    plot %>%
      layout(
        margin = list(l = 52, r = 18, b = 48, t = 12),
        xaxis = list(
          title = "x",
          range = x_limits,
          zeroline = FALSE,
          showgrid = FALSE
        ),
        yaxis = list(
          title = "",
          range = c(-0.14, 0.14),
          showticklabels = FALSE,
          ticks = "",
          zeroline = FALSE,
          showgrid = FALSE,
          fixedrange = TRUE
        ),
        legend = list(
          orientation = "h",
          x = 0,
          y = 1.08
        ),
        plot_bgcolor = "#ffffff",
        paper_bgcolor = "#ffffff"
      ) %>%
      config(displaylogo = FALSE)
  })

  output$logistic_plot_1d <- renderPlotly({
    curve <- curve_data_1d()
    points <- point_data_1d()
    decision_x <- decision_point_data_1d()
    show_decision <- !is.null(decision_x) &&
      decision_x >= x_limits[1] &&
      decision_x <= x_limits[2]

    plot <- plot_ly() %>%
      add_trace(
        type = "scatter",
        mode = "lines",
        x = curve$x,
        y = curve$probability,
        line = list(color = "#315ddc", width = 4),
        name = "p(y = 1 | x)",
        hovertemplate = paste(
          "x: %{x:.2f}<br>",
          "p: %{y:.3f}",
          "<extra></extra>"
        )
      ) %>%
      add_trace(
        type = "scatter",
        mode = "lines",
        x = x_limits,
        y = rep(input$threshold_1d, 2),
        line = list(color = "#ff7a1a", width = 3),
        name = "Threshold",
        showlegend = TRUE,
        hovertemplate = paste(
          "threshold: %{y:.2f}",
          "<extra></extra>"
        )
      ) %>%
      add_trace(
        type = "scatter",
        mode = "markers",
        x = points$x,
        y = points$probability,
        marker = list(
          color = "#6f7785",
          size = 8,
          opacity = 0.88,
          line = list(color = "#ffffff", width = 1)
        ),
        name = "Observations",
        showlegend = !isTRUE(input$show_1d_threshold_rule),
        customdata = cbind(points$id, points$class),
        hovertemplate = paste(
          "point: %{customdata[0]}<br>",
          "x: %{x:.2f}<br>",
          "p: %{y:.3f}<br>",
          "%{customdata[1]}",
          "<extra></extra>"
        )
      )

    if (show_decision) {
      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "lines",
          x = c(decision_x, decision_x),
          y = z_limits,
          line = list(color = "#ff7a1a", width = 3, dash = "dot"),
          name = "Decision",
          showlegend = TRUE,
          hovertemplate = paste(
            "x*: %{x:.3f}",
            "<extra></extra>"
          )
        )
    }

    if (isTRUE(input$show_1d_threshold_rule)) {
      class_zero <- points[points$class == "Class 0", , drop = FALSE]
      class_one <- points[points$class == "Class 1", , drop = FALSE]
      connector_x <- as.vector(rbind(points$x, points$x, NA_real_))
      connector_y <- as.vector(rbind(points$probability, points$class_y, NA_real_))

      plot <- plot %>%
        add_trace(
          type = "scatter",
          mode = "lines",
          x = connector_x,
          y = connector_y,
          line = list(color = "rgba(95, 102, 115, 0.62)", width = 2),
          name = "projection",
          hoverinfo = "skip",
          showlegend = FALSE
        ) %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_zero$x,
          y = rep(0, nrow(class_zero)),
          marker = list(
            color = "#d32f2f",
            size = 9,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 0",
          customdata = cbind(class_zero$id, class_zero$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x: %{x:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 0",
            "<extra></extra>"
          )
        ) %>%
        add_trace(
          type = "scatter",
          mode = "markers",
          x = class_one$x,
          y = rep(1, nrow(class_one)),
          marker = list(
            color = "#2e7d32",
            size = 9,
            line = list(color = "#ffffff", width = 1)
          ),
          name = "Class 1",
          customdata = cbind(class_one$id, class_one$probability),
          hovertemplate = paste(
            "point: %{customdata[0]}<br>",
            "x: %{x:.2f}<br>",
            "p: %{customdata[1]:.3f}<br>",
            "Class 1",
            "<extra></extra>"
          )
        )
    }

    plot %>%
      layout(
        margin = list(l = 52, r = 18, b = 48, t = 12),
        xaxis = list(
          title = "x",
          range = x_limits,
          zeroline = TRUE,
          zerolinecolor = "#8993a4",
          gridcolor = "#e3e8f0"
        ),
        yaxis = list(
          title = "p(y = 1 | x)",
          range = c(-0.12, 1.12),
          tickmode = "array",
          tickvals = c(0, 0.5, 1),
          zeroline = FALSE,
          gridcolor = "#e3e8f0"
        ),
        legend = list(
          orientation = "h",
          x = 0,
          y = 1.08
        ),
        plot_bgcolor = "#ffffff",
        paper_bgcolor = "#ffffff"
      ) %>%
      config(displaylogo = FALSE)
  })

  output$model_formula <- renderUI({
    theta0 <- format_number(input$beta0)
    theta1 <- format_number(input$beta1)
    theta2 <- format_number(input$beta2)
    linear_predictor <- paste0(
      theta0,
      " ",
      format_signed_latex_term(input$beta1, "x_1"),
      " ",
      format_signed_latex_term(input$beta2, "x_2")
    )

    withMathJax(
      tags$div(
        class = "latex-formula",
        HTML(
          paste0(
            "\\[",
            "\\boldsymbol{\\theta} = ",
            "\\begin{pmatrix}\\theta_0 \\\\ \\theta_1 \\\\ \\theta_2\\end{pmatrix}",
            " = ",
            "\\begin{pmatrix}",
            theta0,
            " \\\\ ",
            theta1,
            " \\\\ ",
            theta2,
            "\\end{pmatrix}",
            "\\]",
            "\\[",
            "p(y=1 \\mid x_1, x_2; \\boldsymbol{\\theta}) = ",
            "\\frac{1}{1 + \\exp\\left(-\\left(",
            linear_predictor,
            "\\right)\\right)}",
            "\\]"
          )
        )
      )
    )
  })

  output$boundary_formula <- renderUI({
    theta0 <- format_number(input$beta0)
    theta1 <- format_signed_latex_term(input$beta1, "x_1")
    theta2 <- format_signed_latex_term(input$beta2, "x_2")
    rhs <- format_number(logit(input$threshold), digits = 3)

    withMathJax(
      tags$div(
        class = "latex-formula",
        HTML(
          paste0(
            "\\[",
            "\\theta_0 + \\theta_1 x_1 + \\theta_2 x_2 = ",
            "-\\log\\left(\\frac{1}{\\alpha} - 1\\right)",
            "\\]",
            "\\[",
            theta0,
            " ",
            theta1,
            " ",
            theta2,
            " = ",
            rhs,
            "\\]"
          )
        )
      )
    )
  })

  output$model_formula_1d <- renderUI({
    theta0 <- format_number(input$theta0_1d)
    theta1 <- format_number(input$theta1_1d)
    linear_predictor <- paste0(
      theta0,
      " ",
      format_signed_latex_term(input$theta1_1d, "x")
    )

    withMathJax(
      tags$div(
        class = "latex-formula",
        HTML(
          paste0(
            "\\[",
            "\\boldsymbol{\\theta} = ",
            "\\begin{pmatrix}\\theta_0 \\\\ \\theta_1\\end{pmatrix}",
            " = ",
            "\\begin{pmatrix}",
            theta0,
            " \\\\ ",
            theta1,
            "\\end{pmatrix}",
            "\\]",
            "\\[",
            "p(y=1 \\mid x; \\boldsymbol{\\theta}) = ",
            "\\frac{1}{1 + \\exp\\left(-\\left(",
            linear_predictor,
            "\\right)\\right)}",
            "\\]"
          )
        )
      )
    )
  })

  output$decision_formula_1d <- renderUI({
    theta0 <- format_number(input$theta0_1d)
    theta1 <- format_number(input$theta1_1d)
    rhs <- format_number(logit(input$threshold_1d), digits = 3)
    decision_x <- decision_point_data_1d()
    numeric_line <- if (is.null(decision_x)) {
      paste0("\\theta_1 = ", theta1)
    } else {
      paste0(
        "x^* = \\frac{",
        rhs,
        " - ",
        theta0,
        "}{",
        theta1,
        "} = ",
        format_number(decision_x, digits = 3)
      )
    }

    withMathJax(
      tags$div(
        class = "latex-formula",
        HTML(
          paste0(
            "\\[",
            "x^* = ",
            "\\frac{-\\log\\left(\\frac{1}{\\alpha} - 1\\right) - \\theta_0}{\\theta_1}",
            "\\]",
            "\\[",
            numeric_line,
            "\\]"
          )
        )
      )
    )
  })

}

shinyApp(ui, server)
