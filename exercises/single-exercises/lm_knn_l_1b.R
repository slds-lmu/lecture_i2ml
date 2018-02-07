library(ggplot2)
library(caret)

N <- 200 # number of points per class
D <- 2 # dimensionality
K <- 4 # number of classes
data <- data.frame() # data matrix (each row = single example)


set.seed(308)

for (j in (1:K)){
  r <- seq(0.05,1,length.out = N) # radius
  t <- seq((j-1)*4.7,j*4.7, length.out = N) + rnorm(N, sd = 0.3) # theta
  Xtemp <- data.frame(x =r*sin(t) , y = r*cos(t)) 
  data <- rbind(data, Xtemp)
}

data$label <- rnorm(N*K)*10

ggplot(data,aes(x=x,y=y,color=label)) + geom_point(size=1)

abalone.task <- makeRegrTask(data = data, target = "label")

n = getTaskSize(abalone.task)
train.set = seq(1, n, by = 2)
test.set = seq(2, n, by = 2)
lrn.lm <- makeLearner("regr.lm")
mod.lm = train(lrn.lm, abalone.task, subset = train.set)
task.pred.lm = predict(mod.lm, task = abalone.task, subset = test.set)
task.pred.lm
performance(task.pred.lm)

plotLearnerPrediction(lrn.lm, task = abalone.task, features = c("x", "y"), cv = 0)

lrn.kknn <- makeLearner("regr.kknn")
mod.kknn = train(lrn.kknn, abalone.task, subset = train.set)
task.pred.kknn = predict(mod.kknn, task = abalone.task, subset = test.set)
task.pred.kknn

plotLearnerPrediction(lrn.kknn, task = abalone.task, features = c("x", "y"), cv = 0)
performance(task.pred.kknn)
#listMeasures("regr")
