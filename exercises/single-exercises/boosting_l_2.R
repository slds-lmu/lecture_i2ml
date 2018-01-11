library(BBmisc)
library(rpart)

# animate gtradient boosting process for regression with L2-loss and stumps
#
# enter: num. design matrix, response vector, number of iters, minsplit for trees

anim = function(X, y, M, minsplit = 1L) {
 
  n = length(y)
  x1 = X[,1L]
  # for L2 loss we take the mean as constant model f_0
  intercept = mean(y)

  # here store the M models and associated beta weights
  models = vector("list", M)
  betas = numeric(M)

  # prediction of first m additive models on data X
  additivePredict = function(m) {
    # if we had 0 models in the past, just return intercept
    if (m == 0)
      return(rep(intercept, n))
    # otherwise predict first m model, multiply with beta, add intercept f_0
    p = sapply(1:m, function(i) {
      predict(models[[i]], newdata = X)
    })
    p %*% betas[1:m] + intercept
  }

  # loss = 0.5 (yhat - y)^2
  # negative gradient of loss, here for L2-loss
  dloss = function(yhat) (y - yhat)

  # plot data and prediction yhat of first m models
  plotModel = function(m, yhat, r, rhat, beta) {
    par(mfrow = c(2L, 1L))
    plot(x1, y, main = sprintf("data and first %i aditive models", m))
    lines(x1, yhat)
    plot(x1, r, main =
      sprintf("pseudo-residuals r and rhat-fit of current model\nAfterwards we will find beta = %g", beta))
    lines(x1, rhat)
    par(mfrow = c(1L, 1L))
  }

  # get beta by line search
  # (bonus points to reader who sees that this is actually unnessary and stupid for L2 loss...)
  lineSearch = function(yhat, rhat) {
    # L2 loss for yhat + beta * f.m
    obj = function(beta)
      crossprod(y - (yhat + beta * rhat))
    # find best beta
    or = optimize(obj, interval = c(0, 10000))
    print(or)
    or$minimum
  }

  for(j in 1:M) {
    messagef("Iteration: %i", j)
    # get predictions of our additive model
    yhat = additivePredict(j - 1L)
    # now get pseudo-residuals / negative gradient
    r = dloss(yhat)
    # fit model to pseudo residuals
    rdata = cbind(X, r = r)
    model = rpart(r ~ ., data = rdata, maxdepth = 1L, minsplit = 1L, minbucket = 1L, xval = 0L)
    models[[j]] = model
    rhat = predict(model, newdata = X)
    trace = data.frame(x1 = x1, y = y, yhat = yhat, r = r, rhat = rhat)
    print(trace)
    beta = lineSearch(yhat = yhat, rhat = rhat)
    plotModel(m = j - 1, yhat = yhat, r = r, rhat = rhat, beta = beta)
    betas[[j]] = beta
    pause()
  }
  return(list(iodels = models, betas = betas, intercept = intercept))
}


n = 10
x = seq(0, 10, length.out = n)
X = data.frame(x1 = x)
y = sin(x) + rnorm(n, mean = 0, sd = 0.01)
z = anim(X = X, y = y, M = 2000)


