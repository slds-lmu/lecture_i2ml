################################################################################
################################################################################
####### simulation of data for ridge, elasticnet and lasso #####################
################################################################################
################################################################################
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(gridExtra)
library(glmnet)
library(caret)
library(mvtnorm)


#
#function for calculating:
# with mvtnorm make 
#' @return: a list of:
#[1] errors
#[2] coffecients with ridge
#[3] coefficients with elasticnet
#[4] coefficients with lasso 
#
#input 
#
#' @param m number of data sets
#' @param beta vector with beta
#' @param p length of beta
#' @param sig covariance matrix
#' @param n number of observations in data set
#' @param sd standard eviation of error added on simulated data
#inspiration https://www4.stat.ncsu.edu/~post/will/AdaptiveLASSOSim.R

get_errors <- function (m, beta, p = length(beta), sig, n, sd){
  # create simulated data
  x <- list()
  y <- list()
  
  for (i in 1:m) {
    x[[i]] <- rmvnorm(n = n, mean = c(rep(0, p)), sigma = sig)
    
    # standardize x's
    for (j in 1:p) {
      x[[i]][, j] <- (x[[i]][, j] - mean(x[[i]][, j])) / sd(x[[i]][, j])
    }
    
    y[[i]] <- x[[i]] %*% beta
    y[[i]] <- y[[i]] + rnorm(n, mean = 0, sd = sd)
    y[[i]] <- y[[i]] - mean(y[[i]])
  }
  
  
  lasso <- ridge <- elasticnet <- matrix(c(0), ncol = p, nrow = m)
  
  #calcualte for all datasets m the coefficients with lasso, rdige or elastic net
  for (i in 1:m) {
    
    # alpha = 0 --> Ridge
    cv_ridge <- cv.glmnet(x = x[[i]], y = y[[i]], alpha = 0)
    optimal_lambda_ridge <- cv_ridge$lambda.min
    
    ridge_temp <- glmnet(x = x[[i]], y = y[[i]], alpha = 0, lambda = optimal_lambda_ridge)
    ridge[i, ] <- as.vector(ridge_temp$beta)
    
    
    # alpha = 1 --> LASSO
    cv_lasso <- cv.glmnet(x = x[[i]], y = y[[i]], alpha = 1)
    optimal_lambda_lasso <- cv_lasso$lambda.min
    
    lasso_temp <- glmnet(x = x[[i]], y = y[[i]], alpha = 1, , lambda = optimal_lambda_lasso)
    lasso [i, ] <- as.vector(lasso_temp$beta)
    
    
    data <- cbind(y[[i]], x[[i]])
    colnames(data) <- c("y", seq(1,p)) 
    
    #cv for elastic net: finding alpha and lambda
    elastic_param <- caret::train(
      y ~., data = data, method = "glmnet",
      trControl = trainControl("cv", number = 10),
      tuneLength = 10)
    
    elasticnet_temp <- glmnet(x = x[[i]], y = y[[i]], alpha = elastic_param$bestTune [1], lambda = elastic_param$bestTune[2])
    
    elasticnet[i, ] <- as.vector(elasticnet_temp$beta)
  }
  
  #get errors
  error_df <- as.data.frame(matrix(data = NA, nrow = 0, ncol = 2))
  names(error_df) <- c("reg", "error")
  
  #MSE for all possible 
  for (i in 1:m) {
    error_ridge  <- t(ridge[i, ] - beta) %*% (ridge[i, ] - beta)
    error_lasso  <- t(lasso[i, ] - beta) %*% (lasso[i, ] - beta)
    error_elasticnet  <- t(elasticnet[i, ] - beta)%*%(elasticnet[i, ] - beta)
    
    
    error_df <- rbind( error_df, data.frame(reg = "ridge", error = error_ridge),data.frame(reg = "elasticnet", error = error_elasticnet),
                       data.frame(reg = "lasso", error = error_lasso))
  }
  
  list(error_df, ridge, elasticnet, lasso)
}


################################################################################
################################################################################
#setting different parameters


#########
# simulation: ridge is better then lasso

set.seed(123)

# number of data sets
m <- 50

# True beta vector
beta <- c(rep(2,5), rep(0,5))

# Define number of predictors
p_ridge_better <- length(beta)

# Create covariance matrix for the x's
a <- diag(p_ridge_better)

#covariance matrix 
sig <- 0.8^abs(row(a) - col(a)) #a* 0.5#

#number of observations
n <- 100

#sd for noise
sd <- 1

result_ridge <-get_errors(m, beta, p_ridge_better, sig, n, sd)



################################################################################
################################################################################
#########
# simulation: lasso is better then lasso


set.seed(123)
# number of data sets
m <- 50

# True beta vector
beta <- c(rep(2,3), rep(0,7))

# Define number of predictors
p_lasso_better <- length(beta)


sig <- diag(p_lasso_better) #0.5^abs(row(a) - col(a)) #a* 0.5#

# number of observations
n <- 100

#sd
sd <- 1


result_lasso <- get_errors(m, beta, p_lasso_better, sig, n, sd )


################################################################################
################################################################################
#extracting list from simulation function, save and prepare for ploting

error_ridge_better <- as.data.frame(result_ridge [1])
save(error_ridge_better,file="rsrc/error_ridge_better.Rda")

error_lasso_better <- as.data.frame(result_lasso[1])
save(error_lasso_better,file="rsrc/error_lasso_better.Rda")


beta_ridge_better <- rbind(
  data.frame(reg = "ridge", result_ridge [2]),
  data.frame(reg= "elasticnet", result_ridge [3]),
  data.frame(reg= "lasso",  result_ridge [4]))
colnames(beta_ridge_better) <- c("reg", c(1:p_ridge_better))
p_plus_1 <- p_ridge_better+1
beta_ridge_better <- tidyr::gather(beta_ridge_better, "index","beta", 2:p_plus_1)

save(beta_ridge_better,file="rsrc/beta_ridge_better.Rda") 

beta_lasso_better <- rbind(
  data.frame(reg = "ridge", result_lasso [2]),
  data.frame(reg= "elasticnet", result_lasso [3]),
  data.frame(reg= "lasso",  result_lasso [4]))
colnames(beta_lasso_better) <- c("reg", c(1:p_lasso_better))
p_plus_1 <- p_lasso_better+1
beta_lasso_better <- tidyr::gather(beta_lasso_better, "index","beta", 2:p_plus_1)

save(beta_lasso_better,file="rsrc/beta_lasso_better.Rda")

################################################################################
################################################################################
################################################################################
# test plots:

# MSE in boxplot of different algorithms
p1 <- ggplot(data = error_ridge_better, aes(x = error, y = factor(reg))) +
  geom_boxplot() +
  coord_flip() + 
  ylab("") +
  xlab("MSE")+ 
  theme_gray(base_size = 14)+
  #scale_fill_viridis_d(limits=c("ridge", "elasticnet", "lasso"))+
  theme(legend.position="none")



p2 <- ggplot(data = error_lasso_better, aes(x = error, y = factor(reg))) +
  geom_boxplot() +
  coord_flip() + 
  ylab("") +
  xlab("MSE")+
  theme_gray(base_size = 14)+
  #scale_fill_viridis_d(limits=c("ridge", "elasticnet", "lasso"))+ 
  theme(legend.position="none")

# distribution of beta
p3 <- ggplot(data = beta_ridge_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge") +
  coord_flip()+
  facet_grid(reg~.)+
  xlab("value") +
  ylab("index of beta")+
  scale_y_continuous(breaks=c(1:10))

p4 <- ggplot(data = beta_lasso_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge") +
  coord_flip()+
  facet_grid(reg~.) +
  xlab("value") +
  ylab("index of beta") +
  scale_y_continuous(breaks=c(1:12))




grid.arrange(p1, p2 ,
             p3, p4 , nrow=2)

################################################################################
################################################################################




