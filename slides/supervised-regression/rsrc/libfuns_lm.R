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

# BASE LM CLASS ----------------------------------------------------------------

#' BaseLMPlotter class
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
        #' @description Plots univariate regression.
        #' @param idx_residuals (`integer()`) Optional indices for which to plot
        #' residuals.
        #' @param coefficients (`numeric(2)`) Optional vector of LM
        #' coefficients.
        #' @param point_color (`character(1)`) Color of scatter points.
        #' @param point_size (`numeric(1)`) Size of scatter points.
        #' @param point_size (`character(1)`) Shape of scatter points.
        #' @param line_color (`character(1)`) Color of line.
        #' @param line_size (`numeric(1)`) Size of line.
        #' @param line_linetype (`character(1)`) Line type of line.
        #' @param residuals_color (`character(1)`) Color of residuals.
        #' @param residuals_alpha (`numeric(1)`) Opacity of residuals.
        plot_lm = function(
            idx_residuals = NULL,
            coefficients = NULL,
            point_color = "black",
            point_size = 1,
            point_shape = "circle",
            line_color = "blue",
            line_size = 1,
            line_linetype = "solid",
            residuals_color = "blue",
            residuals_alpha = 0.1
        ) {
            if (!is.null(idx_residuals)) {
                assertNumeric(idx_residuals, max.len = nrow(self$data_table))
            }
            if (is.null(coefficients)) coefficients <- coef(self$model)
            else assertNumeric(coefficients, len = 2L)
            if (length(self$covariates == 1L)) {
                private$plot_lm_univariate(
                    covariates = self$covariates,
                    idx_residuals = idx_residuals,
                    coefficients,
                    point_color,
                    point_size,
                    point_shape,
                    line_color,
                    line_size,
                    line_linetype,
                    residuals_color,
                    residuals_alpha
                )
            }
            else if (length(covariates == 2L)) {
                private$plot_lm_bivariate()
            }
            else stop("Can only plot univariate or bivariate regression")
        }
    ),
    private = list(
        plot_lm_univariate = function(
            covariates,
            idx_residuals,
            coefficients,
            point_color,
            point_size,
            point_shape,
            line_color,
            line_size,
            line_linetype,
            residuals_color,
            residuals_alpha
        ) {
            p <- ggplot(self$data_table, aes(.data[[covariates]], y)) +
                theme_bw() +
                labs(x = expression(x[1])) +
                geom_point(
                    col = point_color, shape = point_shape, size = point_size
                ) +
                geom_abline(
                    intercept = coefficients[1], 
                    slope = coefficients[2], 
                    col = line_color,
                    linetype = line_linetype,
                    linewidth = line_size,
                )
            if (length(idx_residuals > 0)) {
                if (self$loss == "quadratic") {
                    p <- p +
                        geom_rect(
                            self$data_table[idx_residuals, ],
                            mapping = aes(
                                xmin = .data[[covariates]], 
                                xmax = .data[[covariates]] + (y_hat - y), 
                                ymin = y, 
                                ymax = y_hat
                            ),
                            alpha = 0.1,
                            col = residuals_color,
                            fill = residuals_color,
                        )
                }
                else {
                    p <- p +
                        geom_segment(
                            self$data_table[idx_residuals, ],
                            mapping = aes(
                                x = .data[[covariates]], 
                                xend = .data[[covariates]], 
                                y = y, 
                                yend = y_hat
                            ),
                            col = residuals_color,
                        )
                }
            }
            p
        },
        plot_lm_bivariate = function(...) {
            # TODO create
            return NULL
        }
    )
)

# x_1 <- rnorm(10)
# y <- 1 + x_1 + rnorm(10)
# 
# plotter <- LMPlotter$new(x_1 = x_1, y = y)
# plotter$compute_regression(formula = y ~ x_1, loss = "absolute")
# plotter$plot_lm(idx_residuals = c(1, 3, 8, 10)) +
#     ylim(c(0, 10))