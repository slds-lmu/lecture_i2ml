set.seed(1)

png(filename = "figure_man/loss_quadratic_plot1.png", bg = "transparent", width = 500, height = 250)
par(mfrow = c(1, 2))

sigma = matrix(c(1, 0.7, 0.7, 1), nrow = 2)
mat   = as.data.frame(rmvnorm(50, mean = c(5,5), sigma = sigma, method = "chol"))
colnames(mat) = c("x", "y")

x = mat$x
y = mat$y

plot(x, y, pch=19, cex=0.8)   # Plot the points
fit_l2 = lm(y ~ x)              # Find the least squares line
abline(fit_l2)                   # Plot the line
text(x = min(x), y = min(fit_l2$fitted.values), labels = expression(hat(y)), pos = 3)

idx = order(x)[c(10, 20, 30, 40, 50)]
x = mat$x[idx]
y = mat$y[idx]
residuals = fit_l2$residuals[idx]
fitted = fit_l2$fitted.values[idx]
u = mapply(function(x,y,r) rect(x, y, x-r, y-r, col = hsv(rgb2hsv(col2rgb("red")), alpha=0.1), border=NA),
           x, y, residuals)     # Plot the squares
for (i in 1:length(x))
  lines(x = c(x[i], x[i]), y = c(fitted[i], y[i]), col = "red")

xx = seq(-2, 2, by = 0.01);
yy = xx^2
plot(xx, yy, type = "l", xlab = "y - f(x)", ylab = "L(y, f(x))")

for (i in 1:length(x)) {
  lines(x = c(residuals[i], residuals[i]), y = c(0, residuals[i]^2), col = "red")
  points(residuals[i], residuals[i]^2, col = "red")
}

dev.off()