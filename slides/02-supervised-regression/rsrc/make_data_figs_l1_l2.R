# PREREQ -----------------------------------------------------------------------

# Create global datasets used across chunks

library(data.table)
source("libfuns_lm.R")

# DATA -------------------------------------------------------------------------

n_points <- 50L
set.seed(123)
x_1 <- rnorm(n_points, mean = 1, sd = 1)
x_2 <- rnorm(n_points, mean = 1, sd = 1)
set.seed(456)
y_univ <- 1 + 0.5 * x_1 + rnorm(n_points, sd = 0.5)
y_biv <- 1 + 0.5 * x_1 + 0.5 * x_2 + rnorm(n_points, sd = 0.5)
dt_univ <- data.table(x_1, y = y_univ)
x_1_outlier <- sample(x_1, 10)
y_outlier <- 1 + 0.5 * x_1_outlier + rnorm(length(x_1_outlier), sd = 0.1)
dt_univ_outlier <- rbind(
    data.table(x_1 = x_1_outlier, y = y_outlier), list(-1, 5)
)
dt_biv <- data.table(x_1, x_2, y = y_biv)

# UNIVARIATE REGRESSION --------------------------------------------------------

computer_univ <- RegressionComputer$new(dt_univ)
computer_univ$computeRegression("l2_univ", y ~ x_1, loss = "quadratic")
computer_univ$computeRegression("l1_univ", y ~ x_1, loss = "absolute")
saveRDS(
    list(
        data = computer_univ$regression_data[[1]], 
        coeffs = computer_univ$coefficients[[1]]
    ),
    "lm_univariate_quadratic.Rds"
)
saveRDS(
    list(
        data = computer_univ$regression_data[[2]], 
        coeffs = computer_univ$coefficients[[2]]
    ),
    "lm_univariate_absolute.Rds"
)

# UNIVARIATE REGRESSION WITH OUTLIER -------------------------------------------

n_obs <- nrow(dt_univ_outlier)
invisible(
    lapply(
        c(n_obs, n_obs - 1),
        function(i) {
            computer <- RegressionComputer$new(dt_univ_outlier[1:i])
            computer$computeRegression("l2_univ", y ~ x_1, loss = "quadratic")
            computer$computeRegression("l1_univ", y ~ x_1, loss = "absolute")
            saveRDS(
                list(
                    data = computer$regression_data[[1]], 
                    coeffs = computer$coefficients[[1]]
                ),
                sprintf("lm_univariate_quadratic_outlier_%i.Rds", i)
            )
            saveRDS(
                list(
                    data = computer$regression_data[[2]], 
                    coeffs = computer$coefficients[[2]]
                ),
                sprintf("lm_univariate_absolute_outlier_%i.Rds", i)
            )
        }
    )
)

# UNIVARIATE REGRESSION --------------------------------------------------------

computer_biv <- RegressionComputer$new(dt_biv)
computer_biv$computeRegression("l2_biv", y ~ x_1 + x_2, loss = "quadratic")
saveRDS(
    list(
        data = computer_biv$regression_data[[1]], 
        coeffs = computer_biv$coefficients[[1]]
    ),
    "lm_bivariate_quadratic.Rds"
)
