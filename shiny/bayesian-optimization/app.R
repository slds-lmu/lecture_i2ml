library(shiny)
library(ggplot2)

x_limits <- c(0, 1)
main_y_limits <- c(-2.15, 2.15)
jitter <- 1e-8

empty_samples <- function() {
  data.frame(
    step = integer(),
    x = numeric(),
    y = numeric()
  )
}

truth_function <- function(x) {
  0.65 * sin(4.5 * pi * x) +
    0.22 * sin(11 * pi * x) +
    1.8 * (x - 0.70)^2 +
    0.05 * x
}

normalize_numeric <- function(value, default, minimum, maximum) {
  if (is.null(value) || length(value) == 0L || is.na(value)) {
    value <- default
  }

  value <- suppressWarnings(as.numeric(value[[1L]]))
  if (is.na(value)) {
    value <- default
  }

  min(maximum, max(minimum, value))
}

normalize_integer <- function(value, default, minimum, maximum) {
  value <- normalize_numeric(value, default, minimum, maximum)
  min(maximum, max(minimum, as.integer(round(value))))
}

range_with_padding <- function(x, padding = 0.08) {
  range_values <- range(x, finite = TRUE)
  if (!all(is.finite(range_values))) {
    range_values <- c(0, 1)
  }

  width <- diff(range_values)
  if (width == 0) {
    width <- max(abs(range_values), 1)
  }

  range_values + c(-1, 1) * padding * width
}

candidate_grid <- function(grid_size) {
  seq(x_limits[1L], x_limits[2L], length.out = grid_size)
}

squared_exp_kernel <- function(x_one, x_two, length_scale) {
  outer(
    x_one,
    x_two,
    FUN = function(a, b) {
      exp(-0.5 * ((a - b) / length_scale)^2)
    }
  )
}

gp_posterior <- function(samples, grid, length_scale, noise_sd) {
  if (nrow(samples) == 0L) {
    return(data.frame(
      x = grid,
      mu = rep(0, length(grid)),
      sd = rep(1, length(grid)),
      lower = rep(-1.96, length(grid)),
      upper = rep(1.96, length(grid))
    ))
  }

  n_train <- nrow(samples)
  train_kernel <- squared_exp_kernel(samples$x, samples$x, length_scale) +
    diag(noise_sd^2 + jitter, n_train)
  cross_kernel <- squared_exp_kernel(grid, samples$x, length_scale)

  chol_kernel <- tryCatch(
    chol(train_kernel),
    error = function(e) chol(train_kernel + diag(1e-6, n_train))
  )
  alpha <- backsolve(
    chol_kernel,
    forwardsolve(t(chol_kernel), samples$y)
  )
  mu <- as.vector(cross_kernel %*% alpha)
  v <- forwardsolve(t(chol_kernel), t(cross_kernel))
  variance <- pmax(1 - colSums(v^2), 0)
  sd <- sqrt(variance)

  data.frame(
    x = grid,
    mu = mu,
    sd = sd,
    lower = mu - 1.96 * sd,
    upper = mu + 1.96 * sd
  )
}

acquisition_values <- function(method, posterior, samples, kappa) {
  score <- switch(
    method,
    mean = posterior$mu,
    lcb = posterior$mu - kappa * posterior$sd,
    ei = {
      if (nrow(samples) == 0L) {
        rep(0, nrow(posterior))
      } else {
        sigma <- pmax(posterior$sd, 1e-9)
        improvement <- min(samples$y) - posterior$mu
        z <- improvement / sigma
        pmax(improvement * pnorm(z) + sigma * dnorm(z), 0)
      }
    },
    posterior$mu
  )

  data.frame(
    x = posterior$x,
    score = score
  )
}

first_candidate <- function(method) {
  switch(
    method,
    mean = 0.18,
    lcb = 0.50,
    ei = 0.82,
    0.50
  )
}

is_unsampled <- function(grid, samples) {
  if (nrow(samples) == 0L) {
    return(rep(TRUE, length(grid)))
  }

  grid_step <- diff(range(x_limits)) / max(length(grid) - 1L, 1L)
  vapply(
    grid,
    function(x) !any(abs(samples$x - x) <= grid_step / 2),
    logical(1)
  )
}

best_tie_index <- function(values, maximize = FALSE) {
  if (maximize) {
    best_value <- max(values, na.rm = TRUE)
  } else {
    best_value <- min(values, na.rm = TRUE)
  }

  tolerance <- sqrt(.Machine$double.eps) * max(1, abs(best_value))
  which(abs(values - best_value) <= tolerance)[1L]
}

next_candidate <- function(method, samples, grid, acquisition) {
  if (nrow(samples) == 0L) {
    return(first_candidate(method))
  }

  candidate_rows <- is_unsampled(grid, samples)
  if (!any(candidate_rows)) {
    return(NA_real_)
  }

  candidate_acquisition <- acquisition[candidate_rows, , drop = FALSE]
  selected_row <- best_tie_index(
    candidate_acquisition$score,
    maximize = identical(method, "ei")
  )
  candidate_acquisition$x[[selected_row]]
}

nearest_row <- function(data, x) {
  if (length(x) == 0L || is.na(x)) {
    return(data[FALSE, , drop = FALSE])
  }

  data[which.min(abs(data$x - x)), , drop = FALSE]
}

make_bundle <- function(method, samples, controls) {
  grid <- candidate_grid(controls$grid_size)
  posterior <- gp_posterior(
    samples,
    grid,
    length_scale = controls$length_scale,
    noise_sd = controls$noise_sd
  )
  acquisition <- acquisition_values(
    method,
    posterior,
    samples,
    kappa = controls$kappa
  )
  next_x <- next_candidate(method, samples, grid, acquisition)

  list(
    method = method,
    samples = samples,
    truth = data.frame(x = grid, y = truth_function(grid)),
    posterior = posterior,
    acquisition = acquisition,
    next_x = next_x,
    next_posterior = nearest_row(posterior, next_x),
    next_acquisition = nearest_row(acquisition, next_x)
  )
}

main_plot <- function(bundle, show_uncertainty, show_truth, show_proposal) {
  plot <- ggplot()

  if (isTRUE(show_uncertainty)) {
    plot <- plot +
      geom_ribbon(
        data = bundle$posterior,
        aes(x = x, ymin = lower, ymax = upper),
        fill = "#6ea8fe",
        alpha = 0.18,
        inherit.aes = FALSE
      )
  }

  plot <- plot +
    geom_hline(yintercept = 0, colour = "#ccd3dd", linewidth = 0.35)

  if (isTRUE(show_truth)) {
    plot <- plot +
      geom_line(
        data = bundle$truth,
        aes(x = x, y = y, colour = "Truth"),
        linewidth = 1.05,
        inherit.aes = FALSE
      )
  }

  plot <- plot +
    geom_line(
      data = bundle$posterior,
      aes(x = x, y = mu, colour = "GP mean"),
      linewidth = 1.05,
      inherit.aes = FALSE
    )

  if (isTRUE(show_proposal)) {
    plot <- plot +
      geom_vline(
        xintercept = bundle$next_x,
        colour = "#d95f02",
        linewidth = 0.65,
        linetype = 2L,
        na.rm = TRUE
      ) +
      geom_point(
        data = bundle$next_posterior,
        aes(x = x, y = mu),
        shape = 23,
        size = 3.2,
        stroke = 0.8,
        fill = "#d95f02",
        colour = "#7a3300",
        inherit.aes = FALSE,
        na.rm = TRUE
      )
  }

  plot +
    geom_point(
      data = bundle$samples,
      aes(x = x, y = y),
      colour = "#172033",
      fill = "#ffffff",
      shape = 21,
      stroke = 0.8,
      size = 2.7,
      inherit.aes = FALSE
    ) +
    scale_colour_manual(
      values = c("Truth" = "#ff8c1a", "GP mean" = "#3366FF"),
      breaks = c("Truth", "GP mean"),
      name = NULL
    ) +
    coord_cartesian(
      xlim = x_limits,
      ylim = main_y_limits,
      expand = FALSE
    ) +
    labs(
      x = "x",
      y = "objective f(x)"
    ) +
    theme_classic() +
    theme(
      legend.position = "top",
      legend.margin = margin(0, 0, 0, 0),
      legend.box.margin = margin(-4, 0, -5, 0),
      plot.margin = margin(5.5, 7, 5.5, 5.5)
    )
}

acquisition_plot <- function(bundle, y_label, show_proposal) {
  y_limits <- range_with_padding(bundle$acquisition$score)

  plot <- ggplot(bundle$acquisition, aes(x = x, y = score)) +
    geom_hline(yintercept = 0, colour = "#e3e8f0", linewidth = 0.35) +
    geom_line(colour = "#00A651", linewidth = 1.05)

  if (isTRUE(show_proposal)) {
    plot <- plot +
      geom_vline(
        xintercept = bundle$next_x,
        colour = "#d95f02",
        linewidth = 0.65,
        linetype = 2L,
        na.rm = TRUE
      ) +
      geom_point(
        data = bundle$next_acquisition,
        aes(x = x, y = score),
        shape = 23,
        size = 3,
        stroke = 0.8,
        fill = "#d95f02",
        colour = "#7a3300",
        inherit.aes = FALSE,
        na.rm = TRUE
      )
  }

  plot +
    coord_cartesian(
      xlim = x_limits,
      ylim = y_limits,
      expand = FALSE
    ) +
    labs(
      x = "x",
      y = y_label
    ) +
    theme_classic() +
    theme(
      plot.margin = margin(5.5, 7, 5.5, 5.5)
    )
}

button_row <- function(id, proposed, draw_count) {
  propose_button <- if (isTRUE(proposed)) {
    actionButton(
      inputId = paste0("propose_", id),
      label = "Propose",
      class = "btn-default inactive-action",
      disabled = "disabled"
    )
  } else {
    actionButton(
      inputId = paste0("propose_", id),
      label = "Propose",
      class = "btn-success"
    )
  }

  evaluate_button <- if (isTRUE(proposed)) {
    actionButton(
      inputId = paste0("evaluate_", id),
      label = "Evaluate",
      class = "btn-success"
    )
  } else {
    actionButton(
      inputId = paste0("evaluate_", id),
      label = "Evaluate",
      class = "btn-default inactive-action",
      disabled = "disabled"
    )
  }

  div(
    class = "button-row",
    actionButton(
      inputId = paste0("restart_", id),
      label = "Restart"
    ),
    propose_button,
    evaluate_button,
    div(
      class = "draw-count-window",
      paste("draws:", draw_count)
    )
  )
}

method_panel <- function(id, title, subtitle) {
  div(
    class = "method-panel",
    div(
      class = "method-header",
      div(
        div(class = "panel-title", title),
        div(class = "panel-subtitle", subtitle)
      ),
      uiOutput(paste0("button_row_", id))
    ),
    plotOutput(paste0("main_", id), height = "360px"),
    div(class = "acquisition-label", "Acquisition"),
    plotOutput(paste0("acquisition_", id), height = "210px")
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
        max-width: 1560px;
        margin: 0 auto;
        padding: 18px 16px 32px;
      }

      .app-title {
        margin: 0 0 14px;
        font-size: 26px;
        font-weight: 650;
        letter-spacing: 0;
      }

      .top-control-wrap {
        display: flex;
        justify-content: center;
        margin-bottom: 18px;
      }

      .control-panel,
      .method-panel {
        background: #ffffff;
        border: 1px solid #dce3ec;
        border-radius: 8px;
        box-shadow: 0 1px 2px rgba(17, 24, 39, 0.06);
      }

      .control-panel {
        max-width: 840px;
        padding: 16px 18px 12px;
        width: 100%;
      }

      .control-panel h3 {
        margin: 0 0 12px;
        font-size: 17px;
        font-weight: 650;
      }

      .control-grid {
        display: grid;
        gap: 2px 18px;
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .control-grid .form-group,
      .control-grid .checkbox {
        margin-bottom: 12px;
      }

      .method-grid {
        display: grid;
        gap: 16px;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        align-items: start;
      }

      .method-panel {
        min-width: 0;
        padding: 12px 12px 14px;
      }

      .method-header {
        align-items: flex-start;
        display: flex;
        gap: 10px;
        justify-content: space-between;
        margin-bottom: 8px;
      }

      .panel-title {
        margin: 0;
        font-size: 16px;
        font-weight: 650;
      }

      .panel-subtitle {
        color: #5b6472;
        font-size: 12px;
        margin-top: 2px;
      }

      .button-row {
        align-items: stretch;
        display: flex;
        flex: 0 0 auto;
        gap: 8px;
      }

      .button-row .btn {
        min-width: 74px;
      }

      .draw-count-window {
        align-items: center;
        background: #ffffff;
        border: 1px solid #c8d1dd;
        border-radius: 4px;
        color: #344054;
        display: flex;
        font-size: 13px;
        font-weight: 600;
        justify-content: center;
        min-height: 34px;
        min-width: 74px;
        padding: 6px 10px;
        white-space: nowrap;
      }

      .button-row .inactive-action,
      .button-row .inactive-action[disabled] {
        background-color: #e8edf3;
        border-color: #c8d1dd;
        color: #6f7785;
        opacity: 1;
      }

      .acquisition-label {
        color: #5b6472;
        font-size: 12px;
        font-weight: 650;
        margin: 4px 0 0 2px;
        text-transform: uppercase;
      }

      .shiny-input-container {
        margin-bottom: 12px;
      }

      @media (max-width: 1150px) {
        .method-grid {
          grid-template-columns: 1fr;
        }
      }

      @media (max-width: 700px) {
        .control-grid {
          grid-template-columns: 1fr;
        }

        .method-header {
          display: block;
        }

        .button-row {
          margin-top: 10px;
        }
      }
    "))
  ),
  div(
    class = "app-shell",
    h1(class = "app-title", "Bayesian Optimization"),
    div(
      class = "top-control-wrap",
      div(
        class = "control-panel",
        h3("Overall parameters"),
        div(
          class = "control-grid",
          sliderInput(
            inputId = "length_scale",
            label = "GP length-scale",
            min = 0.04,
            max = 0.35,
            value = 0.16,
            step = 0.01
          ),
          sliderInput(
            inputId = "noise_sd",
            label = "GP noise / nugget",
            min = 0,
            max = 0.20,
            value = 0.03,
            step = 0.005
          ),
          sliderInput(
            inputId = "kappa",
            label = "LCB exploration strength",
            min = 0,
            max = 4,
            value = 1.5,
            step = 0.1
          ),
          sliderInput(
            inputId = "grid_size",
            label = "Candidate grid resolution",
            min = 101,
            max = 801,
            value = 401,
            step = 50
          ),
          checkboxInput(
            inputId = "show_uncertainty",
            label = "Show GP uncertainty band",
            value = TRUE
          ),
          checkboxInput(
            inputId = "show_truth",
            label = "Show oracle truth function",
            value = TRUE
          )
        )
      )
    ),
    div(
      class = "method-grid",
      method_panel(
        id = "mean",
        title = "Posterior mean",
        subtitle = "Minimize the current GP mean"
      ),
      method_panel(
        id = "lcb",
        title = "Lower confidence bound",
        subtitle = "Minimize mu - kappa * sigma"
      ),
      method_panel(
        id = "ei",
        title = "Expected improvement",
        subtitle = "Maximize expected improvement"
      )
    )
  )
)

server <- function(input, output, session) {
  mean_samples <- reactiveVal(empty_samples())
  lcb_samples <- reactiveVal(empty_samples())
  ei_samples <- reactiveVal(empty_samples())
  mean_proposed <- reactiveVal(FALSE)
  lcb_proposed <- reactiveVal(FALSE)
  ei_proposed <- reactiveVal(FALSE)

  controls <- reactive({
    list(
      length_scale = normalize_numeric(input$length_scale, default = 0.16, minimum = 0.04, maximum = 0.35),
      noise_sd = normalize_numeric(input$noise_sd, default = 0.03, minimum = 0, maximum = 0.20),
      kappa = normalize_numeric(input$kappa, default = 1.5, minimum = 0, maximum = 4),
      grid_size = normalize_integer(input$grid_size, default = 401L, minimum = 101L, maximum = 801L),
      show_uncertainty = is.null(input$show_uncertainty) || isTRUE(input$show_uncertainty),
      show_truth = is.null(input$show_truth) || isTRUE(input$show_truth)
    )
  })

  propose_optimizer <- function(samples_state, proposed_state, method) {
    bundle <- make_bundle(method, samples_state(), controls())
    if (is.na(bundle$next_x)) {
      return(invisible(NULL))
    }

    proposed_state(TRUE)
  }

  evaluate_optimizer <- function(samples_state, proposed_state, method) {
    if (!isTRUE(proposed_state())) {
      return(invisible(NULL))
    }

    samples <- samples_state()
    current_controls <- controls()
    bundle <- make_bundle(method, samples, current_controls)
    if (is.na(bundle$next_x)) {
      proposed_state(FALSE)
      return(invisible(NULL))
    }

    next_row <- data.frame(
      step = nrow(samples) + 1L,
      x = bundle$next_x,
      y = truth_function(bundle$next_x)
    )
    samples_state(rbind(samples, next_row))
    proposed_state(FALSE)
  }

  observeEvent(input$restart_mean, {
    mean_samples(empty_samples())
    mean_proposed(FALSE)
  })

  observeEvent(input$restart_lcb, {
    lcb_samples(empty_samples())
    lcb_proposed(FALSE)
  })

  observeEvent(input$restart_ei, {
    ei_samples(empty_samples())
    ei_proposed(FALSE)
  })

  observeEvent(input$propose_mean, {
    propose_optimizer(mean_samples, mean_proposed, "mean")
  })

  observeEvent(input$propose_lcb, {
    propose_optimizer(lcb_samples, lcb_proposed, "lcb")
  })

  observeEvent(input$propose_ei, {
    propose_optimizer(ei_samples, ei_proposed, "ei")
  })

  observeEvent(input$evaluate_mean, {
    evaluate_optimizer(mean_samples, mean_proposed, "mean")
  })

  observeEvent(input$evaluate_lcb, {
    evaluate_optimizer(lcb_samples, lcb_proposed, "lcb")
  })

  observeEvent(input$evaluate_ei, {
    evaluate_optimizer(ei_samples, ei_proposed, "ei")
  })

  mean_bundle <- reactive({
    make_bundle("mean", mean_samples(), controls())
  })

  lcb_bundle <- reactive({
    make_bundle("lcb", lcb_samples(), controls())
  })

  ei_bundle <- reactive({
    make_bundle("ei", ei_samples(), controls())
  })

  output$button_row_mean <- renderUI({
    button_row("mean", mean_proposed(), nrow(mean_samples()))
  })

  output$button_row_lcb <- renderUI({
    button_row("lcb", lcb_proposed(), nrow(lcb_samples()))
  })

  output$button_row_ei <- renderUI({
    button_row("ei", ei_proposed(), nrow(ei_samples()))
  })

  output$main_mean <- renderPlot({
    current_controls <- controls()
    main_plot(
      mean_bundle(),
      show_uncertainty = current_controls$show_uncertainty,
      show_truth = current_controls$show_truth,
      show_proposal = mean_proposed()
    )
  })

  output$main_lcb <- renderPlot({
    current_controls <- controls()
    main_plot(
      lcb_bundle(),
      show_uncertainty = current_controls$show_uncertainty,
      show_truth = current_controls$show_truth,
      show_proposal = lcb_proposed()
    )
  })

  output$main_ei <- renderPlot({
    current_controls <- controls()
    main_plot(
      ei_bundle(),
      show_uncertainty = current_controls$show_uncertainty,
      show_truth = current_controls$show_truth,
      show_proposal = ei_proposed()
    )
  })

  output$acquisition_mean <- renderPlot({
    acquisition_plot(
      mean_bundle(),
      "GP mean (smaller is better)",
      show_proposal = mean_proposed()
    )
  })

  output$acquisition_lcb <- renderPlot({
    acquisition_plot(
      lcb_bundle(),
      "LCB (smaller is better)",
      show_proposal = lcb_proposed()
    )
  })

  output$acquisition_ei <- renderPlot({
    acquisition_plot(
      ei_bundle(),
      "EI (larger is better)",
      show_proposal = ei_proposed()
    )
  })
}

shinyApp(ui = ui, server = server)
