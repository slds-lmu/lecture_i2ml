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

# BASIC POLYNOMIAL RELATION ----------------------------------------------------

n_points = 50L
set.seed(pi)
x = runif(n_points, min = 0, max = 3)
y = x^3 + rnorm(n_points, sd = 0.5)

plot_yx = ggplot(data.frame(x = x, y = y), aes(x, y)) +
    theme_bw() +
    geom_point()
plot_yx3 = ggplot(data.frame(x = x^3, y = y), aes(x, y)) +
    theme_bw() +
    geom_point() +
    labs(x = expression(x**3))
ggsave(
    "../figure/reg_poly_yx3.pdf", 
    grid.arrange(plot_yx, plot_yx3, ncol = 2), 
    height = 2, 
    width = 6
)

# LINEARITY IN PARAMS ----------------------------------------------------------

set.seed(pi)
plot_linearity = ggplot(
    data.frame(x = x, y = 1 + x + rnorm(n_points, sd = 0.5)), aes(x, y)
) +
    theme_bw() +
    geom_point() +
    geom_abline(intercept = 0.5, slope = 0.4, color = "darkorange") +
    geom_abline(intercept = 1, slope = 0.8, color = "blue") +
    geom_abline(intercept = 1.5, slope = 1.2, color = "#b73779") +
    ylim(c(0, 5))
ggsave(
    "../figure/reg_poly_linearity.pdf", plot_linearity, height = 2, width = 2
)

# UNIVARIATE POLYNOMIALS -------------------------------------------------------

n_points = 50L
set.seed(pi)
x = runif(n_points, min = 0, max = 10)
y = 0.5 * sin(x) + rnorm(n_points, sd = 0.3)
degrees = c(1, 5, 25, 200)
polys = sprintf("d_%i", seq_along(degrees))
dt = data.table(
    x,
    y,
    predict(lm(y ~ poly(x, degrees[1], raw = TRUE)), data.frame(x)),
    predict(lm(y ~ poly(x, degrees[2], raw = TRUE)), data.frame(x)),
    predict(lm(y ~ poly(x, degrees[3], raw = TRUE)), data.frame(x)),
    predict(lm(y ~ poly(x, degrees[4], raw = TRUE)), data.frame(x))
)
setnames(dt, c("x", "y", polys))
dt = data.table::melt(dt, id.vars = c("x", "y"))

for (i in seq_along(polys)) {
    p = ggplot(dt, aes(x = x, y = y)) +
        theme_bw() +
        geom_point() +
        geom_line(
            dt[variable %in% polys[1:i]],
            mapping = aes(x = x, y = value, col = variable)
        ) +
        scale_color_manual(
            "degree", 
            labels = degrees, 
            values = c("darkorange", "#b73779", "blue", "darkgray")[1:i]
        )
    ggsave(
        sprintf("../figure/reg_poly_univ_%i.pdf", i), p, height = 2, width = 6
    )
    if (i == length(polys)) {
        ggsave(
            "../figure/reg_poly_title.pdf", p, height = 2, width = 4
        )
    }
}

# BIVARIATE EXAMPLE ------------------------------------------------------------

n_points = 500L
set.seed(pi)
dt_biv = data.table(x_1 = rnorm(n_points), x_2 = rnorm(n_points))
dt_biv[, y := 1 + 2 * x_1 + x_2^3 + rnorm(n_points, sd = 0.5)]
plotter_3d <- RegressionPlotter$new(dt_biv)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "black")
plotter_3d$addPredictionHyperplane(
    "l2", coefficients(lm(y ~ x_1 + x_2, dt_biv))
)
plotter_3d$plot()


p <- plotter_3d$plot(x = -1.9, y = 0, z = 0) %>% 
    hide_colorbar() %>% 
    hide_legend()
save_image(p, "../figure/reg_l2_basic_lm_biv.pdf")