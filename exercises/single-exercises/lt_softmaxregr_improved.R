# general comments:
# this implements several variant to fit softmax regression.
# the code is really not written for efficiency, but also tries to avoid the most stuipid mistakes
# of course, one can probably make this a lot faster
# approaches implemented are:
# - normal gradient descent. 
# - optimization with BFGS from optim

###############################################################################################

# general docs for arguments:
#  x:      n x p matrix. n obs, p features. 
#          if you want an intercept, add a 1-col yourself
#  y:      numeric vector of class labels. always coded as integer vals 1,2,..,g 
#  theta:  p x g matrix of coeff vectors. vectors are aligned in columns, 1 vec per class

###############################################################################################

# the softmax trafo, for a numvec z
library(BBmisc)
softmax1 = function(z) exp(z) / sum(exp(z))

# the softmax trafo, for matrix of row-vectors x, aligns results also in rows
softmax2 = function(x)  t(apply(x, 1, softmax1))

# computes linear scores from design matrix x and theta-matrix of coeffs
# result: n x g matrix of linear scores
linscores = function(x, theta) x %*% theta  # n * p  and p * g

# computes posterior probs, just calls linscores + softmax2
# result: n x g matrix of posterior probs
probs = function(x, theta) softmax2(linscores(x, theta))

# get one-hot dummy coding for integer y
# result: n x g binary 0/1 matrix, each row as exactly one "1" entry
onehotcoding = function(y) {
  d = data.frame(y = factor(y, levels = 1:max(y)))
  model.matrix(~y-1, data = d)
}

# computes negative log-likelihood, returns a numerical scalar
objective = function(theta, x, y) {
  p = probs(x, theta)
  p = vnapply(1:nrow(x), function(i) p[i,y[i]]) # get element per row of true class, numeric
  -sum(log(p))
}
  
# computes gradient of objective (neg lok lik)
# as theta is a matrix also returns a matrix of same dim
gradient = function(theta, x, onehot) {
  p = probs(x, theta)
  r = onehot - p  # n * g
  grad = matrix(0, nrow = nrow(theta), ncol = ncol(theta))
  # p * g

  for (i in 1:nrow(x)) { # iterate over all obs
    x1 = x[i,]  # 1 * p
    # gradi = - r[i,] %*% t(x1)  # 1*g and p * 1 outter product g*p
    gradi = - tcrossprod(r[i,], x1)  # 1*g and p * 1 outter product g*p
    # tcrossprod(as.matrix(c(1,1,1)),x1)
    # as promised in the tutorial, I use tcrossprod(x, y)’ instead of ‘x %*% t(y)’
    grad = grad + t(gradi)
  }
  return(grad)
}

linesearch = function(theta, grad, x, y) {
  print(theta)
  print(grad)
  fn = function(s) objective(theta - s * grad, x, y)
  optimize(fn, interval = c(0, 1))
}

# trains softmax regression 
# uses very simply gradient descent on the theta matrix
#   maxit: number of GD steps
#   step.size: simple step.size for a GD step
# returns: list with theta matrix of "optimal" found coefficients 
trainSoftmaxRegr1 = function(x, y, maxit = 100L, step.size = "linesearch") {
  n = nrow(x); p = ncol(x); g = max(y)
  onehot = onehotcoding(y)
  theta = matrix(0, nrow = p, ncol = g)
  for (iter in 1:maxit) {
    grad = gradient(theta, x, onehot)
    if (step.size == "linesearch") 
      step.size = linesearch(theta, grad, x, y)
    theta = theta - (step.size$minimum) * grad 
    obj = objective(theta, x, y)
    messagef("obj = %f", obj)
  }
  theta = theta - theta[,g]
  list(theta = theta, loss = obj)
}

# trains softmax regression 
# returns: list with theta matrix of "optimal" found coefficients 
trainSoftmaxRegr2 = function(x, y, use.grad = TRUE) {
  n = nrow(x); p = ncol(x); g = max(y)
  start = matrix(0, nrow = p, ncol = g-1)
  fn = function(tt, x, y) {
    theta = matrix(tt, nrow = p, ncol = g-1, byrow = FALSE)
    theta = cbind(theta, 0)
    objective(theta, x, y)
  }
  or = optim(par = start, fn = fn, x = x, y = y, method = "BFGS")
  theta = cbind(or$par, 0)
  list(theta = theta, loss = or$value)
}


predictSoftmaxRegr = function(model, x, y = NULL) {
  theta = model$theta
  p = probs(x, theta)
  classes = getMaxIndexOfRows(p)
  err = NULL
  if (!is.null(y))
    err = mean(y != classes)
  list(classes = classes, probs = p, err = err)
}

