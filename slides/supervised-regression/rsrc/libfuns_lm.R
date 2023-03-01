#  -----------------------------------------------------------------------------
#  LIBRARY FUNCTIONS
#  -----------------------------------------------------------------------------

library(checkmate)
library(data.table)
library(ggplot2)
library(mlr3verse)
library(quantreg)
library(R6)
library(stringr)
if (FALSE) devtools::install_github("slds-lmu/vistool")

# BASE CLASS -------------------------------------------------------------------

#' BasePlotter class
#' Create plots from univariate or bivariate data.
BasePlotter <- R6Class(
    "BasePlotter",
    public = list(
        #' @field data_table Data (two covariates, single target) to plot.
        data_table = NULL,
        #' @description Creates a new instance of this class.
        #' @param x_1 (`numeric()`) Data vector in first dimension.
        #' @param x_2 (`numeric()`) Data vector in second dimension.
        #' @param y (`numeric()`) Data target.
        initialize = function(x_1 = NA, x_2 = NA, y = NA) {
            assertNumeric(x_1)
            assertNumeric(x_2)
            assertNumeric(y)
            assertTRUE(length(x_1) == length(y))
            if (!all(is.na(x_2))) assertTRUE(length(x_2) == length(y))
            self$data_table <- data.table(x_1, x_2, y)
            return(invisible(self))
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
