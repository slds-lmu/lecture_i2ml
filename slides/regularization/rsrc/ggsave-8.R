
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)

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
    ylab(expression(theta[2])) 
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


x1 <- seq(0,1.5,length.out = 100)
x2 <- seq(0,3.5,length.out = 100)

beta_start <- c(0, 0)
step_size <- 0.005
grad <- R_emp_grad
num_steps <- 100

gd_betas <- gradient_descent(beta_start, step_size, grad, num_steps)

# R_emp plot
remp_plot <- plot_r_emp(R_emp, x1, x2) +
  geom_path(data = gd_betas, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_point(data = gd_betas, aes(x=V1, y=V2), colour = "white") +
  labs(fill=expression(R[emp]), caption=expression(~Gradient~descent~over~R[emp]))  +
  theme(legend.position="none")

# R_reg plot

lambda <- 10
num_steps <- 100
gd_l2_betas <- gradient_descent(beta_start, step_size, 
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot <-  plot_r_emp(R_emp, x1, x2) + 
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +  
  labs(fill=expression(R[reg]), caption=expression(~Weight~decay~over~R[emp])) + 
  theme(legend.position="none") 

grid.arrange(remp_plot, remp_l2_plot, ncol=2)

##########################################################

lambda <- 5
num_steps <- 100
gd_l2_betas <- gradient_descent(beta_start, step_size, 
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot_1 <-  plot_r_emp(R_emp, x1, x2) + 
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +  
  labs(fill=expression(R[reg]), 
       caption=expression(~Weight~decay~'(small '~lambda~')'~over~R[emp])) +   theme(legend.position="none") 

lambda <- 50
gd_l2_betas <- gradient_descent(beta_start, step_size, 
                                function(beta) R_reg_l2_grad(beta, lambda), num_steps)

ret <- weight_decay(beta_start, lambda, step_size, R_emp_grad, num_steps)

remp_l2_plot_2 <-  plot_r_emp(R_emp, x1, x2) + 
  geom_path(data = ret$betas_gd, aes(x=V1, y=V2), colour = "red", size=1.1) +
  geom_path(data = ret$betas_wd, aes(x=V1, y=V2), colour = "yellow", size=1.1) +
  geom_point(data = gd_l2_betas, aes(x=V1, y=V2), colour = "white") +  
  labs(fill=expression(R[reg]), 
       caption=expression(~Weight~decay~'(large '~lambda~')'~over~R[emp])) + 
  theme(legend.position="none") 


grid.arrange(remp_l2_plot_1 , remp_l2_plot_2 , ncol=2)

##############################################################

R_emp_hessian <- function(features = X){
  return(2 * t(features)%*%(features))
}

theta_min <- gd_betas[num_steps,]
hessian <- R_emp_hessian()

eig_dec <- eigen(hessian)
Q <- eig_dec$vectors
S <- diag(eig_dec$values)

theta_min_rot <-  t(Q) %*% t(as.matrix(theta_min))
theta_min_rot_data <- as.data.frame(t(theta_min_rot))

theta_proj1 <- Q[,1] * (Q[,1] %*% t(as.matrix(theta_min)))[1]
theta_proj2 <- Q[,2] * (Q[,2] %*% t(as.matrix(theta_min)))[1]

theta_proj1_data <- as.data.frame(t(theta_proj1))
theta_proj2_data <- as.data.frame(t(theta_proj2))

theta_min_skew <- solve(S + diag(rep(lambda, length(eig_dec$values)))) %*% 
  S %*% theta_min_rot
theta_min_skew_data <- as.data.frame(t(theta_min_skew))

theta_min_ridge_data <- as.data.frame(t(Q %*% theta_min_skew))

x1 <- seq(-1.5,2,length.out = 100)
x2 <- seq(-1,3.5,length.out = 100)

# R_emp 
init_cond_plot <- plot_r_emp(R_emp, x1, x2) + 
  annotate("label", x = 0.75, y = 3, label = "hat(theta)",
           parse = TRUE, color = 'black', size = 4, fill = "red") +
  theme(legend.position="none") + coord_fixed() +
  geom_hline(yintercept = 0, colour="darkgrey", size=2) +
  geom_vline(xintercept = 0, colour="darkgrey", size=2) +  
  geom_line(data=rbind(rep(0, num_features), theta_min),
            aes(x=V1, y=V2), colour="red", size=1.1, arrow = arrow()) 

rot_plot <- plot_r_emp(R_emp, x1, x2) + 
  theme(legend.position="none") + coord_fixed() +
  geom_abline(slope = Q[2,1]/Q[1,1], colour="darkgrey", size=2) +
  geom_abline(slope = Q[2,2]/Q[1,2], colour="darkgrey", size=2) +  
  geom_line(data=rbind(rep(0, num_features), theta_min),
            aes(x=V1, y=V2), colour="red", size=1.1, arrow = arrow()) +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=theta_proj1_data ), size=1.1,
               arrow=arrow(type="closed"),
               linetype="dashed", aes(x=start.V1, y=start.V2, xend = end.V1, yend = end.V2),
               colour = "green", arrow.fill = "green") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=theta_proj2_data ), size=1.1,
               arrow=arrow(type="closed"),
               linetype="dashed", aes(x=start.V1, y=start.V2, xend = end.V1, yend = end.V2),
               colour = "green", arrow.fill = "green") 

grid.arrange(init_cond_plot, rot_plot, ncol=2)

#########################################################

grid.arrange(rot_plot, init_cond_plot, ncol=2)

##########################################################

lambda <- 50

rs <- sapply(1:2, function(i) S[i,i] / (S[i,i] + lambda))

scale_rot_plot <- rot_plot +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] ), size=1.1,
               arrow=arrow(type="closed"),
               linetype="dashed", aes(x=start.V1, y=start.V2, 
                                      xend = end.V1, yend = end.V2),
               colour = "orange", arrow.fill = "orange") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj2_data*rs[2] ), size=1.1,
               arrow=arrow(type="closed"),
               linetype="dashed", aes(x=start.V1, y=start.V2, 
                                      xend = end.V1, yend = end.V2),
               colour = "orange", arrow.fill = "orange") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] +
                            theta_proj2_data*rs[2] ), size=1.1,
               arrow=arrow(),
               linetype="solid", aes(x=start.V1, y=start.V2, 
                                     xend = end.V1, yend = end.V2),
               colour = "yellow")  

scale_plot <- init_cond_plot +
  annotate("label", x = 1.3, y = 1.5, label = "hat(theta)[Ridge]",
           parse = TRUE, color = 'black', size = 4, fill = "yellow") +
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=
                            theta_proj1_data*rs[1] +
                            theta_proj2_data*rs[2] ), size=1.1,
               arrow=arrow(),
               linetype="solid", aes(x=start.V1, y=start.V2, 
                                     xend = end.V1, yend = end.V2),
               colour = "yellow")  

grid.arrange(scale_rot_plot, scale_plot, ncol=2)

########################################################









