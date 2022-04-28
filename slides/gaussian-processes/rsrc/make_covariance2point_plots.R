# ----------------------------------------------------------------------- #
# Covariance 2D example                                                   #
# ----------------------------------------------------------------------- #

# Initialization -------------------------------------------------------- #
library(mvtnorm)
library(ggplot2)
library(ggpubr)
library(gridExtra)

# ----------------------------------------------------------------------- #

# Squaorange exponential Covariance Function ------------------------------- #

sqexp <- function(d, l = 1) {
  exp(- 0.5 * d^2 / l)
}

sqexp.vec <- function(x, l = 1) {
  D <- as.matrix(dist(x))
  res <- sqexp(D)
  return(res)
  }

# Example for a discrete function with input space containing two points
x <- c(3, 2.5, 5)
df <- data.frame(x = x)

m <- c(0, 0, 0)
K <- sqexp.vec(x)

# sample 
set.seed(1234)
y <- t(rmvnorm(1, mean = m, sigma = K))
df$y <- y


p1 <- ggplot(data.frame(x = c(- 4, 4)), aes(x)) +
  stat_function(fun = sqexp, geom = "line") +
  theme_bw() +
  geom_point(aes(x = 0.5, y = sqexp(0.5)), color = "orange", size = 2) +
  geom_segment(aes(x = 0.5, xend = 0.5, y = 0, yend = sqexp(0.5)), color = "orange", lty = 2) +
  geom_text(aes(x = 1.8, y = sqexp(0.5), label = "high \n correlation \n of y values"), color = "orange", size = 3) +
  xlab("d") +
  ylab("k(d)") +
  ggtitle("Covariance Function")

p2 <- ggplot() +
  ylim(c(-2, 2)) +
  xlim(c(0, 6)) +
  theme_bw() +
  geom_vline(data = df, aes(xintercept = x), color = "grey", lty = 2) +
  geom_text(aes(x = x[3] - 0.3, y = -2, label = "x[3]"), size = 3, parse = TRUE, colour = "darkgrey") +
  geom_text(aes(x = x[1] + 0.3, y = -2, label = "x[1]"), size = 3, parse = TRUE, colour = "darkgrey") +
  geom_segment(aes(x = x[1], xend = x[2], y = y[1], yend = y[1]), color = "orange") +
  geom_text(aes(x = x[1] + 0.5 * (x[2] - x[1]), y = y[1] - 0.4, label = "d = 0.5"), color = "orange", size = 3) +
  geom_text(aes(x = x[1] + 0.3, y = y[1], label = "y[1]"), size = 3, parse = TRUE) +
  geom_point(aes(x = x[1], y = y[1]), size = 2) +
  xlab("x") +
  ylab("f(x)")

ggsave(filename = "../figure/covariance2point/example_covariance_1.pdf", plot = p1,, height = 3, width = 3)
ggsave(filename = "../figure/covariance2point/example_function_1_1.pdf", plot = p2, height = 2.5, width = 3)

p2 <- p2 + geom_segment(aes(x = x[2], xend = x[2], y = y[1], yend = y[2]), color = "orange")
p2 <- p2 + geom_point(aes(x = x[2], y = y[2]), size = 2)
p2 <- p2 + geom_text(aes(x = x[2] - 0.3, y = -2, label = "x[2]"), size = 3, parse = TRUE, colour = "darkgrey")
p2 <- p2 + geom_text(aes(x = x[2] - 0.3, y = y[2], label = "y[2]"), size = 3, parse = TRUE)
# p2 = p2 + geom_text(aes(x = x[2] - 1, y = y[2], label = "y values \n close"), size = 3, color = "orange")

ggsave(filename = "../figure/covariance2point/example_function_1_2.pdf", plot = p2, height = 2.5, width = 3)


p1 <- p1 + geom_point(aes(x = - 2.5, y = sqexp(- 2.5)), color = "blue", size = 2)
p1 <- p1 + geom_segment(aes(x = - 2.5, xend = - 2.5, y = 0, yend = sqexp(2.5)), color = "blue", lty = 2)
p1 <- p1 + geom_text(aes(x = - 3, y = sqexp(- 2.5) + 0.2, label = "low \n correlation \n of y values"), color = "blue", size = 3)
p1 <- p1 + xlab("d") + ylab("k(d)")

ggsave(filename = "../figure/covariance2point/example_covariance_2.pdf", plot = p1,, height = 3, width = 3)

p2 <- p2 + geom_segment(aes(x = x[1], xend = x[3], y = y[1], yend = y[1]), color = "blue")
p2 <- p2 + geom_segment(aes(x = x[3], xend = x[3], y = y[1], yend = y[3]), color = "blue")
p2 <- p2 + geom_point(aes(x = x[3], y = y[3]), size = 2)
p2 <- p2 + geom_text(aes(x = x[3] - 0.3, y = y[3], label = "y[3]"), size = 3, parse = TRUE)

ggsave(filename = "../figure/covariance2point/example_function_2_1.pdf", plot = p2, height = 2.5, width = 3)

