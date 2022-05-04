

library(knitr)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(viridis)

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
  theme_bw() +
  xlab("x") +
  ylab("f(x)") +
  ylim(c(-3, 3)) +
  theme(legend.position = "none") +
  ggtitle("Functions drawn from a Gaussian process prior") +
  scale_color_viridis(end=0.9, discrete = TRUE)

ggsave("../figure/gp_sample/1_1.pdf", width = 6, height = 4)

##############################################

set.seed(131317)
p.list <- list()

for (j in 1:length(x.obs)) {
  # Update of posterior 
  m.post <- K.xxs[, 1:j] %*% solve(K.xx[1:j, 1:j]) %*% y.obs[1:j]
  K.post <- K.xsxs - K.xxs[ , 1:j] %*% solve(K.xx[1:j, 1:j]) %*% t(K.xxs[, 1:j])
  
  df <- data.frame(x = x)
  
  for (i in 1:20) {
    df[, i + 1] <- as.vector(mvtnorm::rmvnorm(1, m.post, sigma = K.post))
  }
  
  df.m <- melt(df, id.vars = "x")
  
  p.list[[j]] <- ggplot() +
    geom_line(data = df.m, aes(x = x, y = value, colour = variable)) +
    geom_point(data = data.frame(x = x.obs[1:j], y = y.obs[1:j]),
               aes(x = x, y = y),
               size = 2) +
    xlab("x") +
    ylab("f(x)") +
    ylim(c(-3, 3)) +
    theme_bw() +
    theme(legend.position = "none") +
    ggtitle(paste0("Posterior process after ", j, " observation", ifelse(j == 1, "", "s"))) +
    scale_color_viridis(end = 0.9, discrete = TRUE)
  
  ggsave(paste0("../figure/gp_sample/2_", j, ".pdf"), width = 6, height = 4)
}

###############################################
##### 10 different samples

# n <- 3
# x <- c(1, 2, 5)
#
# K <- matrix(0, n, n)
#
# for (i in 1:n) {
#   for (j in 1:n) {
#     K[i, j] <- exp(- 1/2 * (abs(x[i] - x[j]))^2)
#     # K[i, j] = t(x[i]) %*% x[j] # linear kernel
#   }
# }
#
# df <- data.frame(x = x)
# df$y <- as.vector(rmvnorm(1, sigma = K))
#
# p <- ggplot(data = df, aes(x = x, y = y)) + geom_line() + theme_bw()
# p <- p + xlab("x") + ylab("f(x)")
# p

################################################

plot_10_samples <- function(l=1) {
  set.seed(1221)
  n <- 100

  x <- seq(-2, 2, length.out = n)
  K <- matrix(0, n, n)

  for (i in 1:n) {
    for (j in 1:n) {
      K[i, j] <- exp(- 1/(2*l^2) * (abs(x[i] - x[j]))^2)
      # K[i, j] = t(x[i]) %*% x[j] # linear kernel
    }
  }

  df <- data.frame(x = x)

  for (i in 1:10) {
    df[, i + 1] <- as.vector(mvtnorm::rmvnorm(1, sigma = K))
  }

  df.m <- melt(df, id.vars = "x")

  p <- ggplot(data = df.m, aes(x = x, y = value, colour = variable)) +
    geom_line() +
    theme_bw() +
    xlab("x") +
    ylab("f(x)") +
    ylim(c(-5, 5)) +
    theme(legend.position = "none") +
    scale_color_viridis(end=0.9, discrete = TRUE)

  return(p)
}

p1 <- plot_10_samples()

ggsave(filename = "../figure/gp_sample/different_samples.pdf",
       plot = p1, width = 6, height = 2)


p2 <- plot_10_samples(l=0.1)

p <- grid.arrange(p1 + ggtitle("l = 1"),
                  p2 + ggtitle("l = 0.1"),
                  ncol = 2)

ggsave(filename = "../figure/gp_sample/varying_length_scale.pdf",
       plot = p, width = 6, height = 3)

