library(mlr3) 
library(mlr3viz) 
library(mlr3learners) 

X <- matrix(c(0,0,0.5,0.5,0,1,3,0,0,3,3,3), byrow=TRUE, ncol=2) 
y = c(-1,1,1,-1,-1,-1)*(-1) 

dat = data.frame(X, y = as.factor(y)) 
dat 

tt <- TaskClassif$new(backend = dat, target = "y", id="mydat") 
tt 

cost <- 10
ll <- lrn("classif.svm", cost=cost, type="C-classification", kernel="linear", scale=FALSE) 
ll$param_set 

mlr3viz::plot_learner_prediction(ll, tt) 

ll$train(tt) 
names(ll$model) 
names(ll) 

llsvm <- ll$model 
beta = drop(t(llsvm$coefs)%*%X[llsvm$index,]) 
beta0 = -llsvm$rho   
cat("C = ", cost, "\n")
cat("theta = ", round(beta,3), "\n")
cat("theta0 = ", round(beta0,3), "\n")