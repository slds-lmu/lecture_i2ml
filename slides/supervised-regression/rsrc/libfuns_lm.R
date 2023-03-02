#  -----------------------------------------------------------------------------
#  LIBRARY FUNCTIONS
#  -----------------------------------------------------------------------------

library(checkmate)
library(data.table)
library(ggplot2)
library(MASS)
library(mlr3verse)
library(quantreg)
library(R6)
library(stringr)

# BASE REGRESSION CLASS --------------------------------------------------------

#' RegressionComputer class
#' Computes regression for tabular data.
RegressionComputer <- R6Class(
    "RegressionComputer",
    public = list(
        #' @field data_table Data to predict on.
        data_table = NULL,
        #' @field formula Regression formula.
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
        #' @param formula (`character(1)`) LM formula to use.
        #' @param loss (`character(1)`) Loss function to use.
        #' @param custom_loss (`function()`) Custom loss acting on residuals.
        computeRegression = function(
            formula = y ~ ., 
            loss = "quadratic", 
            loss_params = NULL, 
            custom_loss = NULL, 
            ...
        ) {
            args = list(...)
            self$formula <- append(self$formula, list(formula))
            self$loss_names <- append(self$loss_names, list(loss))
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
                private$add_regression_data(formula, loss, loss_fun, model)
            }
            else if (loss == "absolute") {
                model <- quantreg::rq(
                    as.formula(formula), data = self$data_table
                )
                loss_fun <- function(x) abs(x) 
                private$add_regression_data(formula, loss, loss_fun, model)
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
                private$add_regression_data(formula, loss, loss_fun, model)
            }
            else if (loss == "logcosh") {
                loss_fun <- function(x) log(cosh(abs(x)))
                private$add_regression_data(formula, loss, loss_fun)
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
                private$add_regression_data(formula, loss, loss_fun)
            }
            else if (loss == "epsiloninsensitive") {
                epsilon <- private$set_loss_param("epsilon", 1L)
                loss_fun <- function(x) {
                    ifelse(abs(x) > epsilon, abs(x) - epsilon, 0L)
                }
                private$add_regression_data(formula, loss, loss_fun)
            }
            else if (loss == "pinball") {
                quantile <- private$set_loss_param("quantile", 1L)
                print(quantile)
                loss_fun <- function(x) {
                    ifelse(x < 0, ((1 - quantile) * (-x)), quantile * x)
                }
                private$add_regression_data(formula, loss, loss_fun)
            }
            else if (loss == "cauchy") {
                epsilon <- private$set_loss_param("epsilon", 1L)
                loss_fun <- function(x) {
                    0.5 * epsilon**2 * log(1 + (x / epsilon)**2)
                }
                private$add_regression_data(formula, loss, loss_fun)
            }
            else if (loss == "custom") {
                if (is.null(custom_loss)) stop("Please provide loss function.")
                else loss_fun <- custom_loss
                private$add_regression_data(formula, loss, loss_fun)
            }
        }
    ),
    private = list(
        #' @description Compute regression and store results.
        #' @param formula (`character(1)`) LM formula to use.
        #' @param loss (`character(1)`) LM formula to use.
        #' @param loss_fun (`function()`) List of loss functions to use.
        #' @param model (`lm()`) Optional model object.
        add_regression_data = function(
            formula, loss, loss_fun, model = NULL
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
            self$coefficients <- append(self$coefficients, list(coefficients))
            dt <- copy(self$data_table)[
                , loss := loss
                ][, y_hat := x_mat %*% coefficients
                  ][, residual := y - y_hat]
            self$regression_data <- append(
                self$regression_data, 
                list(dt)
            )
            self$loss_functions <- append(self$loss_functions, list(loss_fun))
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
            covariate <- unlist(str_split(as.character(formula)[3], " \\+ "))
            if (length(covariate) > 1) {
                stop("Provided multiple covariates to 2D plot.")
            }
            private$p_covariates <- covariate
            private$p_formula <- formula
            private$p_layer_primary <- "twodim"
            private$p_plot <- ggplot(
                self$data_table, aes(.data[[private$p_covariates]], y)) +
                theme_bw() +
                labs(x = expression(x[1]))
            return(invisible(self))
        },
        #' @description Add data points to two-dimensional plot.
        #' @param shape (`character(1)`) Shape of points.
        #' @param ... Further arguments passed to `geom_point(...)`.
        addScatter2D = function(shape = "cross", ...) {
            private$p_plot <- private$p_plot +
                geom_point(shape = shape, ...)
            return(invisible(self))
        },
        #' @description Add regression line to two-dimensional plot.
        #' @param coefficients (`numeric(2)`) Regression coefficients.
        #' @param col (`character(1)`) Line color.
        #' @param ... Further arguments passed to `geom_abline(...)`.
        addPredictionHyperplane2D = function(coefficients, col = "blue", ...) {
            private$p_coefficients <- append(
                private$p_coefficients, coefficients
            )
            private$p_plot <- private$p_plot +
                geom_abline(
                    intercept = coefficients[1], 
                    slope = coefficients[2], 
                    col = col,
                    ...
                )
            return(invisible(self))
        },
        #' @description Add residuals to two-dimensional plot.
        #' @param idx_residuals (`integer()`) Indices of points whose residuals
        #' to highlight in plot.
        #' @param col (`character(1)`) Line color.
        #' @param ... Further arguments passed to `geom_segment(...)`.
        addResiduals2D = function(
            idx_residuals, 
            quadratic = FALSE, 
            col = "blue", 
            fill = "blue",
            alpha = 0.1, ...
        ) {
            if (quadratic) {
                private$p_plot <- private$p_plot +
                    geom_rect(
                        self$data_table[idx_residuals, ],
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
                        self$data_table[idx_residuals, ],
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
        
        initLayer3D = function() {},
        
        #' @description Return the plot.
        plot = function() private$p_plot
    ),
    private = list(
        #' @field p_formula (`formula()`) Formula to plot.
        p_formula = NULL,
        #' @field p_covariates (`character()`) Covariates to plot.
        p_covariates = NULL,
        #' @field p_coefficients (`list()`) Regression coefficients per layer.
        p_coefficients = list(),
        #' @field p_layer_primary (`character(1)`) Type of initial layer.
        p_layer_primary = NULL,
        #' @field p_plot (`ggplot(`) Plot.
        p_plot = NULL
    )
)

#' BaseRegressionPlotter class
#' Creates regression plots from univariate or bivariate data.
BaseRegressionPlotter <- R6Class(
    "BaseRegressionPlotter",
    inherit = BasePlotter,
    public = list(
        #' @field model Regression model.
        model = NULL,
        #' @field covariates (`character()`) Regression covariate names.
        covariates = NULL,
        #' @field loss (`character(1)`) Loss function.
        loss = NULL,
        #' @description Compute regression.
        #' @param loss (`character(1)`) Loss function to use.
        #' @param formula (`character(1)`) LM formula to use.
        compute_regression = function(loss = "quadratic", formula) {
            self$loss <- loss
            self$covariates <- unlist(
                str_split(as.character(formula)[3], " \\+ ")
            )
            if (self$loss == "quadratic") {
                self$model <- lm(as.formula(formula), self$data_table)
                self$data_table[, y_hat := predict(self$model)]
                self$data_table[, residuals := (y - y_hat)**2]
            }
            else if (self$loss == "absolute") {
                self$model <- quantreg::rq(
                    as.formula(formula), data = self$data_table
                )
                self$data_table[, y_hat := predict(self$model)]
                self$data_table[, residuals := abs(y - y_hat)]
            }
            else stop(sprintf("Unknown loss function `%s`", loss))
            return(invisible(self))
        },
        #' @description Set plot details..
        #' @param idx_residuals (`integer()`) Optional indices for which to plot
        #' residuals.
        #' @param coefficients (`numeric(2)`) Optional vector of LM
        #' coefficients.
        #' @param point_color (`character(1)`) Color of scatter points.
        #' @param point_size (`numeric(1)`) Size of scatter points.
        #' @param point_shape (`character(1)`) Shape of scatter points.
        #' @param hyperplane_color (`character(1)`) Color of hyperplane.
        #' @param hyperplane_size (`numeric(1)`) Size of hyperplane.
        #' @param hyperplane_linetype (`character(1)`) Line type of hyperplane.
        #' @param residuals_color (`character(1)`) Color of residuals.
        #' @param residuals_alpha (`numeric(1)`) Opacity of residuals.
        set_plot_parameters = function(
            idx_residuals = NULL,
            coefficients = NULL,
            point_color = "black",
            point_size = 1,
            point_shape = "circle",
            hyperplane_color = "blue",
            hyperplane_size = 1,
            hyperplane_linetype = "solid",
            residuals_color = "blue",
            residuals_alpha = 0.1
        ) {
            private$idx_residuals <- idx_residuals
            private$coefficients <- coefficients
            private$point_color <- point_color
            private$point_size <- point_size
            private$point_shape <- point_shape
            private$hyperplane_color <- hyperplane_color
            private$hyperplane_size <- hyperplane_size
            private$hyperplane_linetype <- hyperplane_linetype
            private$residuals_color <- residuals_color
            private$residuals_alpha <- residuals_alpha
        }
    ),
    private = list(
        idx_residuals = NULL,
        coefficients = NULL,
        point_color = NULL,
        point_size = NULL,
        point_shape = NULL,
        hyperplane_color = NULL,
        hyperplane_size = NULL,
        hyperplane_linetype = NULL,
        residuals_color = NULL,
        residuals_alpha = NULL,
    )
)

# BASE UNIVARIATE REGRESSION CLASS ---------------------------------------------

#' BaseUnivariateRegressionPlotter class
#' Creates regression plots from univariate data.
BaseUnivariateRegressionPlotter <- R6Class(
    "BaseUnivariateRegressionPlotter",
    inherit = BaseRegressionPlotter,
    public = list(
        plot_lm = function() private$plot_lm(),
        plot_lm_and_loss = function() {
            p_1 <- private$plot_lm()
            p_2 <- private$plot_loss()
        }
    ),
    private = list(
        plot_lm = function() {
            p <- ggplot(self$data_table, aes(.data[[self$covariates]], y)) +
                theme_bw() +
                labs(x = expression(x[1])) +
                geom_point(
                    col = private$point_color, 
                    shape = private$point_shape, 
                    size = private$point_size
                ) +
                geom_abline(
                    intercept = private$coefficients[1], 
                    slope = private$coefficients[2], 
                    col = private$hyperplane_color,
                    linetype = private$hyperplane_linetype,
                    linewidth = private$hyperplane_size,
                )
            if (length(private$idx_residuals > 0)) {
                if (self$loss == "quadratic") {
                    p <- p +
                        geom_rect(
                            self$data_table[private$idx_residuals, ],
                            mapping = aes(
                                xmin = .data[[self$covariates]], 
                                xmax = .data[[self$covariates]] + (y_hat - y), 
                                ymin = y, 
                                ymax = y_hat
                            ),
                            alpha = 0.1,
                            col = private$residuals_color,
                            fill = private$residuals_color,
                        )
                }
                else {
                    p <- p +
                        geom_segment(
                            self$data_table[private$idx_residuals, ],
                            mapping = aes(
                                x = .data[[self$covariates]], 
                                xend = .data[[self$covariates]], 
                                y = y, 
                                yend = y_hat
                            ),
                            col = private$residuals_color,
                        )
                }
            }
            p
        },
        plot_loss = function() {
            # TODO
        }
    )
)

# LM CLASS ---------------------------------------------------------------------

#' LMPlotter class
#' Create plots related to linear models from univariate or bivariate data.
LMPlotter <- R6Class(
    "LMPlotter",
    inherit = BasePlotter,
    public = list(
        #' @field model Regression model.
        model = NULL,
        #' @field covariates (`character()`) Regression covariate names.
        covariates = NULL,
        #' @field loss (`character(1)`) Loss function.
        loss = NULL,
        #' @description Compute regression.
        #' @param loss (`character(1)`) Loss function to use.
        #' @param formula (`character(1)`) LM formula to use.
        compute_regression = function(loss = "quadratic", formula) {
            self$loss <- loss
            self$covariates <- unlist(
                str_split(as.character(formula)[3], " \\+ ")
            )
            if (self$loss == "quadratic") {
                self$model <- lm(as.formula(formula), self$data_table)
                self$data_table[, y_hat := predict(self$model)]
                self$data_table[, residuals := (y - y_hat)**2]
            }
            else if (self$loss == "absolute") {
                self$model <- quantreg::rq(
                    as.formula(formula), data = self$data_table
                )
                self$data_table[, y_hat := predict(self$model)]
                self$data_table[, residuals := abs(y - y_hat)]
            }
            else stop(sprintf("Unknown loss function `%s`", loss))
        },
        idx_residuals = NULL,
        coefficients = NULL,
        point_color = NULL,
        point_size = NULL,
        point_shape = NULL,
        hyperplane_color = NULL,
        hyperplane_size = NULL,
        hyperplane_linetype = NULL,
        residuals_color = NULL,
        residuals_alpha = NULL,
        #' @description Plots univariate regression.
        #' @param idx_residuals (`integer()`) Optional indices for which to plot
        #' residuals.
        #' @param coefficients (`numeric(2)`) Optional vector of LM
        #' coefficients.
        #' @param point_color (`character(1)`) Color of scatter points.
        #' @param point_size (`numeric(1)`) Size of scatter points.
        #' @param point_size (`character(1)`) Shape of scatter points.
        #' @param hyperplane_color (`character(1)`) Color of hyperplane.
        #' @param hyperplane_size (`numeric(1)`) Size of hyperplane.
        #' @param hyperplane_linetype (`character(1)`) Line type of hyperplane.
        #' @param residuals_color (`character(1)`) Color of residuals.
        #' @param residuals_alpha (`numeric(1)`) Opacity of residuals.
        plot_lm = function(
            idx_residuals = NULL,
            coefficients = NULL,
            point_color = "black",
            point_size = 1,
            point_shape = "circle",
            hyperplane_color = "blue",
            hyperplane_size = 1,
            hyperplane_linetype = "solid",
            residuals_color = "blue",
            residuals_alpha = 0.1
        ) {
            if (!is.null(idx_residuals)) {
                assertNumeric(idx_residuals, max.len = nrow(self$data_table))
            }
            if (is.null(coefficients)) coefficients <- coef(self$model)
            else assertNumeric(coefficients, len = 2L)
            fun_args <- list(
                idx_residuals = idx_residuals,
                coefficients = coefficients,
                point_color = point_color,
                point_size = point_size,
                point_shape = point_shape,
                hyperplane_color = hyperplane_color,
                hyperplane_size = hyperplane_size,
                hyperplane_linetype = hyperplane_linetype,
                residuals_color = residuals_color,
                residuals_alpha = residuals_alpha
            )
            if (length(self$covariates) == 1L) {
                do.call(private$plot_lm_univariate, c(fun_args))
            }
            else if (length(self$covariates) == 2L) {
                do.call(private$plot_lm_bivariate, c(fun_args))
            }
            else stop("Can only plot univariate or bivariate regression")
        }
    ),
    private = list(
        plot_lm_univariate = function(...) {
            args <- list(...)
            p <- ggplot(self$data_table, aes(.data[[self$covariates]], y)) +
                theme_bw() +
                labs(x = expression(x[1])) +
                geom_point(
                    col = args$point_color, 
                    shape = args$point_shape, 
                    size = args$point_size
                ) +
                geom_abline(
                    intercept = args$coefficients[1], 
                    slope = args$coefficients[2], 
                    col = args$hyperplane_color,
                    linetype = args$hyperplane_linetype,
                    linewidth = args$hyperplane_size,
                )
            if (length(args$idx_residuals > 0)) {
                if (self$loss == "quadratic") {
                    p <- p +
                        geom_rect(
                            self$data_table[args$idx_residuals, ],
                            mapping = aes(
                                xmin = .data[[self$covariates]], 
                                xmax = .data[[self$covariates]] + (y_hat - y), 
                                ymin = y, 
                                ymax = y_hat
                            ),
                            alpha = 0.1,
                            col = args$residuals_color,
                            fill = args$residuals_color,
                        )
                }
                else {
                    p <- p +
                        geom_segment(
                            self$data_table[args$idx_residuals, ],
                            mapping = aes(
                                x = .data[[self$covariates]], 
                                xend = .data[[self$covariates]], 
                                y = y, 
                                yend = y_hat
                            ),
                            col = args$residuals_color,
                        )
                }
            }
            p
        },
        plot_lm_bivariate = function(...) {
            args <- list(...)
            axis_x <- seq(
                min(self$data_table$x_1), max(self$data_table$x_1), by = 0.05
            )
            axis_y <- seq(
                min(self$data_table$x_2), max(self$data_table$x_2), by = 0.05
            )
            lm_surface <- expand.grid(
                x_1 = axis_x, x_2 = axis_y, KEEP.OUT.ATTRS = F
            )
            
            lm_surface$y <- predict(self$model, newdata = lm_surface)
            lm_surface <- acast(
                lm_surface, x_2 ~ x_1, value.var = "y"
            )
            plot_ly(
                self$data_table,
                x = ~x_1, 
                y = ~x_2, 
                z = ~y
            ) %>%
                add_markers(
                    marker = list(
                        color = args$point_color, symbol = args$point_shape
                    )
                ) %>%
                add_trace(
                    z = lm_surface,
                    x = seq(
                        min(self$data_table$x_1),
                        max(self$data_table$x_1),
                        by = 0.05
                    ),
                    y = seq(
                        min(self$data_table$x_2),
                        max(self$data_table$x_2),
                        by = 0.05
                    ),
                    type = "surface",
                    colorscale = list(c(0, 1), rep(args$hyperplane_color, 2)), 
                    opacity = 0.7
                ) %>% 
                layout(showlegend = FALSE) %>% 
                hide_colorbar()
        }
    )
)

x_1 <- rnorm(10)
x_2 <- rnorm(10)
y <- 1 + x_1 + x_2 + rnorm(10)
plotter <- LMPlotter$new(x_1 = x_1, x_2 = x_2, y = y)
plotter$compute_regression(formula = y ~ x_1 + x_2, loss = "quadratic")
plotter$plot_lm()

# LOSS PLOT CLASS --------------------------------------------------------------

#' LossFunPlotter class
#' Create loss plots, optionally: with (univariate) data and residuals.
LossFunPlotter <- R6Class(
    "LossFunPlotter",
    inherit = BasePlotter,
    public = list(
        #' @field loss (`function`) Loss function.
        loss = NULL,
    )
)
