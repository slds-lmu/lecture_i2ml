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
Caravan.train = Caravan[, -constant]
Caravan.test = Caravan[, -constant]

boost.caravan = gbm(Purchase ~ ., data = Caravan.train, n.trees = 1000, shrinkage = 0.01, 
                    distribution = "bernoulli")
summary(boost.caravan)


#c)

boost.prob = predict(boost.caravan, Caravan.test, n.trees = 1000, type = "response")
boost.pred = ifelse(boost.prob > 0.2, 1, 0)
table(Caravan.test$Purchase, boost.pred)

73/(127 + 73)
#About 36% of people predicted to make purchase actually end up making one.

lm.caravan = glm(Purchase ~ ., data = Caravan.train, family = binomial)
lm.prob = predict(lm.caravan, Caravan.test, type = "response")
lm.pred = ifelse(lm.prob > 0.2, 1, 0)
table(Caravan.test$Purchase, lm.pred)
85/(190 + 85)
#About 31% of people predicted to make purchase using logistic regression actually end up making one. This is lower than boosting.