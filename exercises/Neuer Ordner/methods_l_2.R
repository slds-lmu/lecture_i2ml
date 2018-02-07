
library(mnormt)
library(MASS)
library(mlbench)

# Fit QDA on data, using all (numeric) features.
# Target column has to be a factor.
#
# @param target [character(1)]
#   Name of target variable.
# @param data [data.frame]
#   Data.frame with features and target column.
# @return [list]. QDA model (S3 class "myqda"), containing:
#   target [character(1)]: Name of target variable.
#   classes [character]: Levels of classes.
#   classes [character]: Levels of classes.
#   priors [numeric]: Named vector of empirical priors of classes.
#   means [list]: Named list of class means.
#   covs [list]: Named list of cov. matrices.
trainQDA = function(target, data) {
  n = nrow(data)
  classes = levels(data[,target])
  target.col = which(colnames(data) == target)
  k = length(classes)
  priors = setNames(numeric(k), classes)
  means = setNames(vector("list", k), classes)
  covs = setNames(vector("list", k), classes)
  for (cl in classes) {
    j = data[,target.col] == cl
    priors[cl] = sum(j) / n
    d = data[j, -target.col]
    means[[cl]] = colMeans(d)
    covs[[cl]] = cov(d)
  }
  # this constructs an S3 class, but we will not really exploit this in this solution...
  structure(list(
      target = target, classes = classes,
      priors = priors, means = means, covs = covs
  ), class="myqda")
}


# Predict function for myqda model for new data.
#
# @param model [myqda]
#   Our myqda model from trainQDA.
# @param newdata [data.frame]
#   New data to predict. May or may not contain
#   target column. Feaure columns must be the same and in the same
#   order as in training data.
# @param type [character(1)]
#   "prob": Predict matrix of probabilities, columns are named by classes.
#   "classes": Predict factor of discrete classes.
# @return Either a matrix or a factor, see type above.
predictQDA = function(model, newdata, type) {
  cls = model$classes
  newdata[,model$target] = NULL
  probs = matrix(nrow = nrow(newdata), ncol = length(cls))
  colnames(probs) = cls
  for (cl in cls) {
    probs[, cl] =
      dmnorm(newdata, mean = model$means[[cl]], varcov = model$covs[[cl]]) * model$priors[cl]
  }
  probs = t(apply(probs, 1, function(x) x / sum(x)))
  if (type == "prob") {
    return(probs)
  } else {
    y = cls[max.col(probs, ties.method = "random")]
    return(factor(y, levels = cls))
  }
}


# Compare our qda with qda from MASS.
# Fit on whole data set and predict the same data.
#
# @param target [character(1)]
#   Name of target variable.
# @param data [data.frame]
#   Data.frame with features and target column.
# @return [list].
#   max.prob.diff [numeric(1)]: Max. absolute difference for probs between our qda and qda from MASS.
#   label.diff [numeric(1)]: Number of predictions where class labels were different between our qda and qda from MASS.
compareQDA = function(target, data) {
  m1 = trainQDA(target, data)
  p1a = predictQDA(m1, newdata = data, type = "prob")
  p1b = predictQDA(m1, newdata = data, type = "class")

  m2 = qda(reformulate(".", target), data = data)
  p2 = predict(m2, newdata = data)
  p2a = p2$posterior
  p2b = p2$class

  list(
    max.prob.diff = max(abs(p1a - p2a)),
    label.diff = sum(p1b != p2b)
  )
}

print(compareQDA("Species", iris))
data(Ionosphere)
print(compareQDA("Class", Ionosphere[,-(1:2)]))

