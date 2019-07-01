get.knn = function(Y, train.data, test.data, k, normalize = FALSE){
  n = nrow(test.data)
  pred = rep(as.character(NA), n)
  train.labels = train.data[, Y]
  test.labels = test.data[, Y]

  # delete Y column from training and test sets
  train.data[, Y] = NULL
  test.data[, Y] = NULL

  # normalize the feature vectors if desired
  if (normalize == TRUE) {
      train.data = apply(train.data, MARGIN = 2, FUN = function(x)
        (x - max(x)) / (max(x) - min(x)) )
      test.data = apply(test.data, MARGIN = 2, FUN = function(x)
        (x - max(x)) / (max(x) - min(x)) )
  }
  # we could eliminate the following loop with another apply,
  # better this way for explanation
  for (i in 1:n) {
      # compute squared euclidean distances to all instances in training set
      nn = order(apply(train.data, 1, function(x)
        sum((x - test.data[i, ])^2)))[1:k]
      # compute frequencies of classes
      class.frequency = table(train.labels[nn])
      most.frequent.classes =
        names(class.frequency)[class.frequency == max(class.frequency)]
      # tie breaking
      pred[i] = sample(most.frequent.classes, 1)
  }

  # calculate test error
  pred.err = round(sum(ifelse(pred != test.labels, 1, 0)) / n, 4)

  # return list of values
  return(list(prediction = pred, levels=levels(train.labels),
    mmce = pred.err))
}
