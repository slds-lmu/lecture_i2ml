source("libfuns_lm.R")

n_points <- 10L
set.seed(123)
x_1 = rnorm(n_points) 
x_2 = rnorm(n_points)
dt <- data.table(x_1, x_2, y = x_1 + x_2 + rnorm(n_points))

computer <- RegressionComputer$new(dt)
computer$computeRegression("l1", y ~ x_1, loss = "absolute")