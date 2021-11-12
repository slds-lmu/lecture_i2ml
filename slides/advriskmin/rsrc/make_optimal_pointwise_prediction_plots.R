
library(ggplot2)

df = data.frame(x = runif(50, -2.5, 2.5), type = FALSE)
df = rbind(df, data.frame(x = rep(0, 10), type = TRUE))

df$y = 2 * df$x + rnorm(60)

lm_fit = lm(data = df, y ~ x)

k <- 5
sigma <- sigma(lm_fit)
ab <- coef(lm_fit); a <- ab[1]; b <- ab[2]

x <- seq(-k*sigma, k*sigma, length.out = 50)
y <- dnorm(x, 0, sigma)/dnorm(0, 0, sigma) * 1

x0 <- 0
y0 <- a+b*x0
path1 <- data.frame(x = y + x0, y = x + y0)
segment1 <- data.frame(x = x0, y = y0 - k*sigma, xend = x0, yend = y0 + k*sigma)

p = ggplot() + geom_point(data = df[!df$type, ], aes(x = x, y = y), alpha = 0.2, size = 3)
p = p + geom_point(data = df[df$type, ], aes(x = x, y = y), size = 3) + ggtitle("Fix one x")
p = p + geom_path(data = path1, aes(x = x, y = y), color = "orange") 
p = p + geom_segment(aes(x=x,y=y,xend=xend,yend=yend), data = segment1, lty = 2) 
p

ggsave("../figure/optimal_pointwise_1.png", width = 4, height = 3)


p = p + geom_point(aes(x = 0, y = 0), colour = "orange", size = 4, shape = 17)
p = p + ggtitle("Find best prediction and repeat for all x")
p

ggsave("../figure/optimal_pointwise_2.png", width = 4, height = 3)
