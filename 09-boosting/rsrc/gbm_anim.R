library(BBmisc)
library(rpart)
library(gridExtra)

# animate gtradient boosting process for regression with L2-loss and stumps
#
# enter: num. design matrix, response vector, number of iters, minsplit for trees

# plot data and prediction yhat of first m models
# plotModel = function(m, x1, yhat, r, rhat, beta) {
#   par(mfrow = c(2L, 1L))
#   d = c(0, (x1[-1] - x1[-length(x1)])/2, 0)
#   plot(x1, y, main = sprintf("data and first %i aditive models", m))
#   segments(x1 - d[1:length(x1)], yhat, x1 + d[1:length(x1) + 1], yhat)
#   plot(x1, r, main =
#       sprintf("pseudo-residuals r and rhat-fit of current model\nAfterwards we will find beta = %g", beta))
#   segments(x1 - d[1:length(x1)], rhat, x1 + d[1:length(x1) + 1], rhat)
#   par(mfrow = c(1L, 1L))
# }

plotModel = function(m, x1, yhat, r, rhat, beta) {
  d = c(0, (x1[-1] - x1[-length(x1)])/2, 0)
  xgrid = c(rbind(x1 - d[1:length(x1)], x1 + d[1:length(x1) + 1]))
  yhatgrid = rep(yhat, each = 2) 
  rhatgrid = rep(rhat, each = 2) 
  p1 = ggplot() + geom_point(aes(x = x1, y = y), alpha = .5) +
    geom_step(aes(x = xgrid, y = yhatgrid), colour = pal_2[1]) +
    ggtitle(label = NULL , subtitle = sprintf("m = %i: data and model ", m)) + 
    xlab("x") # + ylim(range(c(yhat, rhat)))
  p2 = ggplot() + geom_point(aes(x = x1, y = r), alpha = .5) +
    geom_step(aes(x = xgrid, y = rhatgrid), colour =  pal_2[2]) +
    ggtitle(label = NULL, subtitle = expression(r^{"[m]"}~"und"~beta*b^{"[m]"})) + 
    xlab("x") + ylim(range(c(y, yhat, rhat)))
  grid.arrange(p1, p2, nrow = 1)
}

anim = function(X, y, M, minsplit = 3L, demo = TRUE, data.all.iterations = FALSE) {

  n = length(y)
  x1 = X[,1L]
  # for L2 loss we take the mean as constant model f_0
  intercept = mean(y)

  # here store the M models and associated beta weights
  models = vector("list", M)
  betas = numeric(M)
  if(data.all.iterations) traces = vector("list", M)


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

  # get beta by line search
  # (bonus points to reader who sees that this is actually unnessary and stupid for L2 loss...)
  lineSearch = function(yhat, rhat) {
    # L2 loss for yhat + beta * f.m
    obj = function(beta)
      crossprod(y - (yhat + beta * rhat))
    # find best beta
    or = optimize(obj, interval = c(0, 10000))
    if(demo) print(or)
    or$minimum
  }

  for(j in 1:M) {
    if(demo) messagef("Iteration: %i", j)
    # get predictions of our additive model
    yhat = additivePredict(j - 1L)
    # now get pseudo-residuals / negative gradient
    r = dloss(yhat)
    # fit model to pseudo residuals
    rdata = cbind(X, r = r)
    model = rpart(r ~ ., data = rdata, maxdepth = 1L, minsplit = minsplit, minbucket = minsplit, xval = 0L)
    models[[j]] = model
    rhat = predict(model, newdata = X)
    trace = data.frame(x1 = x1, y = y, yhat = yhat, r = r, rhat = rhat)
    if(demo) {
      print(trace)
    }
    if(data.all.iterations) traces[[j]] = trace
    beta = lineSearch(yhat = yhat, rhat = rhat)
    if(demo) plotModel(m = j - 1, yhat = yhat, r = r, rhat = rhat, beta = beta)
    betas[[j]] = beta
    if(demo) pause()
  }
  if(!data.all.iterations) {
    return(list(models = models, betas = betas, intercept = intercept))
  } else {
    return(list(models = models, betas = betas, intercept = intercept, traces = traces))
  }
}

#example:
# n = 10
# x = seq(0, 10, length.out = n)
# X = data.frame(x1 = x)
# y = sin(x) + rnorm(n, mean = 0, sd = 0.01)
# z = anim(X = X, y = y, M = 10, demo = TRUE)
# z = anim(X = X, y = y, M = 10, demo = FALSE, data.all.iterations = TRUE)
#
# # plot specific iteration:
# m = 4
# plotModel(m-1, X[,1L], yhat = z$traces[[m]]$yhat, r = z$traces[[m]]$r, rhat = z$traces[[m]]$rhat, beta = z$betas[[m]])
