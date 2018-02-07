# general docs for arguments:
#  x:      n x p matrix. n obs, p features. 
#          if you want intercepts, add a 1-col yourself
#  y:      numeric vector of class labels. always coded as 1,2,..,g 
#  theta:  n x g matrix of coeff vectors. vectors are aligned in columns, 1 vec per class

# the softmax trafo, for a numvec z
softmax1 = function(z) exp(z) / sum(exp(z))

# the softmax trafo, for matrix of row-vectors x, aligns results also in rows
softmax2 = function(x)  t(apply(x, 1, softmax1))

# computes linear scores from design matrix x and theta-matrix of coeffs
# result: n x g matrix of linear scores
linscores = function(x, theta) x %*% theta

# computes negative log-likelihood, resturns a numerical scalar
objective = function(theta, x, y) {
  lins = linscores(x, theta)
  s = softmax2(lins)
  p = vnapply(1:nrow(x), function(i) s[i,y[i]])
  -sum(log(p))
}

# trains softmax regression 
# uses very simply gradient descent on the theta matrix
#   maxit: number of GD steps
#   step.size: simple step.size for a GD step
# returns: list with theta matrix of "optimal" found coefficients 
trainSoftmaxRegr1 = function(x, y, maxit = 100L, step.size = 0.0001) {
  n = nrow(x); p = ncol(x); g = max(y)  # The number of levels
  theta = matrix(0, nrow = p, ncol = g)
  dummies = data.frame(y = factor(y, levels = 1:3))
  dummies = model.matrix(~y-1, data = dummies)
  for (iter in 1:maxit) {
    grad = matrix(0, nrow = p, ncol = g)
    lins = linscores(x, theta)
    s = softmax2(lins)
    r = dummies - s
    for (i in 1:n) {
      x1 = x[i,] 
      gradi = - r[i,] %*% t(x1)
      grad = grad + t(gradi)
    }
    theta = theta - step.size * grad 
    obj = objective(theta, x, y)
    messagef("obj = %f", obj)
  }
  theta = theta - theta[,g]
  list(theta = theta, loss = obj)
}

# trains softmax regression 
# returns: list with theta matrix of "optimal" found coefficients 
trainSoftmaxRegr2 = function(x, y, maxit = 100L, step.size = 0.0001) {
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
  lins = linscores(x, model$theta)
  probs = softmax(lins)
  classes = getMaxIndexOfRows(probs)
  err = NULL
  if (!is.null(y))
    err = mean(y != classes)
  list(classes = classes, probs = probs, err = err)
}

# set.seed(123)

# p = 1
# n1 = 5
# g = 3
# n = g*n1
# x1 = runif(n1, min = 0, max = 10)
# x2 = runif(n1, min = 5, max = 15)
# x3 = runif(n1, min = 15, max = 25)

# x = matrix(c(x1, x2, x3), ncol = 1L)
# y = rep(1:3, each = n1)

# m = trainSoftmaxRegr(x, y, maxit = 100)
# print(or$par)
# print(or$value)


x = as.matrix(iris[, 1:4])
x = cbind(x, 1)
y = as.integer(iris[,5])
m1 = trainSoftmaxRegr1(x, y, step.size = 0.0001, maxit = 5000)
print(m1)
m2 = trainSoftmaxRegr2(x, y)
print(m2)
p1 = predictSoftmaxRegr(m1, x, y)
print(p1$err)
p2 = predictSoftmaxRegr(m2, x, y)
print(p2$err)


