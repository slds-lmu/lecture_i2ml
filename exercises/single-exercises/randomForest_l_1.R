library(randomForest)
library(ElemStatLearn)
library(BBmisc)

print(summary(spam))


# Plots variable importance (type 1 and 2 ) of random forest.
# Also orders the features by importance, fits RF only with 
# with the first k features and plots the RF OOB error
# next to the variable importance.
#
# @param target [character(1)]
#   Name of target variable in data.
# @param data [data.frame]
#   Data set for fitting.
# @param max.vars [integer(1)]
#   Maximal number of features displayed in importance plot
#   and maximal number for which OOB error is computed.
# @param err.lines [numeric]
#   Just some vertical lines in the OOB plots
#   so we can see some errors better. 
# @param ...
#   Passed on to randomForest.
inspectFeatures = function(target, data, max.vars = 30L, 
  err.lines = c(0.05, 0.075, 0.1), ...) {
  
  form = reformulate(".", target)
  p = ncol(data) - 1
  opar = par(no.readonly=TRUE)
  par(mfrow = c(1, 4))
  
  # do it for both types of importance
  for (type in 1:2) {
    # model on full data + sorted importance
    model = randomForest(form, data = data, 
      importance =  TRUE, ...)
    imp = importance(model, type = type)
    imp = setNames(imp[,1], rownames(imp))
    imp = sort(imp, decreasing = TRUE)
    # oob errs for first k features, according to importance  
    errs = setNames(1:max.vars, names(imp)[1:max.vars])
    
    for (k in 1:max.vars) {
      # select first k most important features
      feats = names(imp)[1:k]
      data2 = data[, c(feats, target)]
      # fit RF and get OOB error
      model2 = randomForest(form, data = data2, ...)
      errs[k] = model2$err.rate[model2$ntree, "OOB"]
      messagef("Type = %i, Iter = %i; Feat = %s, Error = %.3f", 
        type, k, feats[k], errs[k])
    }
    # plot usual varimp + our OOB error
    varImpPlot(model, type = type, n.var = max.vars)
    barplot(rev(errs), horiz = TRUE, xlab = "RF OOB Err")
    abline(v = err.lines)
    abline(v = model$err.rate[model$ntree, "OOB"], col = "red")
  }
  par(opar)
}

# reduce nr of trees a bit so we are faster
inspectFeatures("spam", spam, max.vars = 20, ntree = 200)

# we see both importance measures differ 
# slightly in the ordering of features.
# we can probably construct a reduced model
# with about 5 - 10 features
# where the error is around 5%-8%.


library(mlr)

task = makeClassifTask(data=spam, target="spam")
lrn = makeLearner("classif.randomForest")
mod = train(lrn, task)

plot(mod$learner.model$err.rate[ ,"OOB"], type="l", xlab="ntree", ylab="OOB", main="")

compare = function(nt, iters=10) {
  
  task = makeClassifTask(data=spam, target="spam")
  lrn = makeLearner("classif.randomForest", ntree=max(nt))
  mod = train(lrn, task)
  
  rdesc = makeResampleDesc("CV", iters=iters)
  r.rp = resample("classif.rpart", task, rdesc)
  
  lrn = lapply(nt, function(i) makeLearner("classif.randomForest", ntree=i))
  r.rf = lapply(lrn, function(x) resample(x, task, rdesc))
  err.rf = unlist(sapply(r.rf, "[", "aggr"))
  
  res = data.frame(ntree = nt,
                   RF_OOB = mod$learner.model$err.rate[nt,"OOB"],
                   RF_CV = err.rf,
                   RP_CV = rep(r.rp$agg, length(nt)))
  return(res)
}

(temp = compare(nt=c(1:10, seq(20, 100, 10)), iters=3))
yl = c(min(temp[ ,2:4]), max(temp[ ,2:4]))
plot(temp[ ,1:2], type="o", ylim=yl, ylab="")
points(temp[ ,c(1,3)], col=2, lty=2, type="o")
points(temp[ ,c(1,4)], col=3, lty=4, type="o")
legend("topright", lty=c(1,2,4), col=1:3, pch=1, 
       legend=c("RF_OOB", "RF_CV", "RP_CV"))


