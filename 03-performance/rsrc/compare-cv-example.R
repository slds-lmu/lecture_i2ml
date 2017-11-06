library(OpenML)
library(mlr)
library(parallelMap)
library(data.table)
library(reshape2)
library(ggplot2)
library(dplyr)
library(parallel)
library(BBmisc)
library(gridExtra)

# Function to get the true error + the error for different CV methods
estimate = function(learner, task, measures = mmce, stratify = FALSE,
  split = 0.01, cv.iters = seq(2, 10, by = 2)) {
  # holdout for nested resampling, use always stratify = TRUE
  rdesc = makeResampleDesc("Holdout", split = split, stratify = TRUE)
  rin = makeResampleInstance(rdesc, task)

  true.err = resample(learner, task, rin, measures = measures)

  # subset Task
  d1.task = subsetTask(task, subset = rin$train.inds[[1]])

  ret = as.data.frame(setNames(lapply(cv.iters, function(iters) {
    crossval(learner, d1.task, iters = iters, measures = measures, stratify = stratify)$aggr
  }), paste0("cv", cv.iters)))
  ret$true = true.err$aggr

  if (!stratify) {
    loodesc = makeResampleDesc("LOO")
    looerr = resample(learner, d1.task, loodesc, measures = measures)
    ret$loo = looerr$aggr
  }
  return(ret)
}
setOMLConfig(arff.reader = "RWeka", server = "https://www.openml.org/api/v1")

# select imbalanced data set manually
imbalanced.data = getOMLDataSet(994)
imbalanced.task = convertOMLDataSetToMlr(imbalanced.data)

# Specify learner
lrn = makeLearner("classif.logreg")

# ugly parallelization for windows
replicates = 100
parallelStartSocket(25)
parallelExport("estimate")
parallelLibrary("mlr")
clusterSetRNGStream(iseed = 123)
# stratified vs. not stratified
res.imbalanced = parallelMap(function(i, ...) estimate(...), seq_len(replicates),
  more.args = list(learner = lrn, task = imbalanced.task, measures = mmce, stratify = TRUE, split = 0.1))
res.imbalanced2 = parallelMap(function(i, ...) estimate(...), seq_len(replicates),
  more.args = list(learner = lrn, task = imbalanced.task, measures = mmce, stratify = FALSE, split = 0.1))
parallelStop()
save(res.imbalanced, res.imbalanced2, file = "compare-cv-example.RData")

# plot results
summarizeResults = function(res) {
  # collect results
  fin.res = as.data.frame(rbindlist(res))
  # Calculate the difference between the resampling error and the true error
  differences = fin.res[,colnames(fin.res) %nin% "true"] - fin.res[,"true"]
  # Calculate the mean of the differences
  diff.means = apply(differences, 2, mean)
  # Calculate the standard deviation of the errors (not the diff)(
  error.sd = apply(fin.res[,colnames(fin.res) %nin% "true"], 2, var)
  # put results in a df that ggplot can handle
  df = data.frame(resampling.method = factor(names(diff.means), names(diff.means)),
    mean = diff.means, sd = error.sd)
  return(df)
}

# aggregate results in a data frame for ggplot
df.imbalanced = summarizeResults(res.imbalanced)
df.imbalanced2 = summarizeResults(res.imbalanced2)
df = rbind(cbind(df.imbalanced, stratified = TRUE), cbind(df.imbalanced2, stratified = FALSE))
df$stratified = as.factor(df$stratified)

jpeg("compare-cv-example.jpg", width = 800, height = 400)
p1 = ggplot(data = df, aes(x = resampling.method, y = mean, colour = stratified)) +
  geom_point(size = 2, position = position_dodge(width = 0.3)) +
  #geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.3, size = 1, position = "dodge") +
  expand_limits(y = 0) +
  labs(x = "Resampling strategies",  y = "Bias")
p2 = ggplot(data = df, aes(x = resampling.method, y = sd, colour = stratified)) +
  geom_point(size = 2, position = position_dodge(width = 0.3)) +
  #geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.3, size = 1, position = "dodge") +
  expand_limits(y = 0) +
  labs(x = "Resampling strategies",  y = "Standard Deviation")
grid.arrange(p1, p2, ncol = 2)
dev.off()
