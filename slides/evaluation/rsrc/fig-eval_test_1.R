 
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

scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }

## data for example
.h = function(x) 0.5 + 0.4 * sin(2 * pi * x)
h = function(x) .h(x) + rnorm(length(x), mean = 0, sd = 0.05)

x.all = seq(0, 1, length = 26L)
ind = seq(1, length(x.all), by = 2)
mydf = data.frame(x = x.all, y = h(x.all))

## function
ggTrainTestPlot = function (data, truth.fun, truth.min, truth.max, test.plot, 
                            test.ind, degrees = NULL)
{
  out = list()
  train.test.errors = list()
  
  x.truth = seq(from = truth.min, to = truth.max, length.out = 200)
  line.data = data.frame(x = x.truth, y = truth.fun(x.truth))
  
  temp = rep("Train set", nrow(data))
  temp[test.ind] = "Test set"
  data$dummy = factor(temp, levels = c("Train set", "Test set"))
  
  gg = ggplot() + 
    geom_line(data = line.data, aes(x = x, y = y, size = "True function"), 
              linetype = "longdash", colour = "grey") +
    scale_size_manual("", values = 0.5, 
                      guide = guide_legend(override.aes = list(colour = "grey"))) +
    xlab("") + ylab("")
  
  if (test.plot) {
    gg = gg + geom_point(data = data, aes(x = x, y = y, shape = dummy)) +
      scale_shape_manual(values = c(19, 1), guide = guide_legend(
        title = "",
        override.aes = list(
          size = 2
        )))
  } else {
    gg = gg + geom_point(data = data[-test.ind, ], aes(x = x, y = y, shape = dummy)) +
      scale_shape_manual(values = c(19, 1), guide = guide_legend(
        title = "",
        override.aes = list(
          size = 2
        )))
  }
  if (! is.null(degrees[1])) {
    
    df.poly = data.frame(x = numeric(0L), y = numeric(0L), degree = integer(0L))
    
    for (d in degrees) {
      
      temp.mod = lm(y ~ poly(x, degree = d), data = data[-test.ind, ])
      df.poly = rbind(df.poly, data.frame(
        x = x.truth, y = predict(temp.mod, newdata = data.frame(x = x.truth)), degree = d
      ))
      
      train.test.errors[[paste0("degree", d)]] = c(train = mean((data$y[-test.ind] - predict(temp.mod))^2), 
                                                   test = mean((data$y[test.ind] - predict(temp.mod, newdata = data.frame(x = data$x[test.ind])))^2))
    }
    
    df.poly$degree = as.factor(df.poly$degree)
    gg = gg + geom_line(data = df.poly, aes(x = x, y = y, color = degree))
    
    out[["train.test"]] = train.test.errors
  }
  
  out[["plot"]] = gg + labs(x = "x", y = "y") 
  
  return (out)
}

library(plyr)
library(kernlab)
set.seed(600000)
pdf("../figure/eval_test_1.pdf", width = 6, height = 3)
ggTrainTestPlot(data = mydf, truth.fun = .h, truth.min = 0, truth.max = 1, 
                test.plot = TRUE, test.ind = ind)[["plot"]] + ylim(0, 1)

ggsave("../figure/eval_test_1.pdf", width = 6, height = 3)
dev.off()

