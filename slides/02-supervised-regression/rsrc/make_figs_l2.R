# PREREQ -----------------------------------------------------------------------

library(gridExtra)

# To save plotly-based figures to static images, plotly uses the kaleido python
# library, which is accessed via reticulate. You might need to run:
if (FALSE) {
    install.packages("reticulate")
    reticulate::install_miniconda()
    reticulate::conda_install("r-reticulate", "python-kaleido")
    reticulate::conda_install("r-reticulate", "plotly", channel = "plotly")
    reticulate::use_miniconda("r-reticulate")
}
# R might throw an error about not finding the `sys` library -- circumvent with
if (FALSE) reticulate::py_run_string("import sys")

source("libfuns_lm.R")

# BASIC UNIVARIATE PLOT --------------------------------------------------------

lm_univ_quad <- readRDS("lm_univariate_quadratic.Rds")
plot_univariate <- RegressionPlotter$new(lm_univ_quad$data)
plot_univariate$initLayer2D(y ~ x_1)
plot_univariate$addScatter()
plot_univariate$addPredictionHyperplane("l2", lm_univ_quad$coeffs, col = "blue")
ggsave(
    "../figure/reg_l2_basic_lm.pdf", 
    plot_univariate$plot(), 
    width = 2.5, 
    height = 2
)

# BIVARIATE PLOT ---------------------------------------------------------------

lm_biv_quad <- readRDS("lm_bivariate_quadratic.Rds")
plotter_3d <- RegressionPlotter$new(lm_biv_quad$data)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "black")
plotter_3d$addPredictionHyperplane("l2", lm_biv_quad$coeffs)
p <- plotter_3d$plot(x = -1.9, y = 0, z = 0) %>% 
    hide_colorbar() %>% 
    hide_legend()
save_image(p, "../figure/reg_l2_basic_lm_biv.pdf")

# UNIVARIATE PLOT WITH INTERPRETATION ------------------------------------------

my_lm <- function(x) lm_univ_quad$coeffs[1] + lm_univ_quad$coeffs[2] * x
summary(lm(y ~ x_1, lm_univ_quad$data)) # save screenshot to figure_man

plot_interpreted <- RegressionPlotter$new(lm_univ_quad$data)
plot_interpreted$initLayer2D(y ~ x_1)
plot_interpreted$addScatter(alpha = 0.4, col = "darkgray")
plot_interpreted$addPredictionHyperplane(
    "l2", lm_univ_quad$coeffs, col = "black"
)
plot_interpreted <- plot_interpreted$plot() +
    geom_segment(
        data.table(
            x = c(0, 2, 1),
            y = c(0, my_lm(1), my_lm(1)),
            xend = c(0, 2, 2),
            yend = c(lm_univ_quad$coeffs[1], my_lm(2), my_lm(1))
        ), 
        mapping = aes(x = x, y = y, xend = xend, yend = yend),
        col = c("blue", "blue", "black")
    ) +
    geom_vline(xintercept = 0, color = "darkgray", linetype = "dotted") +
    geom_text(
        data.table(
            x = c(0.2, 2.2, 1.5),
            y = c(lm_univ_quad$coeffs[2], my_lm(2), my_lm(1)),
            label = c("{theta[0]}", "{theta[1]}", "1")
        ), 
        mapping = aes(x = x, y = y, label = label),
        col = c("blue", "blue", "black"),
        vjust = c(1, 2, 1),
        parse = TRUE
    )
ggsave(
    "../figure/reg_l2_basic_lm_interpreted.pdf", 
    plot_interpreted, 
    width = 2.5, 
    height = 2
)

# UNIVARIATE PLOT WITH QUADRATIC RESIDUAL --------------------------------------

idx_highlight <- 33
plot_residual <- plot_univariate$clone()
plot_residual$addResiduals(
    lm_univ_quad$data$y_hat, 
    idx_highlight, 
    quadratic = TRUE
)
plot_residual <- plot_residual$plot() +
    geom_point(
        lm_univ_quad$data[idx_highlight, ], 
        mapping = aes(x_1, y), 
        col = "blue", 
        size = 2,
        shape = "cross"
    )
ggsave("../figure/reg_l2_residual.pdf", plot_residual, width = 3, height = 2.6)

# LOSS PLOT --------------------------------------------------------------------

idx_highlight <- c(19, 49)
residuals_highlight <- lm_univ_quad$data$residual[idx_highlight]
loss_fun <- function(x) x**2

plot_residual_quad <- RegressionPlotter$new(lm_univ_quad$data)
plot_residual_quad$initLayer2D(y ~ x_1)
plot_residual_quad$addScatter()
plot_residual_quad$addPredictionHyperplane(
    "l2", lm_univ_quad$coeffs, col = "black"
)
plot_residual_quad$addResiduals(
    lm_univ_quad$data$y_hat, 
    idx_highlight, 
    quadratic = TRUE,
    col = "grey",
    fill = "grey"
)
plot_residual_quad$addResiduals(
    lm_univ_quad$data$y_hat, idx_highlight, col = "blue"
)
plot_residual_quad$plot()
plot_loss <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l2", loss_fun, col = "black")
plot_loss$addAnnotation(loss_fun, residuals_highlight, linetype = 2)
plot_loss$addAnnotation(loss_fun, residuals_highlight, type = "point")
plot_loss$addAnnotation(
    loss_fun, residuals_highlight, type = "text", nudge_x = 0.6
)

ggsave(
    "../figure/reg_l2_lossplot_quad.pdf", 
    grid.arrange(plot_residual_quad$plot(), plot_loss$plot(), ncol = 2), 
    width = 6, 
    height = 2.4
)
