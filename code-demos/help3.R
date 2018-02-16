

#################
#
# mlr Overfitting
#
##############

library(mlr)

# data
data(iris)
str(iris)
set.seed(1327)
trainSize = 3/4
trainIndices = sample(x = seq(1, nrow(iris), by = 1), size = ceiling(trainSize * nrow(iris)), replace = FALSE)
irisTrain = iris[ trainIndices, ]
irisTest = iris[ -trainIndices, ]

# run experiment
k.values = rev(c(1, 2, 3, 4, 5, 7, 8, 9, 10, 15, 20, 25, 30, 35, 45, 50, 80, 100))
storage = data.frame(matrix(NA, ncol = 3, nrow = length(k.values)))
colnames(storage) = c("mmce_train", "mmce_test", "k")

for (i in 1:length(k.values)) {

  irisTask = makeClassifTask(data = irisTrain, target = "Species")
  irisLearner = makeLearner("classif.kknn", k = k.values[i])
  irisModel = train(learner = irisLearner, task = irisTask)

  # test data
  # choose additional measures from: listMeasures(irisTask)
  irisPred = predict(irisModel, newdata = irisTest[])
  storage[i, "mmce_test"] = performance(pred = irisPred, measures = mmce)

  # train data
  irisPred = predict(irisModel, newdata = irisTrain[])
  storage[i, "mmce_train"] = performance(pred = irisPred, measures = mmce)

  storage[i, "k"] = k.values[i]
}


plot(x = storage$k, y = storage$mmce_train, main = "Overfitting behavior KNN",
  xlab = "k", ylab = "mmce", col = "blue", type = "l")
lines(x = storage$k, y = storage$mmce_test, col = "orange")
legend("bottomright", c("test", "train"), col = c("orange", "blue"), lty = 1)




#################
#
# CV
#
##############




selfCV = function(data, target, folds, k) {

  storage = as.numeric(folds)

  set.seed(1337)
  indices = sample(x = seq(1, nrow(data), by = 1), size = nrow(data), replace = FALSE)

  # index matrix for folds
  indexMat = matrix(data = indices, byrow = TRUE, nrow = folds)

  for (i in 1:folds) {

    # data
    testData = data[indexMat[i, ], ]
    trainData = data[- indexMat[i, ], ]

    # model
    irisTask = makeClassifTask(data = trainData, target = target)
    irisLearner = makeLearner("classif.kknn", k = k)
    irisModel = train(learner = irisLearner, task = irisTask)
    storage[i] = performance(predict(irisModel, newdata = testData),
      measures = mmce)[[1]]
  }

  return(list(folds = folds, storage = as.data.frame(storage), GE = mean(storage)))
}

foo = selfCV(data = iris, target = "Species", folds = 10, k = 3)

p = ggplot(data = foo$storage, aes(y = storage, x = 1)) +
  geom_boxplot() +
  ggtitle(label = "Generalization error CV") +
  xlab("") + ylab("mmce") + xlim(c(0,2))
p



set.seed(1337)
task = mlr::makeClassifTask(data = iris, target = "Species")
rdescCV = mlr::makeResampleDesc(method = "CV", iters = 10)
mlrCV = resample(learner = "classif.knn", k = 4, task = task,
  resampling = rdescCV, show.info = FALSE)
mlrCV
mlrCV$measures.test

p = ggplot(data = mlrCV$measures.test, aes(y = mmce, x = 1)) +
  geom_boxplot() +
  ggtitle(label = "Generalization error CV") +
  xlab("") + ylab("mmce") + xlim(c(0,2))
p




# repeat 10 times to show that holdout is more depending on the randomness
storage = as.data.frame(matrix(0, nrow = 50, ncol = 2))
colnames(storage) = c("10-fold CV", "Holdout")

for (i in 1:nrow(storage)) {
  rCv = mlr::resample(learner = "classif.knn", k = 4, task = task,
    resampling = rdescCV, show.info = FALSE)
  rHO = mlr::resample(learner = "classif.knn", k = 4, task = task,
    resampling = rdescHO, show.info = FALSE)

  storage[i, "10-fold CV"] = as.numeric(rCv$aggr)
  storage[i, "Holdout"] = as.numeric(rHO$aggr)
}



#################
#
# Nested Resampling
#
##############

selfNR = function(data, target, outerFolds = 3, innerFolds = 4, kCandidates) {

  data = iris
  outerFolds = 3
  innerFolds = 5

  set.seed(1337)
  outerIndices = sample(x = seq(1, nrow(data), by = 1), size = nrow(data), replace = FALSE)
  indexMat = matrix(data = outerIndices, byrow = TRUE, nrow = outerFolds)

  for (i in 1:outerFolds) {

    # split in validation and data for the inner loop
    valData = data[outerIndices[i, ]]
    innerData = data[ -outerIndices[i, ]]

    winnerCV = as.data.frame(matrix(0, nrow = innerFolds, ncol = 2))

    # calculate GE for each of the candidates via CV
    for (l in 1:length(kCandidates)) {

      candidateGE = as.data.frame(matrix(0, nrow = kCandidates, ncol = 2))
      colnames(candidateGE) = c("k", "GE")

      innerIndices = sample(x = seq(1, nrow(innerData), by = 1), size = nrow(innerData), replace = FALSE)

      # index matrix for inner folds
      indexInnerMat = matrix(data = indices, byrow = TRUE, nrow = folds)

      # storage for CV errors for one candidate
      storageCV = as.numeric(innerFolds)

      for (j in 1:innerFolds) {
          # data
          testData = data[indexMat[i, ], ]
          trainData = data[- indexMat[i, ], ]

          # model
          irisTask = makeClassifTask(data = trainData, target = target)
          irisLearner = makeLearner("classif.kknn", k = kCandidates[l])
          irisModel = train(learner = irisLearner, task = irisTask)
          storageCV[i] = performance(predict(irisModel, newdata = testData),
            measures = mmce)[[1]]
      }

      # CV GE for candidate l
      candidateGE[l, "GE"] = mean(storageCV)
    }

  }

  innerIndices =
}




selfCV = function(data, target, folds, k) {

  storage = as.numeric(folds)

  set.seed(1337)
  indices = sample(x = seq(1, nrow(data), by = 1), size = nrow(data), replace = FALSE)

  # index matrix for folds
  indexMat = matrix(data = indices, byrow = TRUE, nrow = folds)

  for (i in 1:folds) {

    # data
    testData = data[indexMat[i, ], ]
    trainData = data[- indexMat[i, ], ]

    # model
    irisTask = makeClassifTask(data = trainData, target = target)
    irisLearner = makeLearner("classif.kknn", k = k)
    irisModel = train(learner = irisLearner, task = irisTask)
    storage[i] = performance(predict(irisModel, newdata = testData),
      measures = mmce)[[1]]
  }

  return(list(folds = folds, storage = as.data.frame(storage), GE = mean(storage)))
}
























