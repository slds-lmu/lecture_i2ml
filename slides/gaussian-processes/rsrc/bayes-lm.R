library(mvtnorm)
library(ggplot2)


# Data 

set.seed(1234)

n = 50

x = seq(-3.5, 7, length.out = n)
x = sample(x, length(x))
y = 0.5 * x + rnorm(n)

d = data.frame(x0 = rep(1, n), x = x, y = y)

p = ggplot(data = d, aes(x = x, y = y)) + geom_point() + theme_bw() + ylab("x") + ylab("y")
ggsave("figure_man/bayes-lm/example.pdf", width = 4, height = 3)


# Prior and Posterior for the Bayes Linear Model 

grid = expand.grid(theta0 = seq(-3, 3, length.out = 200), theta1 = seq(-3, 3, length.out = 200))

# Prior 
# using a standard normal prior 
probs = cbind(grid, prior = mvtnorm::dmvnorm(grid))

p1 = ggplot(probs, aes(x = theta0, y = theta1, z = prior)) + geom_contour()
p1 = p1 + coord_fixed(xlim = c(-3, 3), ylim = c(-2, 2))
p1 = p1 + xlab(expression(theta[0])) + ylab(expression(theta[1]))
p1 = p1 + geom_raster(aes(fill = prior)) + geom_contour(colour = "white", bins = 5)
p1 = p1 + geom_point(x = 0, y = 0, color = "orange", size = 2) 
p1 = p1 + guides(fill = FALSE) + ggtitle(expression(paste("Prior ", theta, "~", N(0, 1)))) + theme(title = element_text(size = 11)) 
p1 = p1 + theme_bw()

ggsave("figure_man/bayes-lm/prior-1.pdf", p1, width = 4, height = 4)

p2 = ggplot() + geom_point(data = as.data.frame(d), aes(x = x, y = y), colour = "grey")
p2 = p2 + geom_abline(intercept = 0, slope = 0, color = "orange")
p2 = p2 + ggtitle("No data points observed") + theme_bw()

ggsave("figure_man/bayes-lm/prior-2.pdf", p2, width = 4, height = 4)


# Posterior distribution
nobs = c(5, 10, 20)
d = as.matrix(d)

titles = c("Posterior distribution after 5 obs.", "Posterior distribution after 10 obs.", "Posterior distribution after 20 obs.")

for (j in 1:length(nobs)) {
  i = nobs[j]
  A = t(d[1:i, 1:2]) %*% d[1:i, 1:2] + diag(2)
  b = as.vector(d[1:i, 3] %*% d[1:i, 1:2])
  m.post = solve(A, b)
  sigma.post = solve(A)
  probs$posterior = dmvnorm(grid, mean = m.post, sigma = sigma.post)

  p1 = ggplot(probs, aes(x = theta0, y = theta1, z = posterior)) + geom_contour( colour = i)
  p1 = p1 + coord_fixed(xlim = c(-3, 3), ylim = c(-2, 2))
  p1 = p1 + xlab(expression(theta[0])) + ylab(expression(theta[1]))
  p1 = p1 + geom_raster(aes(fill = posterior)) + geom_contour(colour = "white", bins = 5)
  p1 = p1 + geom_point(x = m.post[1], y = m.post[2], color = "orange", size = 2)
  p1 = p1 + guides(fill = FALSE) + ggtitle(expression(paste("Posterior of ", theta))) + theme(title = element_text(size = 11))
  p1 = p1 + theme_bw()

  ggsave(paste0("figure_man/bayes-lm/posterior-", i, "-1.pdf"), p1, width = 4, height = 4)
 
  p2 = ggplot() + geom_point(data = as.data.frame(d), aes(x = x, y = y), colour = "grey")
  p2 = p2 + geom_point(data = as.data.frame(d[1:i, ]), aes(x = x, y = y))
  p2 = p2 + geom_abline(intercept = m.post[1], slope = m.post[2], color = "orange")
  p2 = p2 + ggtitle(paste0("MAP after observing ", i, " data points")) + theme_bw()

  ggsave(paste0("figure_man/bayes-lm/posterior-", i, "-2.pdf"), p2, width = 4, height = 4)

  xpred = data.frame(x0 = rep(1, 200), x = as.numeric(seq(-3.5, 7, length.out = 200)))
  postmean = as.matrix(xpred) %*% m.post
  post.sd = as.matrix(xpred) %*% sigma.post %*% t(as.matrix(xpred))
  xpred$postmean = postmean
  xpred$postsd_upper = as.vector(xpred$postmean + 2 * diag(post.sd))
  xpred$postsd_lower = as.vector(xpred$postmean - 2 * diag(post.sd))

  p2 = ggplot(data = xpred) + geom_ribbon(aes(x = x, ymin = postsd_lower, ymax = postsd_upper), fill = "grey", alpha = 0.5)
  p2 = p2 + geom_point(data = as.data.frame(d), aes(x = x, y = y), colour = "grey")
  p2 = p2 + geom_point(data = as.data.frame(d[1:i, ]), aes(x = x, y = y))
  p2 = p2 + geom_abline(intercept = m.post[1], slope = m.post[2], color = "orange")
  p2 = p2 + ggtitle(paste0("MAP after observing ", i, " data points")) + theme_bw()
  p2
  ggsave(paste0("figure_man/bayes-lm/posterior-", i, "-3.pdf"), p2, width = 4, height = 4)

}
