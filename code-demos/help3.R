

#################
#
# mlr Overfitting
#
##############

library(mlr)
library(mlbench)

# data
data(iris)
str(iris)
set.seed(1333)
trainSize = 3/4
trainIndices = sample(x = seq(1, nrow(iris), by = 1), size = ceiling(trainSize * nrow(iris)), replace = FALSE)
irisTrain = iris[ trainIndices, ]
irisTest = iris[ -trainIndices, ]


library(mlr)
library(mlbench)

set.seed(13)
spiral = as.data.frame(mlbench.spirals(n = 500, sd = 0.1))
trainSize = 3/4
trainIndices = sample(x = seq(1, nrow(spiral), by = 1), size = ceiling(trainSize * nrow(spiral)), replace = FALSE)
spiralTrain = spiral[ trainIndices, ]
spiralTest = spiral[ -trainIndices, ]



# run experiment
k.values = rev(c(1, 2, 3, 4, 5, 7, 8, 9, 10, 15, 20, 25, 30, 35, 45, 50, 60, 70, 80, 90, 100))
storage = data.frame(matrix(NA, ncol = 3, nrow = length(k.values)))
colnames(storage) = c("mmce_train", "mmce_test", "k")

for (i in 1:length(k.values)) {

  spiralTask = makeClassifTask(data = spiralTrain, target = "classes")
  spiralLearner = makeLearner("classif.kknn", k = k.values[i])
  spiralModel = train(learner = spiralLearner, task = spiralTask)

  # test data
  # choose additional measures from: listMeasures(irisTask)
  spiralPred = predict(spiralModel, newdata = spiralTest[])
  storage[i, "mmce_test"] = performance(pred = spiralPred, measures = mmce)

  # train data
  spiralPred = predict(spiralModel, newdata = spiralTrain[])
  storage[i, "mmce_train"] = performance(pred = spiralPred, measures = mmce)

  storage[i, "k"] = k.values[i]
}

storage = storage[rev(order(storage$k)),]

plot(x = storage$k, y = storage$mmce_train, main = "Overfitting behavior KNN",
  xlab = "k", ylab = "mmce", col = "blue", type = "l",
  xlim = rev(range(storage$k)),
  ylim = c(min(storage$mmce_train, storage$mmce_test),
    max(storage$mmce_train, storage$mmce_test)))
lines(x = storage$k, y = storage$mmce_test, col = "orange")
legend("bottomleft", c("test", "train"), col = c("orange", "blue"), lty = 1)




#################
#
# CV
#
##############




selfCV = function(data, target, folds, k) {

  storage = numeric(folds)

  set.seed(1337)
  indices = sample(x = seq(1, nrow(data), by = 1), size = nrow(data), replace = FALSE)

  # index matrix for folds
  indexMat = matrix(data = indices, byrow = TRUE, nrow = folds)

  for (i in 1:folds) {

    # data
    testData = data[indexMat[i, ], ]
    trainData = data[-indexMat[i, ], ]

    # model
    task = makeClassifTask(data = trainData, target = target)
    learner = makeLearner("classif.kknn", k = k)
    model = train(learner = learner, task = task)
    storage[i] = performance(predict(model, newdata = testData),
      measures = mmce)[[1]]
  }

  return(list(folds = folds, storage = as.data.frame(storage), GE = mean(storage)))
}

foo = selfCV(data = spiral, target = "classes", folds = 10, k = 3)

p = ggplot(data = foo$storage, aes(y = storage, x = 1)) +
  geom_boxplot() +
  ggtitle(label = "Generalization error CV") +
  xlab("") + ylab("mmce") + xlim(c(0,2))
p



set.seed(1333)
task = mlr::makeClassifTask(data = spiral, target = "classes")
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


#################
#
# Nested Resampling
#
##############

selfNR = function(data, target, outerFolds = 3, innerFolds = 4, kCandidates, inform = FALSE) {

  # data = spiral
  # outerFolds = 4
  # innerFolds = 5
  counter = 0

  set.seed(1337)
  outerIndices = sample(x = seq(1, nrow(data), by = 1), size = nrow(data), replace = FALSE)
  indexOuterMat = matrix(data = outerIndices, byrow = TRUE, nrow = outerFolds)

  # frame to store the winner and its test-GE from all outer folds
  winnerCV = as.data.frame(matrix(0, nrow = outerFolds, ncol = 2))
  colnames(winnerCV) = c("k", "GE")

  for (i in 1:outerFolds) {

    # split in validation and data for the inner loop
    valData = data[indexOuterMat[i, ], ]
    innerData = data[ -indexOuterMat[i, ], ]

    # frame to store the CV-GEs for each candidate
    candidateGE = as.data.frame(matrix(0, nrow = length(kCandidates), ncol = 2))
    colnames(candidateGE) = c("k", "GE")

    # calculate GE for each of the candidates via CV
    for (l in 1:length(kCandidates)) {

      innerIndices = sample(x = seq(1, nrow(innerData), by = 1), size = nrow(innerData), replace = FALSE)

      # index matrix for inner folds
      indexInnerMat = matrix(data = innerIndices, byrow = TRUE, nrow = innerFolds)

      # storage for CV errors for one candidate
      storageInnerCV = numeric(innerFolds)

      for (j in 1:innerFolds) {
          # data
          testData = innerData[indexInnerMat[j, ], ]
          trainData = innerData[ -indexInnerMat[j, ], ]

          # model
          task = makeClassifTask(data = trainData, target = target)
          learner = makeLearner("classif.kknn", k = kCandidates[l])
          model = train(learner = learner, task = task)
          # inform user about progress
          counter = counter + 1
          if (inform) print(paste0("model: " ,counter, " inner fold: ", j, " outer fold: ", i))
          storageInnerCV[j] = performance(predict(model, newdata = testData),
            measures = mmce)[[1]]
      }

      # CV GE for candidate l
      candidateGE[l, "GE"] = mean(storageInnerCV)
      candidateGE[l, "k"] = kCandidates[l]
    }

  # get GE for best candidate in this outerFold
  bestCandidate = candidateGE[which(candidateGE$GE == min(candidateGE$GE)), "k"]
  winnerCV[i, "k"] = bestCandidate


  # model
  task = makeClassifTask(data = innerData, target = target)
  learner = makeLearner("classif.kknn", k = kCandidates[l])
  model = train(learner = learner, task = task)
  winnerCV[i, "GE"] = performance(predict(model, newdata = valData),
    measures = mmce)[[1]]
  }
  return(winnerCV)
}

foo = selfNR(data = spiral, target = "classes", outerFolds = 10, innerFolds = 9,
  kCandidates = c(20, 3, 5, 10, 1), inform = TRUE)
foo

debug(selfNR)
foo = selfNR(data = spiral, target = "classes", outerFolds = 4, innerFolds = 5,
  kCandidates = c(20, 3, 5, 10, 1))
undebug(selfNR)


















