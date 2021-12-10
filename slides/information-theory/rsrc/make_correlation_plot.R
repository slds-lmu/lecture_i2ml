# ------------------------------------------------------------------------------
# FIG: CORRELATION
# ------------------------------------------------------------------------------
library(ggplot2)
library(gridExtra)
library(mvtnorm)

# DATA -------------------------------------------------------------------------
n <- 400
uni_data <- runif(n, -1, 1)

y1 <- 4 * (uni_data^2 - 1/2)^2 + runif(n, -1, 1)/3
df1 <- data.frame(x = uni_data, y = y1)

x2 <- rnorm(n, 0, 0.5)
y2 <- runif(n, -(1-abs(x2)), 1-abs(x2))
df2 <- data.frame(x = x2, y = y2)

y3 <- 2*uni_data^2 + runif(n, -1, 1)
df3 <- data.frame(x = uni_data, y = y3)

y4 <- (uni_data^2 + runif(n, 0, 1/2)) * sample(seq(-1, 1, 2), n, replace = TRUE)
df4 <- data.frame(x = uni_data, y = y4)

y5 <- cos(uni_data*pi) + rnorm(n, 0, 1/8)
x5 <- sin(uni_data*pi) + rnorm(n, 0, 1/8)
df5 <- data.frame(x = x5, y = y5)

xy61 <- rmvnorm(n/4, c( 3,  3))
xy62 <- rmvnorm(n/4, c(-3,  3))
xy63 <- rmvnorm(n/4, c(-3, -3))
xy64 <- rmvnorm(n/4, c( 3, -3))
xy6 <- rbind(xy61, xy62, xy63, xy64)
df6 <- data.frame(x = xy6[,1], y = xy6[,2])

# PLOTS ------------------------------------------------------------------------

make_plot <- function(df, xlimit = NULL) {
  p <- ggplot(df, aes(x = x, y = y)) +
    geom_point(shape = 1, size = 2, stroke = 1) +
    theme_bw() +
    theme(axis.title = element_blank())
  if (!is.null(xlimit)) {
    p <- p + xlim(xlimit[1], xlimit[2])
  }
  p
}

p1 <- make_plot(df1)
p2 <- make_plot(df2, xlimit = c(-1, 1))
p3 <- make_plot(df3)
p4 <- make_plot(df4)
p5 <- make_plot(df5)
p6 <- make_plot(df6)

p <- grid.arrange(grobs = list(p1, p2, p3, p4, p5, p6), nrow = 1, ncol = 6)
ggsave(filename = "../figure/correlation_plot.png", plot = p, width = 12, height = 2)