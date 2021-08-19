## ---- boosting_l_1
set.seed(0)
#' @param formula The formula stating the target of the dataset in the form of target~.
#' @param data The dataframe as input
#' @param iters The number of iterations
#' @param trace Whether to print out state variables
#' @param ...  Not used now
#' @return list of structure(list(alpha = alpha, models = models, iters = iters)
trainADA = function(formula, data, iters, trace = FALSE, ...) {
  if("w" %in% colnames(data)) stop("w is used internally, please choose another column name!")
  require(rpart)
  n = nrow(data)
  #initialize weights: 
  # need to initialize this as **a column of <data>** so that the formula based
  # interface of rpart finds them later. (weird look-up semantics of
  # model.frame, made even weirder by the way rpart calls model.frame
  # internally)
  data$w = rep(1/n, times = n)
  models = list()
  alpha = numeric(iters)
  #main loop
  for (i in seq_len(iters)) {
    models[[i]] = rpart(formula = formula, data = data, weights = w, 
                        control = rpart.control(maxdepth = 1), ...)
    
    pred = predict(models[[i]], data, type = "vector")
    
    missc = pred != models[[i]]$y
    
    err = sum(data$w * missc)/sum(data$w)
    
    alpha[i] = 0.5 * log((1 - err) / err)
    
    data$w = data$w * exp(alpha[i] * missc)
    
    data$w = data$w / sum(data$w)
    
    if (trace && i > 2) {
      newdata = data
      newdata$w = NULL
      input = structure(list(alpha = alpha[1:i], models = models[1:i], iters = i), class = "myADA")
      pred = predictADA(input, newdata = newdata)
      terr = mean(pred != as.numeric(newdata$Class))
      cat(sprintf("err is %s, alpha is %s \n", terr, alpha[i]))
    }
  }
  
  structure(list(alpha = alpha, models = models, iters = iters),
            class = "myADA")
}


predictADA = function(model, newdata) {
  # add weights-column (doesn't do anything, but needed for predict.rpart)
  if ("w" %in% colnames(newdata)) stop("w is used internally, please choose another column name!")
  newdata$w <- rep(1, times = nrow(newdata))
  pred = vapply(model$models, predict, newdata = newdata, type = "vector", 
                FUN.VALUE = numeric(nrow(newdata)))
  #recode classes to -1, 1
  pred = ifelse(pred == 1, -1, 1)
  pr = pred %*% diag(model$alpha[1:model$iters])
  pred = sign(rowSums(pred))
  #recode classes to 1, 2
  ifelse(pred == -1, 1, 2)
}



data(Sonar, package = "mlbench")

set.seed(123) 
idx = sample(208)
train_idx = idx[1:200]
test_idx = idx[201:208]
x = trainADA(Class ~ ., data = Sonar[train_idx, ], iters = 50L, trace = TRUE)
p = predictADA(x, Sonar[test_idx, ])
mean(p == as.numeric(Sonar[test_idx, ]$Class))

library(ada)
mod = ada::ada(Class ~ ., data = Sonar[train_idx, ], iter = 50L)
p2 = predict(mod, newdata = Sonar[test_idx, ])
mean(as.numeric(p2) == as.numeric(Sonar[test_idx, ]$Class))

