# @Description:
# @Model: \theta_{ij} is the jth coefficient for class i
# 
#
library(BBmisc)
library(stats)
library(glmnet)

# random initialization to the model matrix \theta_{ij}
minit = function(df, tname, lastZero = FALSE) {
  p = ncol(df) - 1L                # number of features does not include the target column(1L)
  k = length(unique(df[, tname]))  # number of classes
  theta = matrix(rep(rnorm(p, 0, 1), k), nrow = k, ncol = p)  # k is the number of classes , p is the number of features
  if(lastZero) theta[nrow(theta),] = 0
  return(theta)
}

m.softmax = function(mt.theta, instX) {
  X = matrix(as.matrix(instX), ncol = ncol(mt.theta))  # ncol(X) = ncol(mt.theta)
  vr.z = X %*% t(mt.theta)  # mt.theta[i,] is the coefficients for class i 
  # exp(-vr.z) / sum(exp(-vr.z))
  exp(vr.z) / sum(exp(vr.z))
}

# The cost function is the mean of the cost for each row, -log(/pi_i) negative loglikelihood
mcost = function(mt.theta, X, Y) {
  # mt.pi = m.softmax(mt.theta, X) 
  # m.softmax(mt.theta, X[i, ])[Y[i]]
  list.row = lapply(seq_along(Y), function(i){ m.softmax(mt.theta, X[i, ])[Y[i]] })
  -1 * mean(log(unlist(list.row))) }
# The gradient for each class is a vector, where each column only differs because of the different components of the X vector;
sgdRowUpdate = function(instX, instY, mt_theta_old, lambda = 1e-4, alpha = 1e-4) {
  grad = mt_theta_old  # set to be the same size
  # notrun: assertthat::assert_that(nrow(mt_theta_old)==levels(Y)
  for(i in 1L:nrow(mt_theta_old)) {
    grad[i, ] = as.matrix(instX) * m.softmax(mt_theta_old, instX)[i]
    # $grad[i,] = /pi_j /times x$
}
  grad[instY, ] = -1 * as.matrix(instX) * (1 - m.softmax(mt_theta_old, instX)[instY])
  grad2 = grad + lambda * mt_theta_old  # regularization 
  theta_new = mt_theta_old - alpha* grad2
  # theta_new[nrow(theta_new),] = 0
  theta_new 
}

sgd = function(theta_start, X, Y, alpha = 1e-3, lambda = 0) {
  X = as.matrix(X)
  mt_theta = theta_start
  for(i in sample(nrow(X))) {
   mt_theta = sgdRowUpdate(instX = X[i, ], instY = Y[i], mt_theta, alpha = alpha, lambda = lambda) }
  loss = mcost( mt.theta = mt_theta, X = X, Y = Y)
  catf("loss:%f",loss)
  yhat = mpred(mt_theta, X)
  # perf = mperf(yhat, df, tname = tname)
  # print(nperf)
  mt_theta
}

mtrain = function(theta_start, X, Y, niter = 100L, alpha, lambda, thres = 1e-6) {
 theta_update = theta_start
 print(theta_update)
 for(i in 1L:niter) {
   theta_update = sgd(theta_start = theta_update, X = X, Y = Y, alpha = alpha, lambda = lambda)
   print(theta_update)
   # if you have typo here, each iteration it will use old parameter
   # if(mconverge(theta_old, theta_new, thres = thres)) break
 }
 theta_update
}

mconverge = function(theta_old, theta_new, thres = 0.001 ) {
 # mdev = abs(theta_old[1:2, ] - theta_new[1:2, ]) / abs(theta_old[1:2, ]) 
 #if(mean(mdev) < thres ) return(TRUE)
 return(FALSE)
} 

mpred = function(theta, X) {
 v =  m.softmax(theta, X)  # v has the same number of rows as X
 apply(v, 1, function(x) which(x == max(x)))  # take the biggest value  of each row as yhat
}

mperf = function(Yhat, Y) {
 sum(Yhat == Y)/length(Y)
}

## todo' : 
mgd.single = function( mt_theta_old, instX, instY,lambda = 1e-4, alpha = 1e-4) {
  gd = mt_theta_old
  for(i in 1L:nrow(mt_theta_old)) {  # iterate each class
  gd[i,] = -1 * alpha * as.matrix(instX) * m.softmax(mt_theta_old, instX)[i]
}
  gd[instY,] =  alpha * ( as.matrix(instX) * (-1 + m.softmax(mt_theta_old, instX)[instY])
  )
  gd
}

mgd.batch = function(mt_theta_old, X, Y, lambda = 1e-4, alpha = 1e-4) {
  gd = mt_theta_old  # gradient init to the same dim as theta itself
  gd.list = lapply(1:nrow(X), function(i) {
    mgd.single(mt_theta_old = mt_theta_old, instX = X[i, ], instY = Y[i], lambda = 1e-4, alpha = 1e-4) 
    })
  gd = Reduce("+", gd.list)
  gd
}



mgd.batch2 = function(X, instY, mt_theta_old) {
  lambda = 1e-4
  alpha = 1e-4
  gd = mt_theta_old  # gradient init to the same dim as theta itself
  mt.pi = m.softmax(mt_theta_old, X)
  list.s = lapply(seq_along(instY), function(i){ X[i, ]* mt.pi[i, instY[i]]})
  ss = matrix(unlist(list.s),ncol =1)
  gd = -1 * alpha * ss
  gd[instY,] =  alpha * ( as.matrix(instX[]) * (-1 + m.softmax(mt_theta_old, instX)[instY])
  )
  gd
}


