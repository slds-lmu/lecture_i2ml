# Implementation of the k nearest neighbour algorithm
# Note that this implemenation is quite naive and slow.
#
# @param target [character(1)]
#   Name of target column in train and test data sets.
# @param traindata [data.frame]
#   Training data.
# @param testdata [data.frame]
#   Test data.
# @param k [integer(1)]
#   Number of neighbours considered for classification.
# @return [factor]. 
#   Factor of predicted classes for testdata.
myknn = function(target, traindata, testdata, k) {
  n = nrow(testdata)
  pred = rep(as.character(NA), n)
  # delete target column from training and test sets
  trainlabels = traindata[, target]
  traindata[, target] = NULL
  testdata[, target] = NULL
  
  # we could eliminate the following loop with another apply, but won't do this here
  # for better readability...
  for(i in 1:n) {
    # compute squared euclidean distances to all instances in training set
    nn = order(apply(traindata, 1, function(x) sum((x - testdata[i, ])^2)))[1:k]
    # compute frequencies of classes
    class.frequency = table(trainlabels[nn])
    most.frequent.classes = names(class.frequency)[class.frequency == max(class.frequency)]
    # tie breaking
    pred[i] = sample(most.frequent.classes, 1) 
  }
  factor(pred, levels=levels(trainlabels))
}


# Estimation of misclassification rates on training and test sets for knn
# for different values of k.
# Effectively, we are doing subsampling with n iterations for each k. 
# I.e., we split the data n times in train and test, fit on train,
# predict train, predict test and store the errors.
# All training and sets sets are equal across different values of k. 
#
# @param target [character(1)]
#   Name of target column in train and test data sets.
# @param data [data.frame]
#   Data set.
# @param k [integer]
#   Vector of k-values for knn to try.
# @param n [integer(1)]
#   Number of replications = number of training and test sets.
# @param ratio [numeric(1)]
#   Size of train set, from (0, 1).
# @return [matrix]. 
#   Matrix of misclassification rates both on training and test sets for each k. 
#   Rows correspond to k-values and are named.   
#   Columns correspond to train and test and are named.
estimateErrors = function(target, data, k, n = 10, ratio = 2/3) {
  # build data structure
  error.ratios = matrix(NA, nrow = length(k), ncol = 2)
  for(i in seq_along(k)) {
    err = matrix(NA, ncol = n, nrow = 2)
    for(j in 1:n) {
      # split up in training and test data
      split.idx = sample(nrow(data), ratio * nrow(data))
      train.data = data[split.idx, ]
      test.data  = data[-split.idx, ]
      
      # compute missclassification errors
      train.result = myknn(target, train.data, train.data, k[i])
      test.result  = myknn(target, train.data, test.data, k[i])
      err[1, j] = mean(train.result != train.data[, target])
      err[2, j] = mean(test.result != test.data[, target])
    }
    err = rowMeans(err)
    error.ratios[i,] = err
  }
  # do some naming
  colnames(error.ratios) = c("train error", "test error")
  rownames(error.ratios) = k
  error.ratios
}

# test with a small subset of iris
td = iris[sample(1:nrow(iris), 20),]
pred = myknn("Species", traindata = td, testdata = td, k = 3)
print(pred)
print(table(pred, td$Species))

res = estimateErrors("Species", iris, k = c(1, 2, 7), n = 10)
print(res)
