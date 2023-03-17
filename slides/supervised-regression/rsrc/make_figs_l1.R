# PREREQ -----------------------------------------------------------------------

library(gridExtra)
if (FALSE) devtools::install_github("slds-lmu/vistool")
library(vistool)

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

my_l2 <- function(x, Xmat, y) sum((Xmat %*% x - y)**2)
my_l1 <- function(x, Xmat, y) sum(abs(Xmat %*% x - y))
loss_cols <- c("blue", "darkorange")

# RESIDUAL PLOTS ---------------------------------------------------------------

lm_univ <- list(
    readRDS("lm_univariate_absolute.Rds"),
    readRDS("lm_univariate_quadratic.Rds")
)
quadratic_residuals <- c(FALSE, TRUE)
idx_highlight <- c(19, 49)

plots_residual <- lapply(
    seq_along(lm_univ),
    function(i) {
        plot_residual <- RegressionPlotter$new(lm_univ[[i]]$data)
        plot_residual$initLayer2D(y ~ x_1)
        plot_residual$addScatter()
        plot_residual$addPredictionHyperplane(
            "l", lm_univ[[i]]$coeffs, col = loss_cols[i]
        )
        plot_residual$addResiduals(
            lm_univ[[i]]$data$y_hat, 
            idx_highlight, 
            quadratic = quadratic_residuals[i],
            col = loss_cols[i],
            fill = loss_cols[i]
        )
    }
)
ggsave(
    "../figure/reg_l1_residual_abs_vs_quad.pdf", 
    grid.arrange(
        plots_residual[[1]]$plot(), plots_residual[[2]]$plot(), ncol = 2
    ), 
    width = 6, 
    height = 2.4
)

# LOSS PLOTS -------------------------------------------------------------------

loss_funs <- list(function(x) abs(x), function(x) x**2)
residuals_highlight <- lm_univ[[2]]$data$residual[idx_highlight]

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
    "../figure/reg_l1_lossplot_abs.pdf", 
    grid.arrange(plots_residual[[1]]$plot(), plot_loss$plot(), ncol = 2), 
    width = 6, 
    height = 2.4
)
ggsave(
    "../figure/reg_l1_lossplot_abs_vs_quad.pdf", 
    plot_loss_both$plot(), 
    width = 3, 
    height = 2.6
)

# LOSS SURFACE PLOTS -----------------------------------------------------------

set.seed(pi)
n_points <- 100
x_1 <- 1:n_points
y <- x_1 + rnorm(n_points, 0, 03)
dt <- data.table(x_1, y)
Xmat <- model.matrix(~ x_1, data = dt)

plots_surface <- list()
for (m in list(my_l2, my_l1)) {
    obj <- Objective$new(
        "l", fun = m, xdim = 2, Xmat = Xmat, y = y, minimize = TRUE
    )
    viz <- Visualizer$new(
        obj, x1limits = c(-500, 500), x2limits = c(-10, 10)
    )
    viz$initLayerSurface(colorscale = list(c(0, 1), c("darkgray", "white")))
    viz$setScene(1.5, -1.2, -0.3)
    viz$setLayout(
        scene = list(
            xaxis = list(title = "intercept"), 
            yaxis = list(title = "slope"),
            zaxis = list(title = "loss"),
            showlegend = FALSE
        )
    )
    plots_surface <- append(plots_surface, list(viz$plot()))
}
save_image(plots_surface[[1]], "../figure/reg_l1_surface_quad.pdf")
save_image(plots_surface[[2]], "../figure/reg_l1_surface_abs.pdf")

# L1 VS L2 PLOTS ---------------------------------------------------------------

n_obs <- stringr::str_extract_all(
    list.files(pattern = "lm_univariate_quadratic_outlier_(.)*.Rds"), "\\d+"
)
n_obs <- as.numeric(unlist(n_obs))
models <- list(my_l1, my_l2)
loss_names <- c("absolute", "quadratic")

plots_optim <- list()
plots_outlier <- list()

for (n in n_obs) {
    
    for (m in seq_along(models)) {
        dt <- readRDS(
            sprintf("lm_univariate_%s_outlier_%i.Rds", loss_names[m], n)
        )
        if (n == min(n_obs)) {
            Xmat <- model.matrix(~ x_1, dt$data)
            obj <- Objective$new(
                "l", 
                fun = models[[m]], 
                xdim = 2, 
                Xmat = Xmat, 
                y = dt$data$y, 
                minimize = TRUE
            )
            gd <- OptimizerGD$new(obj, x_start = c(5, 4), print_trace = FALSE)
            n_steps <- 5000
            set.seed(pi)
            gd$optimize(steps = n_steps)
            viz <- Visualizer$new(obj, x1limits = c(-5, 5), x2limits = c(-5, 5))
            viz$initLayerSurface(
                colorscale = list(c(0, 1), c("darkgray", "white"))
            )
            viz$addLayerOptimizationTrace(
                gd, line_color = loss_cols[m], add_marker_at = n_steps
            )
            viz$setScene(1.5, -1.2, 0.6)
            viz$setLayout(
                scene = list(
                    xaxis = list(title = "intercept"), 
                    yaxis = list(title = "slope"),
                    zaxis = list(title = "loss"),
                    showlegend = FALSE
                )
            )
            plots_optim <- append(plots_optim, list(viz$plot()))
            
        }
        
        if (length(plots_outlier) < length(n_obs) & m == 1) {
            plot_outlier <- RegressionPlotter$new(dt$data[1:n])
            plot_outlier$initLayer2D(y ~ x_1)
            plot_outlier$addScatter()
            plots_outlier[[which(n_obs == n)]] <- plot_outlier
        }
        plots_outlier[[which(n_obs == n)]]$addPredictionHyperplane(
            loss_names[m], dt$coeffs, col = loss_cols[m]
        )
        
    }
    
    if (n == max(n_obs)) {
        p <- plots_outlier[[which(n_obs == n)]]$plot() + 
            geom_point(
                dt$data[n], 
                mapping = aes(x_1, y), 
                col = "red",
                shape = "circle",
                size = 3
            )
    }
    else p <- plots_outlier[[which(n_obs == n)]]$plot()
    p <- p + theme(legend.position = "bottom")
    plots_outlier[[which(n_obs == n)]] <- p
    
}

save_image(plots_optim[[1]], "../figure/reg_l1_comparison_optim_abs.pdf")
save_image(plots_optim[[2]], "../figure/reg_l1_comparison_optim_quad.pdf")
ggsave(
    "../figure/reg_l1_comparison.pdf", 
    plots_outlier[[1]], 
    width = 3, 
    height = 2.4
)

# Coefficients for table:
readRDS(sprintf("lm_univariate_absolute_outlier_%i.Rds", min(n_obs)))$coeffs
readRDS(sprintf("lm_univariate_quadratic_outlier_%i.Rds", min(n_obs)))$coeffs

ggsave(
    "../figure/reg_l1_comparison_outlier.pdf", 
    grid.arrange(
        plots_outlier[[1]] + ylim(c(0, 6)), 
        plots_outlier[[2]] + ylim(c(0, 6)), 
        ncol = 2
    ), 
    width = 6, 
    height = 3
)
