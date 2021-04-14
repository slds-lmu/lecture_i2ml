set.seed(1)

png(filename = "figure_man/loss_absolute_plot1.png", bg = "transparent", width = 500, height = 250)
par(mfrow = c(1, 2))

sigma = matrix(c(1, 0.7, 0.7, 1), nrow = 2)
mat   = as.data.frame(rmvnorm(50, mean = c(5,5), sigma = sigma, method = "chol"))
colnames(mat) = c("x", "y")

x = mat$x
y = mat$y

plot(x, y, pch=19, cex=0.8)   # Plot the points
fit_l1 = rq(y ~ x, .5)        # Find the least squares line
abline(fit_l1)                # Plot the line
text(x = min(x), y = min(fit_l1$fitted.values), labels = expression(hat(y)), pos = 3)

idx = order(x)[c(10, 20, 30, 40, 50)]
x = mat$x[idx]
y = mat$y[idx]
residuals = fit_l1$residuals[idx]
fitted = fit_l1$fitted.values[idx]

for (i in 1:length(x))
  lines(x = c(x[i], x[i]), y = c(fitted[i], y[i]), col = "red")

xx = seq(-2, 2, by = 0.01);
yy = abs(xx)
plot(xx, yy, type = "l", xlab = "y - f(x)", ylab = "L(y, f(x))")

for (i in 1:length(x)) {
  
  lines(x = c(residuals[i], residuals[i]), y = c(0, abs(residuals[i])), col = "red")
  points(residuals[i], abs(residuals[i]), col = "red")
  
}

dev.off()