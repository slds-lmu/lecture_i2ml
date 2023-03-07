source("libfuns_lm.R")

n_points <- 10L
set.seed(123)
x_1 = rnorm(n_points) 
x_2 = rnorm(n_points)
dt <- data.table(x_1, x_2, y = x_1 + x_2 + rnorm(n_points))

computer <- RegressionComputer$new(dt)
computer$computeRegression("l1", y ~ x_1, loss = "absolute")
computer$computeRegression("l2", y ~ x_1, loss = "quadratic")
computer$computeRegression(
    "custom_3d", 
    y ~ x_1 + x_2, 
    loss = "custom", 
    custom_loss = function(x) (max(x, 0))**2
)
computer$computeRegression(
    "huber_3d", y ~ x_1 + x_2, loss = "huber", list(epsilon = 10)
)

plot_data <- do.call(rbind, computer$regression_data)
plotter_2d <- RegressionPlotter$new(plot_data)
plotter_2d$initLayer2D(y ~ x_1)
plotter_2d$addScatter()
plotter_2d$addPredictionHyperplane(
    "L1", computer$coefficients[[1]], col = "blue"
)
plotter_2d$addPredictionHyperplane(
    "L2", computer$coefficients[[2]], col = "red"
)
plotter_2d$plot("loss function")
plotter_2d$addResiduals(
    plot_data[id == "l2", y_hat], c(2, 4), quadratic = FALSE, col = "red"
)
plotter_2d$addResiduals(
    plot_data[id == "l2", y_hat], 3, quadratic = TRUE, col = "red", fill = "red"
)
plotter_2d$plot("losses")

plotter_loss <- LossPlotter$new(seq(-5, 5, by = 1))
plotter_loss$initLayer()
plotter_loss$addLossCurve("l2", function(x) x**2, col = "orange")
plotter_loss$addLossCurve("l1", function(x) abs(x), col = "green")
plotter_loss$addAnnotation("l2", c(3, 5), linetype = 2)
plotter_loss$addAnnotation("l2", c(3, 5), type = "point")
plotter_loss$addAnnotation("l2", c(3, 5), type = "text")
plotter_loss$plot("hi")


plotter_3d <- RegressionPlotter$new(plot_data)
plotter_3d$initLayer3D(y ~ x_1 + x_2)
plotter_3d$addScatter(col = "blue")
plotter_3d$addPredictionHyperplane("custom", computer$coefficients[[3]])
plotter_3d$addPredictionHyperplane(
    "huber", computer$coefficients[[4]]
)
plotter_3d$plot()

# TODO make appropriate legends
# TODO implement loss hypersurface plots

             