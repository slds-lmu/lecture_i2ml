set.seed(1)

x = runif(50, -2, 2)
df = data.frame(x = x, y = 1 / 2 * x + rnorm(50, sd = 0.5))
# manually add an outlier
df = rbind(df, data.frame(x = -1.8, y = 2))
df$mean = df$x
df$median = rq(y ~ x, data = df)$fitted.values
df$quantile.04 = rq(y ~ x, data = df, tau = 0.4)$fitted.values

df.fitted = reshape2::melt(df[, -2], id.vars = "x")

p = ggplot() + geom_point(data = df, aes(x = x, y = y))
p = p + geom_line(data = df.fitted, aes(x = x, y = value, lty = variable, colour = variable))
p = p + theme(legend.position = "none")
p

ggsave(filename = "example_intro.png", path = "../figure", width = 200, height = 100, units = "mm")
