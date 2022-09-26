
par(mfrow = c(1, 1))

mpoints = list(c(1, 2),c(3, 1))
x1 = sapply(mpoints,function(x) x[1])
x2 = sapply(mpoints,function(x) x[2])
y = c(1, 1)

par(mar = c(4,4,1,1), pin = c(3,3))
plot(x1, x2, pch = ifelse(y == -1, "-", "+"), cex = 1.5,
     xlim = c(0,4), ylim = c(0,3),
     ylab = "x2", xlab = "x1")
# abline(coef = c(2, -1), lty = 1)
grid(lwd = 2)
points(x1, x2, pch = ifelse(y == -1, "-", "+"), cex = 1.5)