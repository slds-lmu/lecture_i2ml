# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

source("plot_train_test.R")

# DATA -------------------------------------------------------------------------

set.seed(123)

.h = function(x) 0.5 + 0.4 * sin(2 * pi * x)
h = function(x) .h(x) + rnorm(length(x), mean = 0, sd = 0.05)

x.all = seq(0, 1, length = 26L)
ind = seq(1, length(x.all), by = 2)
mydf = data.frame(x = x.all, y = h(x.all))

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_test_1.pdf", width = 6, height = 3)

out = ggTrainTestPlot(data = mydf,
                      truth.fun = .h,
                      truth.min = 0,
                      truth.max = 1,
                      test.plot = TRUE,test.ind = ind)
out [["plot"]] + 
  ylim(0, 1)

ggsave("../figure/eval_test_1.pdf", width = 6, height = 3)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_test_2.pdf", width = 6, height = 3)

out = ggTrainTestPlot(data = mydf, 
                      truth.fun = .h, 
                      truth.min = 0, 
                      truth.max = 1,
                      test.plot = TRUE, 
                      test.ind = ind, 
                      degree = c(1, 3, 9))
out[["plot"]] + 
  ylim(0, 1) + 
  scale_color_viridis_d(end = .9)

ggsave("../figure/eval_test_2.pdf", width = 6, height = 3)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/eval_test_3.pdf", width = 8, height = 4)

degrees = 1:9

errors = ggTrainTestPlot(data = mydf, 
                         truth.fun = .h, 
                         truth.min = 0,
                         truth.max = 1, 
                         test.plot = TRUE, 
                         test.ind = ind,
                         degree = degrees)[["train.test"]]

par(mar = c(4, 4, 1, 1))

plot(1, 
     type = "n", 
     xlim = c(1, 10), 
     ylim = c(0, 0.07),
     ylab = "MSE", 
     xlab = "degree of polynomial")

lines(degrees, sapply(errors, function(x) x["train"]), type = "b")
lines(degrees, sapply(errors, function(x) x["test"]), type = "b", col = "gray")

legend("topright", c("training error", "test error"), 
       lty = 1L,
       col = c("black", "gray"))

text(3.75, 0.05, "Underfitting,\n\nHigh Bias,\nLow Variance", bg = "white")
arrows(4.75, 0.05, 2.75, 0.05, code = 2L, lty = 2L, length = 0.1)

text(6.5, 0.05, "Overfitting,\n\nLow Bias,\nHigh Variance", bg = "white")
arrows(7.5, 0.05, 5.5, 0.05, code = 1, lty = 2, length = 0.1)

ggsave("../figure/eval_test_3.pdf", width = 8, height = 4)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/eval_train_1.pdf", width = 5.5, height = 2)

out = ggTrainTestPlot(data = mydf, 
                      truth.fun = .h, 
                      truth.min = 0, 
                      truth.max = 1,
                      test.plot = FALSE, 
                      test.ind = ind)
out[["plot"]] + ylim(0, 1)

ggsave("../figure/eval_train_1.pdf", width = 5.5, height = 2)
dev.off()

# PLOT 5 -----------------------------------------------------------------------

pdf("../figure/eval_train_2.pdf", width = 5, height = 3)

out = ggTrainTestPlot(data = mydf, 
                      truth.fun = .h, 
                      truth.min = 0, 
                      truth.max = 1,
                      test.plot = FALSE, 
                      test.ind = ind, degree = c(1, 3, 9))
out[["plot"]] + 
  ylim(0, 1) + 
  theme(legend.position = "top") + 
  scale_color_viridis_d(end = .9)

ggsave("../figure/eval_train_2.pdf", width = 5, height = 3)
dev.off()