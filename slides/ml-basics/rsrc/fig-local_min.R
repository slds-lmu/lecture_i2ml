library(ggplot2)

x <- seq(-2, 2, 0.001)
y <- function(x) 3 + 4/3*x^1 + -11/4*x^2 + -1/3*x^3 + 3/4*x^4

da <- c(4/3, -22/4, -1, 3)
dda <- c(-22/4, -2, 9)
ddy <-function(x) dda %*% sapply(0:2, function(i) x^i)
stat_points <- Re(polyroot(da))
sp_type <- sapply(stat_points, function(sa) ddy(sa))
min_points <- stat_points[sp_type > 0]

min_df <- data.frame(x = min_points, y=y(min_points), minimum=c("global", "local"))

ggplot(data.frame(x=x, y=y(x)), aes(x=x, y=y)) +
  geom_line() +
  geom_point(data = min_df, aes(x=x, y=y, colour=minimum)) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank()) +
  ylab(expression(R[emp](theta))) + xlab(expression(theta))
