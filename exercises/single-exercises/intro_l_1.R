library(mlr)
library(BBmisc)
# library(readr)
setwd("~/work/cim/cim2/2017/Aufgaben/")
train = read.table("train.csv", header = TRUE, sep = ",",
  colClasses = c("integer", "factor", "factor", "character", "factor", "numeric",
    "numeric", "numeric", "factor", "numeric", "factor", "factor"))
str(train)
summary(train)


# we see empty factor levels for variable "Embarked", set it to NA!
train$Embarked[train$Embarked == ""] = NA
train$Embarked = droplevels(train$Embarked)
# same for Cabin
train$Cabin[train$Cabin == ""] = NA
# PassengerId, Name, Ticket, is not useful for us,
# in fact they are colinear so we drop it from the data.frame
train = dropNamed(train, c("PassengerId", "Name", "Ticket"))
# Cabin has a lot of NA's and misleading levels. e.g: "B51 B53 B55",
# drop that too
levels(train$Cabin)
sum(is.na(train$Cabin))
train = dropNamed(train, "Cabin")
summary(train)
# Now we still have some NA's in the data for the following features:
# Age, and Embarked

# visualize variables:
barplot(table(train$Pclass), main = "Socioeconomic status")
barplot(table(train$Embarked), main = "Port of embarkation")
hist(train$Age, main = "Histogram of age")
hist(train$Fare, main = "Histogram of passenger fare")


# To validate our models we need a test set!
test = read.table("test.csv", header = TRUE, sep = ",",
  colClasses = c("integer", "factor", "character", "factor", "numeric", "numeric", "numeric",
    "factor", "numeric", "factor", "factor"))
# we can drop the unnecessary columns again, but before we store the passenger
# id's because we need them later to submit our predictions
test.pid = test$PassengerId
test = dropNamed(test, c("PassengerId", "Name", "Ticket", "Cabin"))

# Now we need to take care of our NA's in the data 
imp = impute(train, target = "Survived", dummy.cols = "Age",
  cols = list(
    # NA's for Age will be replaced by the median of the variable
    Age = imputeMedian(),
    # For Embarked we simply use a different tag 
    Embarked = imputeConstant("__miss__"),
    Fare = imputeMedian()
  )
)

# training set with the imputed data
train = imp$data

# Our test set needs the same structure as our training set, reimpute will
# do that for us, we simply need the imputation desc from 'imp'
test = reimpute(test, imp$desc)
# Data preprocessing is finished now. So we can start modelling:
# Firstly we need to create the task with mlr:
task = makeClassifTask(data = train, target = "Survived")
# And a learning algorithm of our choice.
lrn1 = makeLearner("classif.randomForest")
# train the model on the task
mod = train(lrn1, task)
# And calculate predictions on the test set, which the learner hasn't seen
# during training
p = predict(mod, newdata = test)
# let's see how well our model works:
# we make 10 fold CV which we will repeat 3 times
rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 3L)
b = benchmark(lrn1, task, rdesc, measures = acc)
getBMRAggrPerformances(b)

# let's check how well simple logit-regression works on this data.
# We can simply call benchmark again:
lrn2 = makeLearner("classif.logreg")
b2 = benchmark(list(lrn1, lrn2), task, rdesc, measures = acc)
# mlr has built in plotting functions to visualize results from benchmark experiments:
plotBMRBoxplots(b2)
# plotBMRSummary(b2)
# plotBMRRanksAsBarChart(b2)


# store our predictions with the passenger id's in a data frame
subm = data.frame(PassengerId = test.pid, Survived = as.character(getPredictionResponse(p)))
# save it as .csv so we can upload it on kaggle
write.table(subm, file = "subm.csv", col.names = TRUE, row.names = FALSE,
  sep = ",", quote = FALSE)

