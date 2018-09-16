par(mfrow = c(1,3))

## Two different lines for the SSE:
## ================================

colBlue   = function (alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colOrange = function (alpha) { rgb(255, 185,  15, alpha, maxColorValue = 255) }
colGreen  = function (alpha) { rgb(188, 238, 104, alpha, maxColorValue = 255) }

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)

plot(x, y, ylim = c(-2, 6), xlim = c(0, 8), cex = 2, pch = 4, las = 1)
# title("1. Different lines produces \ndifferent SSEs", xpd = TRUE)
grid()

# Line 1:

a = 0.5
b = 2

curve(a * x + b, add = TRUE, from = 0, to = 6, col = colBlue(255), lwd = 3)

y1 = a * x + b
w = abs(y - y1)

rect(xleft = x, ybottom = y, xright = x + w, ytop = y1, col = colBlue(90),
  border = colBlue(120), lwd = 2)

sse1 = sum((y - a * x - b)^2)

# Line 2:
a = 0.2
b = 2

curve(a * x + b, add = TRUE, from = 0, to = 6, col = colOrange(255), lwd = 3)

y2 = a * x + b
w = abs(y - y2)

rect(xleft = x, ybottom = y, xright = x + w, ytop = y2, col = colOrange(90),
  border = colOrange(120), lwd = 2)

sse2 = sum((y - a * x - b)^2)

text(x = 6.5, y = -0.5, labels =  paste0("SSE: ", sum(round((y1 - y)^2, 2))),
  col = colBlue(255))
text(x = 6.5, y = -1.5, labels =  paste0("SSE: ", sum(round((y2 - y)^2, 2))),
  col = colOrange(255))

points(x, y, cex = 2, pch = 4, lwd = 2)

## 3d SSE:
## =======

x.values = x

n.draw = 20
a.try = seq(0, 1.5, length.out = n.draw)
b.try = seq(-1, 3, length.out = n.draw)

Z = matrix(NA_real_, ncol = n.draw, nrow = n.draw)

for (i in seq_along(a.try)) {
  for (j in seq_along(b.try)) {
    Z[i, j] = sum((y - a.try[i] * x - b.try[j])^2)
  }
}

# Define some nice colors and reshape them to a color matrix:
cols = as.factor(Z[-n.draw, -n.draw])
cols.ramp = colorRampPalette(c("yellow", "brown"))(length(levels(cols)))
levels(cols) = cols.ramp
cols = as.character(cols)

p = persp(x = a.try, y = b.try, z = Z, col = cols, theta = 20, phi = 30,
  # main = "2. Surface of the SSE",
  xlab = "Slope", ylab = "Intercept", zlab = "Sum of Squared Errors")

points.3d = trans3d(x = c(0.2, 0.5), y = c(2,2), z = c(sse1, sse2), pmat = p)
points(points.3d, col = c(colBlue(255), colOrange(255)), pch = 16, cex = 2)
points(points.3d, col = "black", pch = 1, cex = 2, lwd = 2)



sse.optimal = sum((y - x)^2)

points.3d.optimal = trans3d(x = 1, y = 0, z = sse.optimal, pmat = p)
points(points.3d.optimal, col = colGreen(255), pch = 16, cex = 2)
points(points.3d.optimal, col = "black", pch = 1, cex = 2, lwd = 2)

# Last image:
# ===========

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)

plot(x, y, ylim = c(-2, 6), xlim = c(0, 8), cex = 2, pch = 4, las = 1)
# title("3. Line corresponding to the \noptimal SSE", line = 1, xpd = TRUE)
grid()
a = 1
b = 0

curve(a * x + b, add = TRUE, from = 0, to = 6, col = colGreen(255), lwd = 3)

y1 = a * x + b
w = abs(y - y1)

rect(xleft = x, ybottom = y, xright = x + w, ytop = y1, col = colGreen(90),
  border = colGreen(120), lwd = 2)
text(x = x, y = y, labels = paste0("SE: ", round((y1 - y)^2, 2)), pos = 1)
text(x = 6.5, y = -1, labels =  paste0("SSE: ", sum(round((y1 - y)^2, 2))),
  col = colGreen(255))

points(x, y, cex = 2, pch = 4, lwd = 2)


par(mfrow = c(1,1))