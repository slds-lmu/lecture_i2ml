# ---- svm_l_4 ----
library(mlbench)
library(kernlab)
library(ggplot2)
library(gridExtra)

f = function(w, b, x)
  sum(w * x) + b

# hinge loss for vector of decision values and labels
hinge = function(f, y)
  pmax(0, 1 - f * y)

# fits linear softmargin svm on data X (matrix), y (+1, -1 labels) and C
# the implementation is PURELY proof-of-concept and sucks in a dozen ways
mysvm = function(X, y, C) {

  obj = function(w, b) {
    f = X %*% w + b
    L = sum(hinge(f, y))
    norm = 0.5 * sum(w^2)
    norm + C * L
  }

  obj2 = function(x) obj(w = x[-1L], b = x[1L])
  p = ncol(X)
  start = rep(0, p + 1L)
  # using neldermead is EXTRMELY stupid here. but who cares....
  res = optim(par = start, fn = obj2, method = "Nelder-Mead",
    control = list(maxit = 1000L))
  par = res$par
  w = par[-1L]
  b = par[1L]
  mod = list(w = w, b = b, obj = res$val)
}


# check on a simple example
set.seed(1L)
data = mlbench.twonorm(n = 100, d = 2)
data = as.data.frame(data)
X = as.matrix(data[, 1:2])
y = data$classes
# recode y
y = ifelse(y == "2", 1, -1)
mod1 = mysvm(X, y, C = 1)
# decision values
f1 = X %*% mod1$w + mod1$b

# compare to kernlab. we CANNOT expect a PERFECT match
mod2 = ksvm(classes~., data = data, kernel = "vanilladot", C = 1, kpar = list(), scaled = FALSE)
f2 = predict(mod2, newdata = data, type = "decision")

print("compare outputs")
print(range(abs(f2 - f1)))

print("compare coeffs")
print(mod1)

print("alpha * y")
print(mod2@coef[[1]])
print("b2")
print(mod2@b)
print("obj2")
print(mod2@obj)

print("recompute w")
print(mod1$w)
print(coef(mod2)[[1]] %*% X[SVindex(mod2), ])

# seems we were reasonably close. puh, lucky....



