#  -----------------------------------------------------------------------------
#  LIBRARY FUNCTIONS
#  -----------------------------------------------------------------------------

library(checkmate)
library(data.table)
library(ggplot2)
library(MASS)
library(mlr3verse)
library(plotly)
library(quantreg)
library(R6)
library(reshape2)
library(stringr)

# BASE REGRESSION CLASS --------------------------------------------------------

#' RegressionComputer class
#' Computes regression for tabular data.
RegressionComputer <- R6Class(
    "RegressionComputer",
    public = list(
        #' @field data_table Data to predict on.
        data_table = NULL,
        #' @field id ID of regression computation.
        formula = list(),
        #' @field coefficients Regression coefficients
        coefficients = list(),
        #' @field loss_names (`list()`) Loss function name.
        loss_names = list(),
        #' @param loss_params (`list()`) List of parameters to loss function.
        loss_params = list(),
        #' @param loss_function (`list()`) Loss function.
        loss_functions = list(),
        #' @field regression_data Regression data.
        regression_data = list(),
        #' @description Creates a new instance of this class.
        #' @param data_table (`data.frame()`) Data to plot in long format.
        initialize = function(data_table) {
            assert_data_frame(data_table)
            self$data_table = as.data.table(data_table)
            return(invisible(self))
        },
        #' @description Compute regression.
        #' @param id (`character(1)`) ID to reference results.
        #' @param formula (`character(1)`) LM formula to use.
        #' @param loss (`character(1)`) Loss function to use.
        #' @param custom_loss (`function()`) Custom loss acting on residuals.
        computeRegression = function(
            id,
            formula = y ~ ., 
            loss = "quadratic", 
            loss_params = NULL, 
            custom_loss = NULL, 
            ...
        ) {
            args = list(...)
            if (id %in% do.call(rbind, self$regression_data)$id) {
                stop(sprintf("ID `%s` already exists.", id))
            }
            this_formula <- list(formula)
            this_loss_name <- list(loss)
            names(this_formula) <- names(this_loss_name) <- id
            self$formula <- append(self$formula, this_formula)
            self$loss_names <- append(self$loss_names, this_loss_name)
            self$loss_params <- append(self$loss_params, loss_params)
            supported_losses <- c(
                "quadratic",
                "absolute",
                "huber",
                "logcosh",
                "logbarrier",
                "epsiloninsensitive",
                "pinball",
                "cauchy",
                "custom"
            )
            if (!loss %in% supported_losses) {
                stop(
                    sprintf(
                        "Unknown loss. Supported losses: %s",
                        paste(supported_losses, collapse = ", ")
                    )
                )
            }
            else if (loss == "quadratic") {
                model <- lm(as.formula(formula), self$data_table)
                loss_fun <- function(x) x**2 
                private$add_regression_data(id, formula, loss, loss_fun, model)
            }
            else if (loss == "absolute") {
                model <- quantreg::rq(
                    as.formula(formula), data = self$data_table
                )
                loss_fun <- function(x) abs(x) 
                private$add_regression_data(id, formula, loss, loss_fun, model)
            }
            else if (loss == "huber") {
                epsilon <- private$set_loss_param("epsilon", 0.5)
                model <- MASS::rlm(
                    as.formula(formula),
                    data = self$data_table,
                    scale.est = "Huber",
                    k2 = epsilon,
                    maxit = 100
                )
                loss_fun <- function(x) {
                    ifelse(
                        abs(x) <= epsilon, 
                        0.5 * x**2, 
                        epsilon * abs(x) - 0.5 * epsilon**2
                    )
                } 
                private$add_regression_data(id, formula, loss, loss_fun, model)
            }
            else if (loss == "logcosh") {
                loss_fun <- function(x) log(cosh(abs(x)))
                private$add_regression_data(id, formula, loss, loss_fun)
            }
            else if (loss == "logbarrier") {
                epsilon <- private$set_loss_param("epsilon", 1)
                loss_fun <- function(x) {
                    abs_res <- abs(x)
                    abs_res[abs_res > epsilon] <- Inf
                    abs_res[abs_res <= epsilon] <- -epsilon**2 * log(
                        1 - (abs_res[abs_res <= epsilon] / epsilon)**2
                    )
                    abs_res
                }
                private$add_regression_data(id, formula, loss, loss_fun)
            }
            else if (loss == "epsiloninsensitive") {
                epsilon <- private$set_loss_param("epsilon", 1L)
                loss_fun <- function(x) {
                    ifelse(abs(x) > epsilon, abs(x) - epsilon, 0L)
                }
                private$add_regression_data(id, formula, loss, loss_fun)
            }
            else if (loss == "pinball") {
                quantile <- private$set_loss_param("quantile", 1L)
                loss_fun <- function(x) {
                    ifelse(x < 0, ((1 - quantile) * (-x)), quantile * x)
                }
                private$add_regression_data(id, formula, loss, loss_fun)
            }
            else if (loss == "cauchy") {
                epsilon <- private$set_loss_param("epsilon", 1L)
                loss_fun <- function(x) {
                    0.5 * epsilon**2 * log(1 + (x / epsilon)**2)
                }
                private$add_regression_data(id, formula, loss, loss_fun)
            }
            else if (loss == "custom") {
                if (is.null(custom_loss)) stop("Please provide loss function.")
                else loss_fun <- custom_loss
                private$add_regression_data(id, formula, loss, loss_fun)
            }
        }
    ),
    private = list(
        #' @description Compute regression and store results.
        #' @param id (`character(1)`) ID to reference results.
        #' @param formula (`character(1)`) LM formula to use.
        #' @param loss (`character(1)`) LM formula to use.
        #' @param loss_fun (`function()`) List of loss functions to use.
        #' @param model (`lm()`) Optional model object.
        add_regression_data = function(
            id, formula, loss, loss_fun, model = NULL
        ) {
            base_model <- lm(as.formula(formula), self$data_table)
            x_mat <- model.matrix(base_model)
            if (is.null(model)) {
                model <- base_model
                objective <- function(theta) {
                    with(
                        self$data_table, 
                        sum(loss_fun(y - model.matrix(model) %*% theta))
                    )
                }
                coefficients <- optim(
                    coefficients(model), objective, method = "BFGS"
                )$par
            }
            else coefficients <- coefficients(model)
            this_coefficients <- list(coefficients)
            this_loss_fun <- list(loss_fun)
            names(this_coefficients) <- names(this_loss_fun) <- id
            self$coefficients <- append(self$coefficients, this_coefficients)
            dt <- copy(self$data_table)[
                , `:=`(id = id, loss = loss, y_hat = x_mat %*% coefficients)
                ][, `:=`(
                    residual = y - y_hat,
                    formula = list(formula),
                    coefficients = list(coefficients)
                )]
            self$regression_data <- append(
                self$regression_data, 
                list(dt)
            )
            self$loss_functions <- append(self$loss_functions, this_loss_fun)
        },
        set_loss_param = function(param_name, default) {
            if (is.null(self$loss_params[[param_name]])) {
                print(
                    paste(
                        sprintf(
                            "Setting %s to %.2f. Change by specifying",
                            param_name,
                            default
                        ),
                        sprintf("`loss_params = list(%s = ...)`", param_name)
                    )
                )
                return(default)
            }
            else return(self$loss_params[[param_name]])
        }
    )
)

# BASE REGRESSION CLASS --------------------------------------------------------

#' RegressionPlotter class
#' Creates regression plots from univariate or bivariate data.
RegressionPlotter <- R6Class(
    "RegressionPlotter",
    public = list(
        #' @field data_table Data to plot.
        data_table = NULL,
        #' @description Creates a new instance of this class.
        #' @param data_table (`data.frame()`) Data to plot in long format.
        initialize = function(data_table) {
            assert_data_frame(data_table)
            self$data_table = as.data.table(data_table)
            return(invisible(self))
        },
        
        #' @description Initialize two-dimensional plot.
        #' @param formula (`formula()`) Formula to plot.
        #' @param ... Further arguments passed to `ggplot(...)`.
        initLayer2D = function(formula, ...) {
            covariates <- unlist(str_split(as.character(formula)[3], " \\+ "))
            if (length(covariates) > 1) {
                stop("Provided multiple covariates to 2D plot.")
            }
            private$p_covariates <- covariates
            private$p_formula <- formula
            private$p_layers <- append(
                private$p_layers, list(initial = "twodim")
            )
            private$p_plot <- ggplot(
                self$data_table, aes(.data[[private$p_covariates]], y)) +
                theme_bw() +
                labs(x = expression(x[1]))
            return(invisible(self))
        },
        
        #' @description Initialize three-dimensional plot.
        #' @param formula (`formula()`) Formula to plot.
        #' @param ... Further arguments passed to `plot_ly(...)`.
        initLayer3D = function(formula, ...) {
            covariates <- unlist(str_split(as.character(formula)[3], " \\+ "))
            if (length(covariates) > 2) {
                stop("Provided more than 2 covariates to 3D plot.")
            }
            private$p_covariates <- covariates
            private$p_formula <- formula
            private$p_layers <- append(
                private$p_layers, list(initial = "threedim")
            )
            private$p_plot <- plotly_empty(
                self$data_table, x = ~x_1, y = ~x_2, z = ~y, ...
            )
        },
        
        #' @description Add data points to two-dimensional plot.
        #' @param id (`character(1)`) ID to reference layer.
        #' @param shape (`character(1)`) Shape of points.
        #' @param ... Further arguments passed to `geom_point(...)` or 
        #' `plot_ly(...)`.
        addScatter = function(
            id = "scatter", shape = "cross", col = "black", ...
        ) {
            private$p_layers <- append(private$p_layers, list(scatter = id))
            if (private$p_layers$initial == "twodim") {
                private$p_plot <- private$p_plot +
                    geom_point(shape = shape, col = col, ...)
            }
            else {
                private$p_plot <- private$p_plot %>%
                    add_markers(
                        marker = list(
                            symbol = shape, color = col, showscale = FALSE, ...
                        )
                    )
            }
            return(invisible(self))
        },
        
        #' @description Add regression line to two-dimensional plot.
        #' @param id (`character(1)`) ID to reference layer.
        #' @param coefficients (`numeric()`) Regression coefficients.
        #' @param col (`character(1)`) Line color.
        #' @param ... Further arguments passed to `geom_abline(...)` or 
        #' `add_trace(...)`.
        addPredictionHyperplane = function(
            id, coefficients, col = "blue", ...
        ) {
            private$p_layers <- append(private$p_layers, list(id))
            this_color <- list(col)
            names(this_color) <- id
            private$p_colors <- append(private$p_colors, this_color)
            private$p_coefficients <- append(
                private$p_coefficients, list(id = coefficients)
            )
            
            if (private$p_layers$initial == "twodim") {
                private$p_plot <- private$p_plot +
                    geom_abline(
                        data.frame(
                            theta_0 = coefficients[1],
                            theta_1 = coefficients[2],
                            color = id
                        ),
                        mapping = aes(
                            intercept = theta_0, slope = theta_1, col = color
                        ),
                        ...
                    )
            }
            else {
                axis_x1 <- seq(
                    min(self$data_table[[private$p_covariates[[1]]]]),
                    max(self$data_table[[private$p_covariates[[1]]]]),
                    by = 0.05
                )
                axis_x2 <- seq(
                    min(self$data_table[[private$p_covariates[[2]]]]),
                    max(self$data_table[[private$p_covariates[[2]]]]),
                    by = 0.05
                )
                lm_surface <- expand.grid(
                    x_0 = 1, x_1 = axis_x1, x_2 = axis_x2, KEEP.OUT.ATTRS = F
                )
                lm_surface$y <- as.matrix(lm_surface) %*% coefficients
                lm_surface <- acast(lm_surface, x_2 ~ x_1, value.var = "y")
                private$p_plot <- private$p_plot %>%
                    add_trace(
                        name = id,
                        z = lm_surface,
                        x = axis_x1,
                        y = axis_x2,
                        type = "surface",
                        colorbar = list(
                            title = id, 
                            ticks = "", 
                            nticks = 1
                        ),
                        colorscale = list(c(0, 1), rep(col, 2)),
                        opacity = 0.7,
                        ...
                    )
            }
            return(invisible(self))
        },
        
        #' @description Add residuals to two-dimensional plot.
        #' @param y_hat (`numeric()`) Corresponding predictions.
        #' @param idx_residuals (`integer()`) Indices of points whose residuals
        #' to highlight in plot.
        #' @param col (`character(1)`) Line color.
        #' @param ... Further arguments passed to `geom_segment(...)`.
        addResiduals = function(
            y_hat,
            idx_residuals, 
            quadratic = FALSE, 
            col = "blue", 
            fill = "blue",
            alpha = 0.1, ...
        ) {
            if (private$p_layers$initial == "threedim") {
                stop("Only implemented for two-dimensional plots.")
            }
            plot_columns <- c(private$p_covariates, "y")
            # TODO unique not optimal here, might throw error if two obs are 
            # actually identical
            plot_data <- unique(self$data_table[, ..plot_columns])
            plot_data[, y_hat := y_hat]
            if (quadratic) {
                private$p_plot <- private$p_plot +
                    geom_rect(
                        plot_data[idx_residuals, ],
                        mapping = aes(
                            xmin = .data[[private$p_covariates]], 
                            xmax = .data[[private$p_covariates]] + (y_hat - y), 
                            ymin = y, 
                            ymax = y_hat
                        ),
                        alpha = alpha,
                        col = col,
                        fill = fill,
                        ...
                    )
            }
            else {
                private$p_plot <- private$p_plot +
                    geom_segment(
                        plot_data[idx_residuals, ],
                        mapping = aes(
                            x = .data[[private$p_covariates]], 
                            xend = .data[[private$p_covariates]], 
                            y = y, 
                            yend = y_hat
                        ),
                        col = col,
                        ...
                    )
            }
            return(invisible(self))
        },
        
        #' @description Return the plot.
        #' @param legend_title (`character(1)`) Title of legend. If NULL, no
        #' legend will be used.
        plot = function(legend_title = NULL, x = 1, y = 1, z = 1) {
            if (private$p_layers$initial == "twodim") {
                p <- private$p_plot +
                    scale_color_manual(
                        legend_title, values = private$p_colors
                    )
                if (is.null(legend_title))  {
                    p <- p + theme(legend.position = "none")
                }
                p
            }
            # TODO implement legend for 3D plot
            else private$p_plot %>%
                layout(
                    scene = list(
                        xaxis = list(title = "x1"), 
                        yaxis = list(title = "x2"),
                        zaxis = list(title = "y"),
                        showlegend = FALSE,
                        camera = list(eye = list(x = x, y = y, z = z))
                    )
                )
        }
    ),
    private = list(
        #' @field p_formula (`formula()`) Formula to plot.
        p_formula = NULL,
        #' @field p_covariates (`character()`) Covariates to plot.
        p_covariates = NULL,
        #' @field p_coefficients (`list()`) Regression coefficients per layer.
        p_coefficients = list(),
        #' @field p_layers (`list()`) List of layer IDs.
        p_layers = list(),
        #' @field p_colors (`list()`) List of specified layer colors.
        p_colors = list(),
        #' @field p_plot (`ggplot(`) Plot.
        p_plot = NULL
    )
)

# LOSS PLOTTER CLASS -----------------------------------------------------------

#' RegressionPlotter class
#' Creates regression plots from univariate or bivariate data.
LossPlotter <- R6Class(
    "LossPlotter",
    public = list(
        #' @field data_table Data to plot.
        data_table = NULL,
        #' @description Creates a new instance of this class.
        #' @param residuals (`numeric()`) Residuals to plot on x-axis.
        initialize = function(residuals) {
            assert_numeric(residuals)
            self$data_table = data.table(x = residuals)
            return(invisible(self))
        },
        
        #' @description Initialize two-dimensional plot.
        #' @param residuals (`numeric()`) Residuals to plot on x-axis.
        #' @param ... Further arguments passed to `ggplot(...)`.
        initLayer = function() {
            private$p_layers <- append(
                private$p_layers, list(initial = "initial")
            )
            private$p_plot <- ggplot(
                self$data_table, aes(x)) +
                theme_bw() +
                labs(x = expression(y - f(x)), y = expression(L(f(x), y)))
            return(invisible(self))
        },
        
        #' @description Add loss function.
        #' @param id (`character(1)`) ID to reference layer.
        #' @param loss_fun (`function()`) Loss function to plot.
        #' @param col (`character(1)`) Line color.
        #' @param ... Further arguments passed to `stat_function(...)`.
        addLossCurve = function(id, loss_fun, col = "blue", ...) {
            private$p_layers <- append(private$p_layers, list(id))
            this_color <- list(col)
            names(this_color) <- id
            private$p_colors <- append(private$p_colors, this_color)
            self$data_table[[id]] <- loss_fun(self$data_table$x)
            private$p_plot <- private$p_plot +
                geom_function(
                    data.frame(x = self$data_table$x, color = id), 
                    mapping = aes(x = x, col = color), 
                    fun = loss_fun,
                    ...
                )
            return(invisible(self))

        },
        
        #' @description Highlight residuals in loss plot with vertical segments.
        #' @param loss_id (`character()`) ID of loss layer residuals
        #' @param idx_residuals (`integer()`) Indices of points whose residuals
        #' to highlight in plot.
        #' @param type (`character(1)`) Type of annotation.
        #' @param col (`character(1)`) Color.
        #' @param ... Further arguments passed to `geom_segment(...)`.
        addAnnotation = function(
            loss_fun, 
            residuals, 
            type = "segment", 
            col = "blue",
            nudge_x = 0.05 * diff(range(self$data_table$x)),
            hjust = 1,
            ...
        ) {
            supported_types <- c("segment", "point", "text")
            if (type == "segment") {
                private$p_plot <- private$p_plot +
                    geom_segment(
                        data.frame(x = residuals, y = loss_fun(residuals)),
                        mapping = aes(
                            x = x,
                            xend = x,
                            y = 0,
                            yend = y
                        ),
                        col = col,
                        ...
                    )
            }
            else if (type == "point") {
                private$p_plot <- private$p_plot +
                    geom_point(
                        data.frame(x = residuals, y = loss_fun(residuals)),
                        mapping = aes(x = x, y = y),
                        col = col,
                        ...
                    )
            }
            else if (type == "text") {
                private$p_plot <- private$p_plot +
                    geom_text(
                        data.frame(x = residuals, y = loss_fun(residuals)),
                        mapping = aes(
                            x = x, 
                            y = y,
                            label = sprintf("%.2f", y)
                        ),
                        col = col,
                        hjust = hjust,
                        nudge_x = nudge_x,
                        ...
                    )
            }
            else {
                stop(
                    sprintf(
                        "Supported types: %s", 
                        paste(supported_types, collapse = ", ")
                    )
                )
            }
            return(invisible(self))
        },

        #' @description Return the plot.
        #' @param legend_title (`character(1)`) Title of legend. If NULL, no
        #' legend will be used.
        plot = function(legend_title = NULL) {
            p <- private$p_plot +
                scale_color_manual(
                    legend_title, values = unlist(private$p_colors)
                )
            if (is.null(legend_title))  {
                p <- p + theme(legend.position = "none")
            }
            p
        }
    ),
    private = list(
        #' @field p_layers (`list()`) List of layer IDs.
        p_layers = list(),
        #' @field p_colors (`list()`) List of specified layer colors.
        p_colors = list(),
        #' @field p_plot (`ggplot(`) Plot.
        p_plot = NULL
    )
)
