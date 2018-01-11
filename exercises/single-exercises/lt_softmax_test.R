source("lt_softmax.R")
library(BBmisc)
library(mlr)
df = iris
dic = levels(iris$Species)
df[,1:4] = apply(df[, 1:4], 2, function(x){x/sqrt(var(x))})
df$Species = unlist(lapply(iris$Species, function(x){which(x == dic)}))

# random initialization
p = ncol(df)-1
theta = minit(df, tname = "Species", lastZero = F)
theta
tname = "Species"
set.seed(1L)
feat = setdiff(colnames(df), tname)
df = df[sample(nrow(df)), ]
X = df[, feat]
X = as.matrix(X)
Y = df[, tname]


## test for sgdRowUpdate
i = 1  # first class
i = 50 # second class
i = 150 # third class
for(i in c(1L,50L,150L)) {
  temp = sgdRowUpdate(X[i, ], Y[i], mt_theta_old = theta)
  print(temp)
}

## test for sgd, cost must decrease
sgd(theta, X, Y)

## test for mtrain: labmda * alpha must be smaller than 1 in order to have weight decay

theta_100 = mtrain(theta, X = X[1:100, ], Y = Y[1:100], niter = 100, alpha = 0.001, lambda = 0, thres = 1e-6)
theta_200 = mtrain(theta_200, X = X[1:100, ], Y = Y[1:100], niter = 100, alpha = 0.001, lambda = 0, thres = 1e-6)

# optim(par = theta, fn = mcost, X = X, Y = Y, method = "BFGS")
# optim(par = theta, fn = mcost, gr = mgd.batch, X = X, Y= Y, method = "BFGS")

# test prediction
yhat_te = mpred(theta_200, X[101:150, ])
yhat_tr = mpred(theta_200, X[1:150, ])
mperf(yhat_te, Y[101:150])
mperf(yhat_tr, Y[1:150])

hist(yhat) 
unique(yhat) 
