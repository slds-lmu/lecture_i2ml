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

plot_data <- do.call(rbind, computer$regression_data)
plotter_2d <- RegressionPlotter$new(plot_data)
plotter_2d$initLayer2D(y ~ x_1)
plotter_2d$addScatter(alpha = 0.4)
plotter_2d$addPredictionHyperplane(
    "l2", computer$coefficients[[1]], col = "blue"
)

plot_univariate <- plotter_2d$plot()
ggsave(
    "../figure/reg_lm_plot.pdf", 
    plot_univariate, 
    width = 2.5, 
    height = 2
)

# UNIVARIATE PLOT WITH INTERPRETATION ------------------------------------------

theta_0 <- computer$coefficients[["l2_univ"]][1]
theta_1 <- computer$coefficients[["l2_univ"]][2]
summary(lm(y ~ x_1, dt_univ)) # save screenshot to figure_man

plot_univariate_interpreted <- plot_univariate +
    geom_vline(xintercept = 0, color = "darkgray", linetype = "dotted") +
    geom_segment(
        mapping = aes(x = 0, y = 0, xend = 0, yend = theta_0),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(
            x = 2, 
            y = theta_0 + theta_1 * 1, 
            xend = 2, 
            yend = theta_0 + theta_1 * 2
        ),
        color = "blue"
    ) +
    geom_segment(
        mapping = aes(
            x = 1, 
            y = theta_0 + theta_1 * 1, 
            xend = 2, 
            yend = theta_0 + theta_1 * 1
        ),
    ) +
    geom_text(
        mapping = aes(x = 0.2, y = theta_1, label = "{theta[0]}"),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(
            x = 2.2, y = theta_0 + theta_1 * 2, label = "{theta[1]}"
        ),
        color = "blue",
        vjust = 2,
        parse = TRUE
    ) +
    geom_text(
        mapping = aes(
            x = 1.5, y = theta_0 + theta_1 * 1, label = "1 unit"
        ), 
        vjust = 2,
    )
ggsave(
    "../figure/reg_lm_plot_interpreted.pdf", 
    plot_univariate_interpreted, 
    width = 2.5, 
    height = 2
)

# UNIVARIATE PLOT WITH QUADRATIC RESIDUAL --------------------------------------

idx_highlight <- 33
plotter_2d$addResiduals(
    plot_data[id == "l2_univ", y_hat], 
    idx_highlight, 
    quadratic = TRUE, 
    col = "blue"
)
plot_univariate_res <- plotter_2d$plot() +
    geom_hline(yintercept = mean(dt_univ$y)) +
    geom_point(
        dt_univ[idx_highlight, ], mapping = aes(x_1, y), col = "red", size = 2
    )+
    geom_text(
        mapping = aes(x = -1, y = mean(y) + 0.5, label = "{bar(y)}"),
        vjust = 1,
        parse = TRUE
    )
ggsave("../figure/reg_lm_sse.pdf", plot_univariate_res, width = 3, height = 2.6)

# LOSS PLOT --------------------------------------------------------------------

idx_highlight <- c(1, 45)
plotter_2d <- RegressionPlotter$new(plot_data)
plotter_2d$initLayer2D(y ~ x_1)
plotter_2d$addScatter(alpha = 0.4)
plotter_2d$addPredictionHyperplane(
    "l2", computer$coefficients[[1]], col = "blue"
)
plotter_2d$addResiduals(
    plot_data[id == "l2_univ", y_hat], 
    idx_highlight, 
    quadratic = TRUE, 
    col = "blue"
)
p_1 <- plotter_2d$plot()

residuals_highlight <- computer$regression_data[[1]]$residual[idx_highlight]
plotter_loss <- LossPlotter$new(seq(-3, 3, by = 1))
plotter_loss$initLayer()
plotter_loss$addLossCurve("l2", function(x) x**2, col = "blue")
plotter_loss$addAnnotation(function(x) x**2, residuals_highlight, linetype = 2)
plotter_loss$addAnnotation(function(x) x**2, residuals_highlight, type = "point")
plotter_loss$addAnnotation(function(x) x**2, residuals_highlight, type = "text")
p_2 <- plotter_loss$plot()
p <- grid.arrange(p_1, p_2, ncol = 2)

ggsave("../figure/l2.pdf", p, width = 6, height = 2.5)

# BIVARIATE PLOT ---------------------------------------------------------------

computer_biv <- RegressionComputer$new(dt_biv)
computer_biv$computeRegression("l2_biv", y ~ x_1 + x_2, loss = "quadratic")
plotter_3d <- RegressionPlotter$new(
    do.call(rbind, computer_biv$regression_data)
)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "black")
plotter_3d$addPredictionHyperplane("l2", computer$coefficients[["l2_biv"]])
plotter_3d$plot()
