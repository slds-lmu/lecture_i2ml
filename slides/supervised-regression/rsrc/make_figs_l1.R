# PREREQ -----------------------------------------------------------------------

library(gridExtra)
source("libfuns_lm.R")

# RESIDUAL PLOTS ---------------------------------------------------------------

lm_univ <- list(
    readRDS("lm_univariate_quadratic.Rds"), 
    readRDS("lm_univariate_absolute.Rds")
)
quadratic_residuals <- c(FALSE, TRUE)

plots_residual <- lapply(
    seq_along(lm_univ),
    function(i) {
        plot_residual <- RegressionPlotter$new(lm_univ[[i]]$data)
        plot_residual$initLayer2D(y ~ x_1)
        plot_residual$addScatter()
        plot_residual$addPredictionHyperplane("l", lm_univ[[i]]$coeffs)
        plot_residual$addResiduals(
            lm_univ[[i]]$data$y_hat, 
            idx_highlight, 
            quadratic = quadratic_residuals[i]
        )
    }
)
ggsave(
    "../figure/reg_lm_residual_l2_l1.pdf", 
    grid.arrange(
        plots_residual[[1]]$plot(), plots_residual[[2]]$plot(), ncol = 2
    ), 
    width = 6, 
    height = 2.4
)

# LOSS PLOTS -------------------------------------------------------------------

loss_funs <- list(function(x) abs(x), function(x) x**2)
loss_cols <- c("blue", "darkorange")

plot_loss <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss$initLayer()
plot_loss$addLossCurve("l1", loss_funs[[1]], col = "black")
plot_loss$addAnnotation(loss_funs[[1]], residuals_highlight, linetype = 2)
plot_loss$addAnnotation(loss_funs[[1]], residuals_highlight, type = "point")
plot_loss$addAnnotation(
    loss_funs[[1]], residuals_highlight, type = "text", nudge_x = 0.6
)

plot_loss_both <- LossPlotter$new(seq(-1.5, 1.5, by = 1))
plot_loss_both$initLayer()
invisible(
    lapply(
        seq_along(loss_funs),
        function(i) {
            plot_loss_both$addLossCurve("l", loss_funs[[i]], col = "black")
            plot_loss_both$addAnnotation(
                loss_funs[[i]], 
                residuals_highlight, 
                linetype = 2, 
                col = loss_cols[i]
            )
            plot_loss_both$addAnnotation(
                loss_funs[[i]], 
                residuals_highlight, 
                type = "point",
                col = loss_cols[i]
            )
        }
    )
)

ggsave(
    "../figure/l1.pdf", 
    grid.arrange(plots_residual[[1]]$plot(), plot_loss$plot(), ncol = 2), 
    width = 6, 
    height = 2.4
)
ggsave(
    "../figure/reg_lm_l1_l2.pdf", 
    plot_loss_both$plot(), 
    width = 3, 
    height = 2.6
)

# LOSS SURFACE PLOTS -----------------------------------------------------------

# OUTLIER PLOTS ----------------------------------------------------------------

plots_outlier <- lapply(
    c(10, 11),
    function(i) {
        dt_q <- readRDS(sprintf("lm_univariate_quadratic_outlier_%i.Rds", i))
        dt_a <- readRDS(sprintf("lm_univariate_absolute_outlier_%i.Rds", i))
        plot_outlier <- RegressionPlotter$new(dt_q$data[1:i])
        plot_outlier$initLayer2D(y ~ x_1)
        plot_outlier$addScatter()
        plot_outlier$addPredictionHyperplane(
            "L2", dt_q$coeffs, col = "darkorange"
        )
        plot_outlier$addPredictionHyperplane("L1", dt_a$coeffs, col = "blue")
        if (i == 11) {
            p <- plot_outlier$plot() + 
                geom_point(
                    dt_q$data[i], 
                    mapping = aes(x_1, y), 
                    col = "red",
                    shape = "circle",
                    size = 3
                )
        }
        else p <- plot_outlier$plot()
        p + theme(legend.position = "bottom")
    }
)
ggsave(
    "../figure/reg_lm_l1_l2_outlier.pdf", 
    grid.arrange(plots_outlier[[1]], plots_outlier[[2]], ncol = 2), 
    width = 6, 
    height = 2.4
)
