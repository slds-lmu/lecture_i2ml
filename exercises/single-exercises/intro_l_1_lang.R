library(mlr)
library(BBmisc)
library(stringi)

train = read.table("train.csv", header = TRUE, sep = ",",
  colClasses = c("integer", "factor", "factor", "character", "factor", "numeric",
    "numeric", "numeric", "factor", "numeric", "factor", "factor"))

train$train = TRUE

test = read.table("test.csv", header = TRUE, sep = ",",
  colClasses = c("integer", "factor", "character", "factor", "numeric",
    "numeric", "numeric", "factor", "numeric", "factor", "factor"))


test$Survived = NA
test$train = FALSE

data = rbind(train, test)

rm(train, test)

#Read in train and test data, combine it to one dataset so that we can apply the same preprocessing to both sets

#### preprocessing ####
summary(data)

# we see empty factor levels for variable "Embarked" and "Cabin", set them to NA!
data$Embarked[data$Embarked == ""] = NA
data$Embarked = droplevels(data$Embarked)
data$Cabin[data$Cabin == ""] = NA
data$Cabin = droplevels(data$Cabin)

#### Feature engeneering ####


# The full name does not give to much information, but maybe we can extract some useful features from the names

# first split first and last names and save it as a list
names = stri_split(data$Name, fixed = ", ")


# # get the family name. We assume that survival or death of whole families is more or less likely 
# data$family = vapply(names, function(x) x[1], character(1))
# 
# singles = names(which(table(data$family) == 1))
# 
# # recode all family names that occur just once in a "single" class
# data$family = forcats::fct_collapse(data$family, single = singles)

#We can also try to get some additional information from the titles of the persons
data$titles = vapply(names, function(name) {
  stri_split(name[2], fixed = " ", simplify = TRUE)[1]
}, character(1))

#We aggretete the a bit further 
data$titles = forcats::fct_collapse(data$titles, 
  Noble = c("Capt.", "Col.", "Major.", "Sir.", "Lady.", "Rev.", "Dr.", "Don.", "Dona.", "Jonkheer."),
  Mrs = c("Mrs.", "Ms.", "the"), # "the" is for "the countess" and got butchered by the splitting earlier
  Mr = c("Mr."),
  Miss = c("Mme.", "Mlle.", "Miss."),
  Master = c("Master."))

# "children and women first" we generate a variable to account for this
data$dibs = data$Sex == "female" | data$Age < 15

# Price per person, since multiple ticket prices are bought by one person
data$farePp = data$Fare / (data$Parch + data$SibSp + 1)

# The deck can be extracted from the the cabin number
data$deck = as.factor(stri_sub(data$Cabin, 1, 1))

# starboard had an odd number, portside even cabin numbers
data$portside = as.numeric(stri_sub(data$Cabin, 3, 3)) %% 2 == 0

# PassengerId, Ticket, Name and Cabin is not useful for us anymore so we drop them
data = dropNamed(data, c("Cabin","PassengerId", "Ticket", "Name"))

summary(data)


#### Imputation ####

# We some missing values that we want to remove
# Numerics are imputed with the median value and factors with a seperate category

data = impute(data, cols = list(
  Age = imputeMedian(),
  Fare = imputeMedian(),
  Embarked = imputeConstant("__miss__"),
  dibs = imputeConstant("__miss__"),
  farePp = imputeMedian(),
  deck = imputeConstant("__miss__"),
  portside = imputeConstant("__miss__")
))

data = data$data
data = convertDataFrameCols(data, chars.as.factor = TRUE)

summary(data)


### tasks ###

# split data back into train and test and remove the train 
train = data[data$train, ]
train$train = NULL

test = data[!data$train, ]
test$train = NULL

task.train = makeClassifTask(id = "titanic", data = train, target = "Survived", positive = "1")

### algorithms ###

# We want to compare these four algorithms

learners = makeLearners(c("glmnet", "naiveBayes", "randomForest", "ksvm"), type = "classif", 
  predict.type = "prob")


set.seed(3)
rdesc = makeResampleDesc("CV", iters = 10L, stratify = TRUE)
rinst = makeResampleInstance(rdesc, task.train)
bmr = benchmark(learners, task.train, rinst, measures = auc)

plotBMRBoxplots(bmr)

# The Random Forest seems to work best, let's have a closer look

split = makeResampleInstance(hout, task.train)

mod = train(learners$classif.randomForest, task.train, subset = split$train.inds[[1]])

pred = predict(mod, task.train, subset = split$test.inds[[1]])

df = generateThreshVsPerfData(pred, list(fpr, tpr, acc))

plotThreshVsPerf(df)
plotROCCurves(df)
calculateROCMeasures(pred)


imps = getFeatureImportance(mod)

barplot(unlist(imps$res))

plotPartialDependence(generatePartialDependenceData(mod, task.train, "Age", gridsize = 20L))
plotPartialDependence(generatePartialDependenceData(mod, task.train, "farePp", gridsize = 20L))


### Tuning ###

# We used all algorithms in their default settings, hopefully tuning will improve the performance
# For a fair comparison we have to use nested crossvalidation to get true out-of-sample predictions.

par.set = makeParamSet(
  makeNumericParam("C", lower = -8, upper = 8, trafo = function(x) 2^x),
  makeNumericParam("sigma", lower = -8, upper = 8, trafo = function(x) 2^x)
)

tune.ctrl = makeTuneControlRandom(maxit = 20)

classif.ksvm.tuned = makeTuneWrapper(learners$classif.ksvm, cv3, auc, par.set, tune.ctrl)

bmr2 = benchmark(classif.ksvm.tuned, task.train, rinst, auc)


plotBMRBoxplots(mergeBenchmarkResults(list(bmr, bmr2)))

