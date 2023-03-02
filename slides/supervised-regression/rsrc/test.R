source("libfuns_lm.R")

set.seed(123)
x_1 = rnorm(10) 
x_2 = rnorm(10)
dt <- data.table(x_1, x_2, y = x_1 + x_2 + rnorm(10))

computer = RegressionComputer$new(dt)
computer$computeRegression(y ~ x_1, loss = "quadratic")

plotter = RegressionPlotter$new(do.call(rbind, computer$regression_data))
plotter$initLayer2D(y ~ x_1)
plotter$addScatter(col = "blue")
plotter$addPredictionHyperplane(computer$coefficients[[1]])
# plotter$addResiduals2D(c(2, 4), quadratic = TRUE)
# plotter$addResiduals2D(c(5), quadratic = TRUE, col = "green", fill = "green")
plotter$plot()
