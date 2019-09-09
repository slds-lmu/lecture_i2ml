library(reshape)
library(mlr)
library(mlbench)

data(Ozone)
df = Ozone[complete.cases(Ozone), ] # we just keep complete cases (this is stupid, but this is just for demonstration)

task = makeRegrTask(data = df, target = "V4")
lrn = makeDummyFeaturesWrapper(makeLearner("regr.lm"))
rin = makeResampleDesc("RepCV", folds = 10, predict = "both")

task.sub = subsetTask(task, subset = 1:50)
r = resample(lrn, task.sub, rin)

res = data.frame("train error" = mean(r$measures.train$mse), "test.error" = mean(r$measures.test$mse))

res = data.table(mse.train = r$measures.train$mse, mse.test = r$measures.test$mse, nobs = 50)

for (i in seq(60, nrow(df), by = 10)) {
    task.sub2 = subsetTask(task, subset = 1:i)
    lrn = makeDummyFeaturesWrapper(makeLearner("regr.lm"))
    r = resample(lrn, task.sub2, rin)
    res = rbind(res, data.table(mse.train = r$measures.train$mse, mse.test = r$measures.test$mse, nobs = rep(i, 10)))
}

df_incdata = melt(res, id = "nobs")


# full model results 
vars = c("V7", "V9", "V8", "V10", "V11", "V12", "V1", "V2", "V3", "V4", "V5", "V6")

task = makeRegrTask(data = df, target = "V4")

lrn = makeLearner("regr.featureless")
task.sub = subsetTask(task, subset = 1:50)
rin = makeResampleDesc("RepCV", folds = 10, predict = "both")
r = resample(lrn, task.sub, rin)

dfp = melt(data.table(mse.train = r$measures.train$mse, mse.test = r$measures.test$mse, type = 0), id = "type")

lrn = makeDummyFeaturesWrapper(makeLearner("regr.lm"))

for (i in 1:12) {
  task.sub = subsetTask(task, subset = 1:50, features = vars[1:i])
  r = resample(lrn, task.sub, rin)
  dfp = rbind(dfp, melt(data.table(mse.train = r$measures.train$mse, mse.test = r$measures.test$mse, type = i), id = "type"))
}

dfp$variable = as.factor(dfp$variable)
df_incfeatures = dfp[, .(mean.mse = mean(value)), by = c("type", "variable")]
df_incfeatures$type = as.numeric(df_incfeatures$type)

save(df_incdata, df_incfeatures, file = "data/ozone_example.RData")