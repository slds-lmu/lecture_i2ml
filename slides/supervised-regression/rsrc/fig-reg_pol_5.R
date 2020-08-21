 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


set.seed(600000)
.h = function(x) 0.6 + 0.4 * sin(2 * pi * x)
h = function(x) .h(x) + .1 * arima.sim(list(ar = .7, ma = 0), length(x)) + rnorm(length(x), sd = .5)

x = seq(0.4, 2, length = 31L)
y = h(x)

pdf("../figure/reg_pol_5.pdf", width= 8, height = 6.5)
line.palette = viridisLite::viridis(4)
baseplot = function() {
  # par(mar = c(2, 2, 1, 1))
  plot(x, y, pch = 19L, ylim = c(-1, 2))
}

p1 = lm(y ~ poly(x, 1, raw = TRUE))
p3 = lm(y ~ poly(x, 5, raw = TRUE))
p10 = lm(y ~ poly(x, 25, raw = TRUE))
mods = list(p1, p3, p10)
x.plot = seq(min(x), max(x), length = 500L)
layout((1:2))
baseplot()
title(main = "Training Data")
for (i in 2:3) {
  lines(x.plot, predict(mods[[i]], newdata = data.frame(x = x.plot)),
        col = line.palette[i], lwd = 2L)
}

plot(x.plot,
     
     
     .h(x.plot) + .3 * rnorm(length(x.plot)), pch = 19, col = rgb(0,0,0,.5),
     
     cex = .8,
     xlab = "x", ylab = "y",
     ylim = c(-1, 2))
title(main = "Test Data")
for (i in 2:3){
  lines(x.plot, predict(mods[[i]], newdata = data.frame(x = x.plot)),
        col = line.palette[i], lwd = 2L)
}
ggsave("../figure/reg_pol_5.pdf", width = 8, height = 6.5)
dev.off()

