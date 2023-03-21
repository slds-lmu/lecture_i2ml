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
    geom_abline(intercept = 0.5, slope = 0.4, color = "blue") +
    geom_abline(intercept = 1, slope = 0.8, color = "#feb078") +
    geom_abline(intercept = 1.5, slope = 1.2, color = "#b73779") +
    ylim(c(0, 5))
ggsave(
    "../figure/reg_poly_linearity.pdf", plot_linearity, height = 2, width = 2
)

# BASIS FUNS -------------------------------------------------------------------

degrees = 1:5 

plot_basis = ggplot() +
    theme_bw() 

for (j in degrees) {
    plot_basis = plot_basis +
        stat_function(
            data.frame(x = -5:5, col = as.character(j)),
            mapping = aes(x = x, col = col),
            fun = function(x, d) x**d, 
            args = list(d = j),
            linetype = j
        )
}
plot_basis = plot_basis +
    ylim(c(-100, 100)) +
    scale_color_viridis_d(
        "degree", 
        end = 0.9, 
        direction = -1,
        option = "magma",
        guide = guide_legend(
            override.aes = list(linetype = 1:5)
        )
    )
ggsave(
    "../figure/reg_poly_basis.pdf", plot_basis, height = 1.5, width = 4
)

# UNIVARIATE POLYNOMIALS -------------------------------------------------------

n_points = 50L
set.seed(pi)
x = runif(n_points, min = 0, max = 10)
y = 0.5 * sin(x) + rnorm(n_points, sd = 0.3)
degrees = c(1, 5, 25, 50)
models = lapply(degrees, function(i) lm(y ~ poly(x, i, raw = TRUE)))
plot_poly <- function(until = 1) {
    p = ggplot(dt, aes(x = x, y = y)) +
        theme_bw() +
        geom_point()
    for (i in 1:until) {
        df =  data.frame(x = seq(0, 10, by = 0.01))
        p = p + geom_line(
            data.frame(
                x = df, 
                y = predict(models[[i]], newdata = df),
                col = as.character(i)
            ),
            mapping = aes(x = x, y = y, col = col)
        )
    }
    p + 
        ylim(c(-1, 1)) +
        scale_color_viridis_d(
            "degree", 
            option = "magma",
            end = 0.9, 
            direction = -1,
            labels = degrees[1:until]
        )
}

ggsave(
    "../figure/reg_poly_univ_2.pdf", plot_poly(2), height = 2, width = 4
)
ggsave(
    "../figure/reg_poly_univ_4.pdf", plot_poly(4), height = 2, width = 6
)
ggsave("../figure/reg_poly_title.pdf", plot_poly(4), height = 2, width = 4)

# BIVARIATE EXAMPLE ------------------------------------------------------------

n_points = 50L
set.seed(pi)
dt_biv = data.table(x_1 = rnorm(n_points), x_2 = rnorm(n_points))
dt_biv[, y := 1 + 2 * x_1 + x_2^3 + rnorm(n_points, sd = 0.5)]
plotter_3d <- RegressionPlotter$new(dt_biv)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "black")

axis_x1 <- seq(-2, 2, by = 0.05)
axis_x2 <- seq(-2, 2, by = 0.05)
lm_surface <- expand.grid(
    x_0 = 1, x_1 = axis_x1, x_2 = axis_x2, KEEP.OUT.ATTRS = F
)
lm_surface$y <- predict(
    lm(y ~ x_1 + poly(x_2, 7, raw = TRUE), dt_biv),
    data.frame(x_1 = axis_x1, x_2 = axis_x2)
)
lm_surface <- acast(lm_surface, x_2 ~ x_1, value.var = "y")
plot_biv = plotter_3d$plot(x = -0.8, y = 1.6, z = 0) %>%
    add_trace(
        z = lm_surface,
        x = axis_x1,
        y = axis_x2,
        type = "surface",
        colorbar = list(
            title = "", 
            ticks = "", 
            nticks = 1
        ),
        colorscale = list(c(0, 1), rep("blue", 2)),
        opacity = 0.7
    ) %>% 
    hide_colorbar() %>% 
    hide_legend()
save_image(plot_biv, "../figure/reg_poly_biv.pdf")
