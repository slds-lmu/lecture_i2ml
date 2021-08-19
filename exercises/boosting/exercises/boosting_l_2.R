#### Without mlr3 ####

#a)

library(ISLR)
train = 1:1000
Caravan$Purchase = ifelse(Caravan$Purchase == "Yes", 1, 0)
Caravan.train = Caravan[train, ]
Caravan.test = Caravan[-train, ]


#b)

library(gbm)
set.seed(342)

#Remove constant features
constant = which(sapply(Caravan.train, function(x) var(x) == 0))
Caravan.train = Caravan.train[, -constant]
Caravan.test = Caravan.test[, -constant]

boost.caravan = gbm(Purchase ~ ., data = Caravan.train, n.trees = 1000, shrinkage = 0.01, distribution = "bernoulli")
summary(boost.caravan)


#c)

boost.prob = predict(boost.caravan, Caravan.test, n.trees = 1000, type = "response")
boost.pred = ifelse(boost.prob > 0.2, 1, 0)
table(Caravan.test$Purchase, boost.pred)

34/(137 + 34)
#About 20% of people predicted to make purchase actually end up making one.

lm.caravan = glm(Purchase ~ ., data = Caravan.train, family = binomial)
lm.prob = predict(lm.caravan, Caravan.test, type = "response")
lm.pred = ifelse(lm.prob > 0.2, 1, 0)
table(Caravan.test$Purchase, lm.pred)
58/(350 + 58)
#About 14% of people predicted to make purchase using logistic regression actually end up making one. This is lower than boosting.



#### Now with mlr3 ####

library(mlr3)
library(mlr3extralearners)

# a) b)

data("Caravan")
task = TaskClassif$new(id = "Caravan", backend = Caravan, target = "Purchase", positive = "Yes")
task$select(setdiff(task$feature_names, names(constant)))

lrn_boost = lrn("classif.gbm", shrinkage = 0.01, n.trees = 1000, predict_type = "prob")

lrn_boost$train(task, row_ids = 1:1000)
lrn_boost$importance()

#c) 

preds = lrn_boost$predict(task, row_ids = 1001:task$nrow)
preds$set_threshold(0.2)
preds$confusion
preds$score(msr("classif.precision"))

lrn_logreg = lrn("classif.log_reg", predict_type = "prob")
lrn_logreg$train(task, row_ids = 1:1000)
preds2 = lrn_logreg$predict(task, row_ids = 1001:task$nrow)
preds2$set_threshold(0.2)
preds2$confusion
preds2$score(msr("classif.precision"))
