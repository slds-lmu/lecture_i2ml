library(knitr)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(viridis)
theme_set(theme_bw())

########################## Functions drawn from a Gaussian process prior
squared.exp <- function(x1, x2, l = 1) {

  D <- as.matrix(dist(c(x1, x2), method = "euclidean"))

  K <- exp(-1 / 2 * D^2 / l^2)

  return(K)
}

set.seed(131317)
n <- 100
x <- seq(-2, 2, length.out = n)
x.obs <- c(-1.5, 1/3, 4/3, -0.5)
y.obs <- c(0, 1, 2, 1.5)

K <- squared.exp(x, x.obs)
K.xx <- K[(n + 1):nrow(K), (n + 1):nrow(K)]
K.xxs <- K[1:n, (n + 1):nrow(K)]
K.xsxs <- K[1:n, 1:n]

df <- data.frame(x = x)

# Drawing from Gaussian process Prior
for (i in 1:50) {
  df[, i + 1] <- as.vector(mvtnorm::rmvnorm(1, sigma = K.xsxs))
}

df.m <- melt(df, id.vars = "x")

p1 <- ggplot(data = df.m, aes(x = x, y = value, colour = variable)) +
  geom_line() +
  xlab("x") +
  ylab("f(x)") +
  ylim(c(-3, 3)) +
  theme(legend.position = "none") +
  ggtitle("Functions drawn from a Gaussian process prior") +
  scale_color_viridis(end = 0.9, discrete = TRUE)

ggsave("../figure/gp-prior.pdf", plot = p1, width = 6, height = 3.5)

##############################################

set.seed(131317)
p.list <- list()

for (j in 1:length(x.obs)) {
  # Update of posterior
  m.post <- K.xxs[, 1:j] %*% solve(K.xx[1:j, 1:j]) %*% y.obs[1:j]
  K.post <- K.xsxs - K.xxs[ , 1:j] %*% solve(K.xx[1:j, 1:j]) %*% t(K.xxs[, 1:j])
}

df <- data.frame(x = x)

for (i in 1:20) {
  df[, i + 1] <- as.vector(mvtnorm::rmvnorm(1, m.post, sigma = K.post))
}

df.m <- melt(df, id.vars = "x")

p2 <- ggplot() +
  geom_line(data = df.m, aes(x = x, y = value, colour = variable)) +
  geom_point(data = data.frame(x = x.obs[1:j], y = y.obs[1:j]), aes(x = x, y = y), size = 2) +
  xlab("x") + ylab("f(x)") + ylim(c(-3, 3)) + theme_bw() + theme(legend.position = "none") +
  ggtitle(paste0("Posterior process after ", j, " observation", ifelse(j == 1, "", "s"))) +
  scale_color_viridis(end = 0.9, discrete = TRUE)

ggsave("../figure/gp-posterior.pdf", plot = p2, width = 6, height = 3.5)
