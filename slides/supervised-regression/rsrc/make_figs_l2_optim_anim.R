# PREREQ -----------------------------------------------------------------------

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

# DATA -------------------------------------------------------------------------

set.seed(pi)
x_1 <- 1:5
y <- x_1 + rnorm(5, 0, 2)
dt <- data.table(x_1, y)
true_coeffs <- coefficients(lm(y ~ x_1))
coeffs <- list(c(1.8, .3), c(1, .1), c(0.5, .8), true_coeffs)
colors <- c("darkgreen", "orange", "red", "blue")
    
# PLOTS MODEL FIT --------------------------------------------------------------

lapply(
    seq_along(coeffs),
    function(i) {
        p <- RegressionPlotter$new(dt)
        p$initLayer2D(y ~ x_1)
        p$addScatter()
        p$addPredictionHyperplane("manual_1", coeffs[[i]], col = colors[i])
        p$addResiduals(
            y_hat = coeffs[[i]][1] + coeffs[[i]][2] * x_1, 
            idx_residuals = seq_len(length(x_1)),
            quadratic = TRUE,
            col = colors[i],
            fill = colors[i]
        )
        ggsave(
            sprintf("../figure/reg_lm_sse_1%i.pdf", i), 
            p$plot() + xlim(c(0, 7)) + ylim(-2, 6), 
            width = 3, 
            height = 3.2
        )
    }
)

# PLOT OPTIM TRACE -------------------------------------------------------------

# Compute optim trace

mylm <- function(x, Xmat, y) norm(Xmat %*% x - y, "2")
Xmat <- model.matrix(~ x_1, data = dt)

obj_lm <- Objective$new(
    id = "exmpl_lm", fun = mylm, xdim = 2, Xmat = Xmat, y = y, minimize = TRUE
)
gd <- OptimizerGD$new(obj_lm, x_start = c(0, 4), print_trace = FALSE)

n_steps <- 10000
gd$optimize(steps = n_steps)

# Create loss surface plot

viz <- Visualizer$new(obj_lm, x1limits = c(-2, 2), x2limits = c(-0.5, 3.5))
viz$initLayerSurface(colorscale = list(c(0, 1), c("darkgray", "white")))
viz$setScene(-1.5 * 1.1, -1.1 * 1.1, 2 * 1.1)
viz$setLayout(
    scene = list(
        xaxis = list(title = "intercept"), 
        yaxis = list(title = "slope"),
        zaxis = list(title = "loss"),
        showlegend = FALSE
    )
)

# Add manually devised coefficients to plot

dt_coeffs_manual <- data.table(
    x = c(sapply(coeffs, function(i) i[1])[-4], NULL),
    y = c(sapply(coeffs, function(i) i[2])[-4], NULL),
    z = c(sapply(coeffs, function(i) mylm(i, Xmat, y))[-4], NULL),
    color = c(colors[-4], NULL)
)
plot_manual_markers <- function(plot, i, filename) {
    p <- plot %>% 
        add_trace(
            x = dt_coeffs_manual$x[1:i],
            y = dt_coeffs_manual$y[1:i],
            z = dt_coeffs_manual$z[1:i],
            type = "scatter3d",
            mode = "markers",
            marker = list(
                symbol = "circle",
                showscale = FALSE,
                size = 10,
                color = colors[1:i]
            )
        )
    save_image(p, sprintf("../figure/%s.pdf", filename))
}
invisible(
    lapply(
        seq_along(coeffs[-length(coeffs)]),
        function(i) {
            plot_manual_markers(
                viz$plot(), i, sprintf("reg_lm_sse_optim_%i", i)
            )
        }
    )
)

# Add optim trace

viz$addLayerOptimizationTrace(
    gd, line_color = "blue", add_marker_at = n_steps
)
plot_manual_markers(
    viz$plot() %>% layout(showlegend = FALSE), 
    length(coeffs) - 1,
    sprintf("reg_lm_sse_optim_%i", length(coeffs))
)
