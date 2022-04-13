library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(viridis)

set.seed(123)
num_obs <- 100
num_features <- 2

err_std <- 0.5

X <- matrix(runif(num_features * num_obs), ncol = num_features)
beta_true <- c(0.5, 3)

y <- X %*% beta_true + rnorm(num_obs, sd = err_std)

R_emp <- function(beta, features = X, target = y){
  return(sum((features %*% beta - target)^2))
}

R_emp_hessian <- function(features = X){
  return(2 * t(features)%*%(features))
}

R_reg_l2 <- function(beta, lambda = 0.1, features = X, target = y){
  return(R_emp(beta, features, target) + (0.5*lambda * sum(beta^2)))
}

plot_r_emp <- function(r_emp, x1, x2){
  eval_grid <- expand.grid(x1,x2)
  eval_grid$r_emp <- apply(eval_grid, 1, r_emp)

  ggplot(eval_grid) +
    geom_raster(aes(x=Var1, y=Var2, fill=r_emp)) +
    geom_contour(aes(x=Var1, y=Var2, z=r_emp), colour="white") +
    xlab(expression(theta[1])) +
    ylab(expression(theta[2])) +
    scale_fill_viridis(end = 0.9)
}

R_emp_grad <- function(beta, features = X, target = y){
  return(2 * t(features)%*%(features %*% beta - target))
}

R_reg_l2_grad <- function(beta, lambda, features = X, target = y){
  return((2 * t(features)%*%(features %*% beta - target) +
            lambda*beta))
}

gradient_descent <- function(beta_start, step_size, grad_fun, num_steps){
  betas <- matrix(0, ncol=length(beta_start), nrow=num_steps)
  betas[1, ] <- beta_start
  for(i in seq(2,num_steps)){
    betas[i, ] <- betas[i-1, ] - step_size * grad_fun(betas[i-1,])
  }

  betas <- as.data.frame(betas)
  return(betas)
}

weight_decay <- function(beta_start, lambda, step_size, unreg_grad_fun,
                         num_steps){
  betas_wd <- matrix(NA, ncol=length(beta_start), nrow=(num_steps)*3)
  betas_wd[1, ] <- beta_start

  betas_gd <- matrix(NA, ncol=length(beta_start), nrow=(num_steps-1)*3)

  for(i in seq(1, 3 * (num_steps-1), 3)){
    betas_wd[i+1, ] <- betas_wd[i, ]*(1-step_size*lambda)
    betas_gd[i, ] <- betas_wd[i+1, ]
    betas_gd[i+1, ] <- betas_gd[i, ] - step_size * unreg_grad_fun(betas_wd[i,])
    betas_wd[i+3, ] <- betas_gd[i+1, ]
  }

  return(list(betas_wd = as.data.frame(betas_wd),
              betas_gd = as.data.frame(betas_gd)))
}