 
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
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

library(plyr)
library(kernlab)
set.seed(600000)
pdf("../figure/eval_ofit_3.pdf", width = 8, height = 3)
par(mar = c(2.1, 2.1, 0, 0))
x <- seq(0, 1, length.out = 20)
y1 <- c(1 - x[1:4], 1.5 - 4 * x[5:6], 0.5 - 0.8 * x[7:10], 0.15 - 0.1 * x[11:20])
X <- seq(0, 1, length.out = 1000)
Y1 <- predict(smooth.spline(x, y1, df = 10), X)$y
plot(X, Y1, type = "l", axes = FALSE, xlab = "Complexity", ylab = "Error")
mtext("Complexity", side = 1, line = 1)
mtext("Error", side = 2, line = 1)
Y2 <- 0.5 * X
lines(X, Y1 + Y2)
abline(v = 0.42, lty = 2)
text(0.4, 0.93, "Underfitting", pos = 2)
text(0.44, 0.93, "Overfitting", pos = 4)
arrows(0.4, 0.98, 0.2, 0.98, length = 0.1)
arrows(0.44, 0.98, 0.64, 0.98, length = 0.1)
box()
text(0.85, 0.13, "Apparent error")
text(0.85, 0.55, "Actual error")

ggsave("../figure/eval_ofit_3.pdf", width = 8, height = 3)
dev.off()

