source("lt_softmax.R")
library(BBmisc)
library(mlr)

source("lt_a_1.problem.R")
df = gen3class()
theta = minit(df, tname = "Species")
p = 2
mt_theta = theta 
theta
i = 1  # first class
miter(df[1, 1L:p], df[1, tname], theta, alpha = 0.001)
i = 150 # third class
miter(df[150, 1L:p], df[150, tname], theta, alpha = 0.001)
i = 50 # second class
miter(df[50, 1L:p], df[50, tname], theta, alpha = 0.001)

theta_10 = mtrain(theta, df, niter = 10, alpha = 0.00001, lambda = 1)
theta_20 = mtrain(theta_10, df, niter = 10, alpha = 0.00001, lambda = 1)
theta_50 = mtrain(theta_20, df, niter = 40, alpha = 0.00001, lambda = 1)
theta_100 = mtrain(theta, df, nniter = 50, alpha = 0.0001, lambda = 0.01, thres = 0.000001)
theta_200 = mtrain(theta, df, niter = 200, alpha = 0.00001, lambda = 0)
theta_500 = mtrain(theta_200, df, niter = 300, alpha = 0.00001, lambda = 1)
theta_1000 = mtrain(theta_200, df, niter = 800, alpha = 0.00001, lambda = 1)
theta_1300 = mtrain(theta_1000, df, niter = 300, alpha = 0.00001, lambda = 1)
theta_2000 = mtrain(theta_1000, df, niter = 1000, alpha = 0.00001, lambda = 1)

X = as.matrix(df[,1:p]) 


yhat0 = mpred(theta, X)
yhat10 = mpred(theta_10, X)
yhat20 = mpred(theta_20, X)
yhat50 = mpred(theta_50, X)

yhat100 = mpred(theta_100, X)
yhat200 = mpred(theta_200, X)
yhat500 = mpred(theta_500, X)
yhat1000 = mpred(theta_1000, X)
yhat1300 = mpred(theta_1300, X)
yhat2000 = mpred(theta_2000, X)

mperf = function(yhat, df, tname = "Species"){
  sum(yhat == df[,tname])/150.0
}

mperf(yhat0, df)
mperf(yhat1000, df)
mperf(yhat1300, df)
mperf(yhat2000, df)

unique(yhat0)
unique(yhat10) 
unique(yhat20) 
unique(yhat50) 

unique(yhat100)
unique(yhat200)
hist(yhat100)
hist(yhat200)
hist(yhat500)
hist(yhat1000)
hist(yhat1300)
hist(yhat2000) 
