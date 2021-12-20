# ------------------------------------------------------------------------------
# FIG: KNN ERROR
# ------------------------------------------------------------------------------

library(ggplot2)
library(data.table)
library(mvtnorm)
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

a5 <- 2

d6 <- 2
a6 <- rep(2 / sqrt(d6), d6)
x6 <- seq(-6, 6, length.out = 100)
datagrid_bayes6 <- expand.grid(x1 = x6, x2 = x6)

datagrid_bayes6$`1` <- dmvnorm(datagrid_bayes6[, 1:d6], mean = - a6) -
  dmvnorm(datagrid_bayes6[, 1:d6], mean = a6)
datagrid_bayes6$`2` <- dmvnorm(datagrid_bayes6[, 1:d6], mean = a6) -
  dmvnorm(datagrid_bayes6[, 1:d6], mean = - a6)

idx6_1 <- (datagrid_bayes6$x1 >= 0 & datagrid_bayes6$x2 >= 0) |
  (datagrid_bayes6$x1 * datagrid_bayes6$x2 <= 0 & -datagrid_bayes6$x1 <= datagrid_bayes6$x2)

idx6_2 <- (datagrid_bayes6$x1 < 0 & datagrid_bayes6$x2 < 0) |
  (datagrid_bayes6$x1 * datagrid_bayes6$x2 < 0 & -datagrid_bayes6$x1 > datagrid_bayes6$x2)

datagrid_bayes6$density <- 0.
datagrid_bayes6[idx6_1, "density"] <- dmvnorm(datagrid_bayes6[idx6_1, 1:d6], mean = - a6)
datagrid_bayes6[idx6_2, "density"] <- dmvnorm(datagrid_bayes6[idx6_2, 1:d6], mean = a6)

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

# Optimal Bayes classifier 1d
p3 <- p1 + geom_rect(data = data.frame(xmin = c(0, -Inf),
                                       xmax = c(Inf, 0),
                                       ymin = c(-Inf, -Inf),
                                       ymax = c(Inf, Inf),
                                       group = as.factor(c(1, 2))),
                     mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=group),
                     color="black",
                     alpha=0.2)

# Optimal Bayes classifier 2d
p4 <- p2 + geom_abline(slope = -1, intercept = 0) +
  geom_polygon(data = data.frame(x = c(-Inf, Inf, -Inf), y = c(Inf, -Inf, -Inf)),
               aes(x,y), fill=3, alpha=0.2) +
  geom_polygon(data = data.frame(x = c(-Inf, Inf, Inf), y = c(Inf, Inf, -Inf)),
               aes(x,y), fill=2, alpha=0.2)

# Bayes Error 1d
p5 <- p1 +
  stat_function(data = data.frame(x = c(1, 2)), aes(x), fun = function(x) dnorm(x, mean = -a5 ), geom = "area", alpha = 0.5, xlim = c(0, 5)) +
  stat_function(data = data.frame(x = c(1, 2)), aes(x), fun = function(x) dnorm(x, mean = a5 ), geom = "area", alpha = 0.5, xlim = c(- 5, 0)) +
  ggtitle("Bayes error (p = 1)")

# Bayes Error 2d

p6 <- ggplot() +
  theme_bw() +
  geom_raster(data=datagrid_bayes6, aes(x = x1, y = x2, fill = density)) +
  geom_contour(data = df2, aes(x = x1, y = x2, z = value, colour = variable)) +
  coord_fixed(xlim = c(- 5, 5), ylim = c(- 5, 5), ratio = 1) +
  scale_fill_gradient(low = "white", high = "black") +
  geom_point(data = samples2, aes(x = x1, y = x2, colour = class), size = 2) +
  ggtitle(paste0("Bayes error (p = ", d6,")")) +
  labs(colour = "Class")

p <- grid.arrange(p3, p4, p5, p6, nrow = 2)

ggsave(filename = "../figure/knn_error_plot.png", plot = p, width = 8, height = 7)