# PREREQ -----------------------------------------------------------------------

library(gridExtra)
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
dt_biv <- data.table(x_1, x_2, y = y_biv)

computer <- RegressionComputer$new(dt_univ)
computer$computeRegression("l2_univ", y ~ x_1, loss = "quadratic")

# BASIC UNIVARIATE PLOT --------------------------------------------------------

plot_univariate <- RegressionPlotter$new(
    do.call(rbind, computer$regression_data)
)
plot_univariate$initLayer2D(y ~ x_1)
plot_univariate$addScatter()
plot_univariate$addPredictionHyperplane(
    "l2", computer$coefficients[[1]], col = "blue"
)
ggsave(
    "../figure/reg_lm_plot.pdf", 
    plot_univariate$plot(), 
    width = 2.5, 
    height = 2
)

# UNIVARIATE PLOT WITH INTERPRETATION ------------------------------------------

theta_0 <- computer$coefficients[["l2_univ"]][1]
theta_1 <- computer$coefficients[["l2_univ"]][2]
my_lm <- function(x, coefs = c(theta_0, theta_1)) coefs[0] + coefs[1] * x
summary(lm(y ~ x_1, dt_univ)) # save screenshot to figure_man

plot_interpreted <- RegressionPlotter$new(
    do.call(rbind, computer$regression_data)
)
plot_interpreted$initLayer2D(y ~ x_1)
plot_interpreted$addScatter(alpha = 0.4, col = "darkgray")
plot_interpreted$addPredictionHyperplane(
    "l2", computer$coefficients[[1]], col = "black"
)
plot_interpreted <- plot_interpreted$plot() +
    geom_vline(xintercept = 0, color = "darkgray", linetype = "dotted") +
    geom_segment(
        mapping = aes(x = 0, y = 0, xend = 0, yend = theta_0),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(x = 2, y = my_lm(1), xend = 2, yend = my_lm(2)),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(x = 1, y = my_lm(1), xend = 2, yend = my_lm(1))
    ) +
    geom_text(
        mapping = aes(x = 0.2, y = theta_1, label = "{theta[0]}"),
        color = "blue",
        vjust = 1,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 2.2, y = my_lm(2), label = "{theta[1]}"),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(x = 1.5, y = my_lm(1), label = "1 unit"), 
        vjust = 1,
    )
ggsave(
    "../figure/reg_lm_plot_interpreted.pdf", 
    plot_interpreted, 
    width = 2.5, 
    height = 2
)

# UNIVARIATE PLOT WITH QUADRATIC RESIDUAL --------------------------------------

idx_highlight <- 33
plot_residual <- plot_univariate$clone()
plot_residual$addResiduals(
    plot_data[id == "l2_univ", y_hat], 
    idx_highlight, 
    quadratic = TRUE
)
plot_residual <- plot_residual$plot() +
    geom_point(
        dt_univ[idx_highlight, ], 
        mapping = aes(x_1, y), 
        col = "blue", 
        size = 2,
        shape = "cross"
    )
ggsave("../figure/reg_lm_sse.pdf", plot_residual, width = 3, height = 2.6)

# LOSS PLOT --------------------------------------------------------------------

idx_highlight <- c(19, 49)
residuals_highlight <- computer$regression_data[[1]]$residual[idx_highlight]
loss_fun <- function(x) x**2

plot_residual_2 <- plot_univariate$clone()
plot_residual_2$addResiduals(
    plot_data[id == "l2_univ", y_hat], idx_highlight, quadratic = TRUE
)
plot_loss <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l2", loss_fun, col = "black")
plot_loss$addAnnotation(loss_fun, residuals_highlight, linetype = 2)
plot_loss$addAnnotation(loss_fun, residuals_highlight, type = "point")
plot_loss$addAnnotation(
    loss_fun, residuals_highlight, type = "text", nudge_x = 0.6
)
ggsave(
    "../figure/l2.pdf", 
    grid.arrange(plot_residual_2$plot(), plot_loss$plot(), ncol = 2), 
    width = 6, 
    height = 2.4
)

# BIVARIATE PLOT ---------------------------------------------------------------

computer_biv <- RegressionComputer$new(dt_biv)
computer_biv$computeRegression("l2_biv", y ~ x_1 + x_2, loss = "quadratic")
plotter_3d <- RegressionPlotter$new(
    do.call(rbind, computer_biv$regression_data)
)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "black")
plotter_3d$addPredictionHyperplane("l2", computer_biv$coefficients[["l2_biv"]])
plotter_3d$plot()
