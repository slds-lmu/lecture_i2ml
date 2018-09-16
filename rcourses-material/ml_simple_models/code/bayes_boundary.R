set.seed(314159)

load(paste0(getwd(), "/code/bayes_boundary.rds"))

margin.def = par()$mar
par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)

colBlue = function (alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colOrange = function (alpha) { rgb(255, 185, 15, alpha, maxColorValue = 255) }

# Simulate 10 means:
# ==================

nsim.means = 10

# Blue:
# -----

m.blue.x1 = rnorm(nsim.means, 1, 1)
m.blue.x2 = rnorm(nsim.means, 0, 1)

# Orange:
# -------

m.orange.x1 = rnorm(nsim.means, 0, 1)
m.orange.x2 = rnorm(nsim.means, 1, 1)

# Generate the next 100 observations for each class:
# ==================================================

nsim.obs = 100

# Draw indizes for the means to use:
# ----------------------------------

idx.blue = sample(x = seq_along(m.blue.x1), size = nsim.obs, replace = TRUE)
idx.orange = sample(x = seq_along(m.orange.x1), size = nsim.obs, replace = TRUE)

# Simulate the ovservations:
# --------------------------

x1.blue = rnorm(nsim.obs, m.blue.x1[idx.blue], 1 / 5)
x2.blue = rnorm(nsim.obs, m.blue.x2[idx.blue], 1 / 5)
x1.orange = rnorm(nsim.obs, m.orange.x1[idx.orange], 1 / 5)
x2.orange = rnorm(nsim.obs, m.orange.x2[idx.orange], 1 / 5)

# Create data table:
# ==================

dt = data.table::data.table(
  class = c(rep("BLUE", nsim.obs), rep("ORANGE", nsim.obs)),
  x1 = c(x1.blue, x1.orange),
  x2 = c(x2.blue, x2.orange)
  )
# Plot the data:
# ==============
plot(x = dt$x1,
  y = dt$x2,
  lwd = 2,
  las = 1,
  col = c(rep(colBlue(255), nsim.obs),
    rep(colOrange(255), nsim.obs)),
  xlab = expression(X[1]),
  ylab = expression(X[2]),
  main = "")

legend(x = 3.5, y = 1, legend = c(expression(pi[1] > pi[2]), expression(pi[1] < pi[2]), expression(pi[1] == pi[2])), pch = c(15, 15, NA), title = "Area with", 
  col = c(colBlue(100), colOrange(100), "black"), bty = "n", lty = c(NA, NA, 1), lwd = 2)
legend(x = 3.5, y = 1, legend = c(expression(pi[1] > pi[2]), expression(pi[1] < pi[2]), expression(pi[1] == pi[2])), pch = c(22, 22, NA), title = "Area with", 
  col = c(colBlue(255), colOrange(255), "black"), bty = "n", lty = c(NA, NA, 1), lwd = 2)

# Means:
# points(x = m.blue.x1,
#   y = m.blue.x2,
#   col = colBlue(),
#   pch = 3,
#   cex = 2,
#   lwd = 2)
# points(x = m.orange.x1,
#   y = m.orange.x2,
#   col = colOrange(),
#   pch = 3,
#   cex = 2,
#   lwd = 2)
# Bayes-Boundary:
# ===============
nsim.bayes = 100
getProb = function (x0, means)
{
  apply(X = means, MARGIN = 1, FUN = function (x) {
    mvtnorm::dmvnorm(x0, mean = x, sigma = diag(2) / 5)
  })
}

dt.means = data.table::data.table(
  means.x1 = c(m.blue.x1, m.orange.x1),
  means.x2 = c(m.blue.x2, m.orange.x2)
  )

axes.x1 = par()$usr[c(1,2)]
axes.x2 = par()$usr[c(3,4)]

grid.axes = expand.grid(
  x1 = seq(axes.x1[1], axes.x1[2], length.out = nsim.bayes),
  x2 = seq(axes.x2[1], axes.x2[2], length.out = nsim.bayes)
  )

if (! "probs" %in% ls()) {
  probs = t(apply(X = grid.axes, MARGIN = 1, FUN = function (x) {
    getProb(x0 = x, means = dt.means)
  }))
}

probs.max = apply(X = probs, MARGIN = 1, FUN = which.max)
probs.class = c(rep("BLUE", nsim.means), rep("ORANGE", nsim.means))[probs.max]
probs.01 = ifelse(probs.class == "BLUE", 1, 0)

points(x = grid.axes$x1,
  y = grid.axes$x2,
  col = ifelse(probs.class == "BLUE", colBlue(100), colOrange(100)),
  pch = 16,
  cex = 0.4)

# Again for the boundary:
nsim.boundary = 100
if (! "Z" %in% ls()) {
  grid.boundary = expand.grid(
    x1 = seq(axes.x1[1], axes.x1[2], length.out = nsim.boundary),
    x2 = seq(axes.x2[1], axes.x2[2], length.out = nsim.boundary)
    )

  probs2 = t(apply(X = grid.boundary, MARGIN = 1, FUN = function (x) {
    getProb(x0 = x, means = dt.means)
  }))

  probs.max = apply(X = probs2, MARGIN = 1, FUN = which.max)
  probs.class = c(rep("BLUE", nsim.means), rep("ORANGE", nsim.means))[probs.max]
  probs.01 = ifelse(probs.class == "BLUE", 1, 0)

  Z = matrix(data = probs.01, nrow = nsim.boundary, ncol = nsim.boundary, byrow = TRUE)
}

contour(x = seq(axes.x1[1], axes.x1[2], length.out = nsim.boundary),
  y = seq(axes.x2[1], axes.x2[2], length.out = nsim.boundary),
  z = t(Z),
  levels = 1,
  add = TRUE,
  lwd = 2,
  drawlabels = FALSE)

points(x = dt$x1,
  y = dt$x2,
  lwd = 2,
  las = 1,
  col = c(rep(colBlue(255), nsim.obs),
    rep(colOrange(255), nsim.obs)))

par(mar = margin.def)