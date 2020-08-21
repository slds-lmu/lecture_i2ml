 
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
library(rpart)
library(rpart.plot)
library(randomForest)
library(rattle)
library(smoof)
library(kableExtra)
library(kknn)
library(e1071)
library(rattle)
library(reshape2)

library(plyr)
library(kernlab)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


mySimul = function(task.size, cv.iters, tune.iters) {
  
  # simulates stupid task of given size with 0,1 labels with equal prob
  makeMyTask = function(n) {
    y = sample(c(0,1), size = n, replace = TRUE)
    d = data.frame(x = 1, y = as.factor(y))
    makeClassifTask(data = d, target = "y")
  }
  
  task = makeMyTask(task.size)
  # "tuning" featureless learner by resampling it very often
  lrn = makeLearner("classif.featureless", method = "sample-prior")
  rin = makeResampleInstance("CV", iters = cv.iters, task = task)
  replicate(tune.iters, resample(lrn, task, rin, show.info = FALSE)$aggr)
}

set.seed(123)
tune.iters = 100L
cv.iters = 2L
task.sizes = c(100, 200, 500)
reps = 50
res1 = array(dim = c(length(task.sizes), tune.iters, reps), 
             dimnames = list(task.size = task.sizes, iter = 1:tune.iters, rep = 1:reps))
res2 = res1

for (j in 1:reps) { 
  for (i in seq_along(task.sizes)) {
    task.size = task.sizes[i]
    messagef("rep=%i; task size=%i", j, task.size)
    v = mySimul(task.size, cv.iters = cv.iters, tune.iters = tune.iters)  
    res1[i, , j] = v
    res2[i, , j] = cummin(v)
  }
}
res2.mean = apply(res2, 1:2, mean)
save2(file = "overtuning-example.RData", res1 = res1, res2 = res2, res2.mean = res2.mean)


pdf("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)

ggd = BBmisc::load2("overtuning-example.RData", "res2.mean")
ggd = reshape2::melt(ggd, measure.vars = colnames(res2), value.name = "tuneperf");
colnames(ggd)[1:2] = c("data.size", "iter")
ggd = BBmisc::sortByCol(ggd, c("data.size", "iter"))
ggd$data.size = as.factor(ggd$data.size)


pl = ggplot(ggd, aes(x = iter, y = tuneperf, col = data.size))
pl =  pl + geom_line() + ylab("Tuning Error") + xlab("Iteration") + labs(colour = "Data Size")
print(pl)
ggsave("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)
dev.off()

