
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
pal_2 <- viridisLite::viridis(2, end = .9)

# create learning_curve.RData (used in resampling)

# nice report http://www.ritchieng.com/machinelearning-learning-curve/ and
# http://scikit-learn.org/stable/modules/learning_curve.html#learning-curve
# http://www.ritchieng.com/applying-machine-learning/

library(OpenML)
library(data.table)
library(parallelMap)
library(parallel)
setOMLConfig(server = "https://www.openml.org/api/v1", apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f", arff.reader="farff")

#' Does subsampling with 'split' as split rate and 'iters' as number of subsampling iterations
myLearningCurveSplit = function(learner, task, measure, iters = 100, split = 1) {
  rdesc = makeResampleDesc(method = "Subsample",
                           iters = iters, split = split, predict = "both", stratify = TRUE)
  res = resample(learner = learner, task = task, resampling = rdesc,
                 measures = list(
                   test.mean = setAggregation(measure, test.mean),
                   train.mean = setAggregation(measure, train.mean),
                   test.sd = setAggregation(measure, test.sd),
                   train.sd = setAggregation(measure, train.sd)
                 ), show.info = FALSE)
  return(as.data.frame(c(percentage = split, as.list(res$aggr))))
}

#' Compute learning curve for many different split rates
myLearningCurve = function(learner, task, measure, iters = 100,
                           perc = seq(0.1, 0.9, by = 0.1)) {
  # iterate over all training set percentages from 'perc'
  res = rbindlist(lapply(perc, function(x) {
    myLearningCurveSplit(learner = learner,
                         measure = measure, task = task, split = x, iters = iters)
  }))
  # make data frame
  melt(res, id.vars = "percentage", variable.name = "measure",
       value.name = c("mmce", "sd"), measure = patterns("mean", "sd"))
}

set.seed(123)
task = convertOMLDataSetToMlr(getOMLDataSet(847))
lrn.ranger = makeLearner("classif.ranger", num.threads = 1, num.trees = 10)
lrn.rpart = makeLearner("classif.rpart", cp = 0.0025)

parallelStartSocket(20)
clusterSetRNGStream(iseed = 123)
res.ranger = myLearningCurve(learner = lrn.ranger, measure = mmce, task = task, iters = 100)
res.rpart = myLearningCurve(learner = lrn.rpart, measure = mmce, task = task, iters = 100)
res.rpart.small = myLearningCurve(learner = lrn.rpart, measure = mmce, task = task, iters = 20)
parallelStop()

save(res.ranger, res.rpart, res.rpart.small, file = "learning_curve.RData")

pdf("../figure/eval_learn_curves_3.pdf", width = 5, height = 2)
opt = res.rpart
opt$mmce = opt$mmce - mean(opt$mmce) + 0.08

eline = 0.08
xlab_lc = "Number of training instances"

p = ggplot(data = res.rpart, aes(x = percentage, y = mmce))
p + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, eline - 0.003, label = "desired error", vjust = 1, hjust = 0)) +
  geom_errorbar(aes(ymin = mmce - sd, ymax = mmce + sd, colour = measure), width = 0.025) +
  geom_line(aes(colour = measure)) +
  geom_point(aes(colour = measure)) +
  ylim(0, 0.2) +
  ylab(expression(widehat(GE))) +
  xlab(xlab_lc) +
  scale_color_discrete(name = NULL, labels = c("1" = expression(D[test]), 
                                               "2" = expression(D[train]))) +
  theme_minimal() 
print(p)
ggsave("../figure/eval_learn_curves_3.pdf", width = 5, height = 2)
dev.off()


pdf("../figure/eval_learn_curves_4.pdf", width = 5, height = 2)
p1 = ggplot(data = res.ranger, aes(x = percentage, y = mmce))
p1 + geom_hline((aes(yintercept = eline))) +
  geom_text(aes(0.1, eline - 0.003, label = "desired error", vjust = 1, hjust = 0)) +
  geom_errorbar(aes(ymin = mmce - sd, ymax = mmce + sd, colour = measure), width = 0.025) +
  geom_line(aes(colour = measure)) +
  geom_point(aes(colour = measure)) +
  ylim(0, 0.2) +
  ylab(expression(widehat(GE))) +
  xlab(xlab_lc) +
  scale_color_discrete(name = NULL, labels = c("1" = expression(D[test]), 
                                               "2" = expression(D[train]))) +
  theme_minimal()

print(p1)
ggsave("../figure/eval_learn_curves_4.pdf", width = 5, height = 2)
dev.off()



