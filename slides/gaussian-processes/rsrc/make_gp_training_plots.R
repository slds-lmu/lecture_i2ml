# ----------------------------------------------------------------------- #
# Training of a Gaussian Process                #
# ----------------------------------------------------------------------- #

# Initialization -------------------------------------------------------- #
library(mvtnorm)
library(ggplot2)
# library(RandomFieldsUtils)


# Sampling from a Gaussian process with l = 1
set.seed(123)

n <- 15 # number of points
x <- seq(-2, 2, length.out = n) # n equally spaced points
D <- as.matrix(dist(x, method = "euclidean")) # distance matrix

ltrue <- 0.5
K <- exp(-1 / 2 * D^2 / ltrue^2)

noise <- 0.5
y <- as.vector(rmvnorm(1, Sigma = K)) + rnorm(n, sd = noise)

df <- data.frame(x = x, y = y)

p1 <- ggplot(data = df, aes(x = x, y = y)) + geom_point() + theme_bw()
p1 <- p1 + ggtitle("Data Points")

ggsave("../figure/gp_training/datapoints.pdf", p1, height = 3, width = 4)


computeMarginalLogLik <- function(y, D, l, noise) {
	
	n <- length(y)

	Ky <- exp(-1 / 2 * D^2 / l^2) + diag(rep(noise, length(x)))

	fit <- - 0.5 * t(y) %*% solve(Ky) %*% y
	penalty <- - 0.5 * log(det(Ky))

	margll <- penalty + fit

	return(list(fit = as.numeric(fit), penalty = as.numeric(penalty), margll = as.numeric(margll)))
}

computePosterior <- function(x, xnew, y, l, noise) {

	n <- length(y)
		
	Dnew <- as.matrix(dist(c(x, xnew), method = "euclidian"))
	Knew <- exp(- 1 / 2 * Dnew^2 / l^2)

	K <- Knew[1:n, 1:n]
	Kx <- Knew[1:n, (n + 1):nrow(Knew)]
	Kxx <- Knew[(n + 1):nrow(Knew), (n + 1):nrow(Knew)]

	Ky <- K + diag(rep(noise, length(x)))

	Kyinv <- solve(Ky)

	mpost <- t(Kx) %*% Kyinv %*% y
	Kpost <- Kxx - t(Kx) %*% Kyinv %*% Kx

	return(data.frame(x = xnew, mpost = mpost, sdpost = diag(Kpost)))
}


lengthscales <- seq(0.1, 2, by = 0.01)

res <- lapply(lengthscales, function(l) computeMarginalLogLik(y, D, l, noise))

dfl <- data.frame(l = lengthscales)
dfl$Fit <- sapply(res, function(x) x$fit)
dfl$Penalty <- sapply(res, function(x) x$penalty)
dfl$LogLikelihood <- sapply(res, function(x) x$margll)

dfl <- reshape2::melt(dfl, id.vars = c("l"))

p2 <- ggplot() + geom_line(data = dfl, aes(x = l, y = value, color = variable))
p2 <- p2 + theme_bw() + labs(colour = "") + theme(legend.position = "top")

ggsave("../figure/gp_training/fit_vs_penalty.pdf", p2, height = 3, width = 4)



xnew <- seq(-2, 2, length.out = 100)

for (l in c(0.2, 0.5, 2)) {

	res <- computePosterior(x, xnew, y, l, noise)
	res$sdupper <- res$mpost + 2 * res$sdpost
	res$sdlower <- res$mpost - 2 * res$sdpost

	p2n <- p2 + geom_vline(data = data.frame(), aes(xintercept = l), lty = 2, colour = "grey")

	ggsave(paste0("../figure/gp_training/fit_vs_penalty_", gsub("\\.", "_", l), ".pdf"), p2n, height = 3, width = 4)

	p1n <- p1 + geom_line(data = res, aes(x = x, y = mpost), colour = "grey")
	p1n <- p1n + ggtitle(paste0("l = ", l))
	ggsave(paste0("../figure/gp_training/datapoints_", gsub("\\.", "_", l), ".pdf"), p1n, height = 3, width = 4)
}