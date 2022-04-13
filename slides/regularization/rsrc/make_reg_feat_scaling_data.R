library(glmnet)
set.seed(2020-06-03)

# create data => 100 x 5 matrix (5 features)
X <- matrix(rnorm(100 * 5), 100, 5)
colnames(X) <- paste0("x",1:5)
# response only relates to first feature
y <- X[, 1] + rnorm(100)
# fit Lasso with lambda = 0.5
fit1 <- glmnet(X, y)
# print model coefficients
round(t(as.matrix(coef(fit1, s = 0.5)))[,1:5],3)

# rescale second feature
X[,2] <- X[, 2] * 10000
# and turn internal standardization off
fit1 <- glmnet(X, y, standardize = FALSE)
round(t(as.matrix(coef(fit1, s = 0.5)))[,1:5],6)