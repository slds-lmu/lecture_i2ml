# ------------------------------------------------------------------------------
# FIG: KNN DENSITY
# ------------------------------------------------------------------------------
library(mvtnorm)
library(data.table)
library(ggplot2)
library(gridExtra)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

theme_set(theme_bw())
# DATA -------------------------------------------------------------------------

d1 <- 1
a1 <- rep(2 / sqrt(d1), d1)
x1 <- seq(-6, 6, length.out = 500)

datagrid1 <- data.frame(x = x1)
datagrid1$`1` <- dnorm(datagrid1$x, mean = a1)
datagrid1$`2` <- dnorm(datagrid1$x, mean = - a1)
df1 <- melt(datagrid1, id.vars = "x")

samples1 <- data.frame(`1` = rnorm(10, mean = a1), `2` = rnorm(10, mean = -a1))
samplesr1 <- melt(samples1)
levels(samplesr1$variable) <- c(1, 2)

# 2d case
d2 <- 2
a2 <- rep(2 / sqrt(d2), d2)
x2 <- seq(-6, 6, length.out = 100)
datagrid2 <- expand.grid(x1 = x2, x2 = x2)
datagrid2$`1` <- dmvnorm(datagrid2[, 1:d2], mean = a2)
datagrid2$`2` <- dmvnorm(datagrid2[, 1:d2], mean = - a2)
df2 <- melt(datagrid2, id.vars = c("x1", "x2"))
datagrid2$density <- datagrid2$`1` + datagrid2$`2`

samples2 <- data.frame(class = rep(1:2, each = 10))
samples2 <- cbind(samples2, t(vapply(samples2$class, function(x) rmvnorm(1, mean = rep((- 1)^(x + 1), 2)), numeric(2))))
samples2$class <- factor(samples2$class)
names(samples2)[2:3] <- c("x1", "x2")

# PLOTS ------------------------------------------------------------------------

p1 <- ggplot() +
  geom_line(data = df1, aes(x = x, y = value, colour = variable)) +
  geom_point(data = samplesr1, aes(x = value, y = 0, colour = variable)) +
  xlab("x") + ylab("density") +
  labs(colour = "class") +
  ggtitle(paste("Dimension p =", d1)) + theme(legend.position = "none") +
  coord_fixed(xlim = c(- 5, 5), ylim = c(0, 0.5), ratio = 20)



p2 <- ggplot() +
  geom_raster(data = datagrid2, aes(x = x1, y = x2, fill = density)) +
  geom_contour(data = df2, aes(x = x1, y = x2, z = value, colour = variable)) +
  coord_fixed(xlim = c(- 4, 4), ylim = c(- 4, 4), ratio = 1) +
  scale_fill_gradient(low = "white", high = "darkgrey") +
  geom_point(data = samples2, aes(x = x1, y = x2, colour = class), size = 2) +
  ggtitle(paste("Dimension p =", d2)) +
  labs(colour = "Class")


p <- grid.arrange(p1, p2, nrow = 1)

ggsave(filename = "../figure/knn_density_plot.png", plot = p, width = 8, height = 4)