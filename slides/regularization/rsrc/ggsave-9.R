
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

R_emp_hessian <- function(features = X){
  return(2 * t(features)%*%(features))
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

prc <- prcomp(X , scale. = FALSE)
X_dc <- prc$x
X_dc[,1] = X_dc[,1]/2

colnames(X_dc) <- NULL

hessian <- R_emp_hessian(X_dc)

x1 <- seq(-4, 2.5,length.out = 100)
x2 <- seq(-4, 5,length.out = 100)

df <- data.frame(X = X_dc, y = y)

res <- lm(y ~ ., df) 
y_new <- y - res$coefficients[1]
theta_hat <- t(res$coefficients[2:3])
colnames(theta_hat) <- NULL

lambda <- 10
theta_l1_reg <- sign(theta_hat) * pmax(abs(theta_hat) - lambda / diag(hessian),0)

init_plot_l1 <- plot_r_emp(function(beta) R_emp(beta, features = X_dc, target = y_new), 
                           x1, x2) +
  theme(legend.position = "none") +
  coord_fixed() +
  annotate("label", x = -1, y = 3.5, label = "hat(theta)",
           parse = TRUE, color = 'black', size = 4, fill = "red") +
  geom_hline(yintercept = 0, colour="lightblue",
             linetype = "dashed", alpha= 0.8, size = 1.1) +
  geom_vline(xintercept = 0, colour="lightblue",
             linetype = "dashed", alpha= 0.8, size = 1.1) +
  geom_line(data=rbind(rep(0, num_features), as.data.frame(theta_hat)),
            aes(x=V1, y=V2), colour="red", size=1.1, arrow = arrow(ends = "first")) +
  geom_vline(xintercept = -lambda/hessian[1,1], colour="yellow",
             linetype = "dashed", alpha= 0.8, size = 1.1) +
  annotate("label", x = -2, y = -2.5, label =
             "frac(-lambda, H[\"1,1\"])",
           parse = TRUE, color = 'black', size = 4, fill = "yellow") 

theta_hat_1 <- theta_hat
theta_hat_1[,1] = 0


plot_l1_theta1 <- init_plot_l1 +
  # geom_polygon(data = data.frame(x = c(theta_hat[,1], theta_hat[,1], 0, 0), 
  #                               y = c(-Inf, Inf, Inf, -Inf)),
  #         aes(x,y), fill="white", alpha=0.5) + 
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=as.data.frame(theta_hat_1)),
               aes(x=start.V1, y=start.V2, 
                   xend = end.V1, yend = end.V2), colour="green", 
               linetype="dashed",
               size=1.1, arrow = arrow(ends = "last", type="closed"),
               arrow.fill = "green")

grid.arrange(init_plot_l1, plot_l1_theta1, ncol=2)

###################################################################


theta_hat_2 <- theta_hat
theta_hat_2[,2] = theta_l1_reg[2]


plot_l1_theta2 <- init_plot_l1 +
  geom_hline(yintercept = lambda/hessian[2,2], colour="yellow",
             linetype = "dashed", alpha= 0.8, size = 1.1) +
  #      geom_polygon(data = data.frame(x = c(-Inf, Inf, Inf, -Inf), 
  #                                     y = c(theta_hat[,2], theta_hat[,2], 0, 0)),
  #               aes(x,y), fill="white", alpha=0.5) + 
  geom_segment(data=cbind(start=as.data.frame(t(c(0,0))), end=as.data.frame(theta_hat_2)),
               aes(x=start.V1, y=start.V2, 
                   xend = end.V1, yend = end.V2), colour="green", 
               linetype="dashed",
               size=1.1, arrow = arrow(ends = "last", type="closed"),
               arrow.fill = "green")+
  annotate("label", x = -3, y = 2, label =
             "frac(lambda, H[\"2,2\"])",
           parse = TRUE, color = 'black', size = 4, fill = "yellow") 

plot_l1_theta_lasso <- plot_l1_theta2 +
  geom_line(data=rbind(rep(0, num_features), as.data.frame(theta_l1_reg)),
            aes(x=V1, y=V2), colour="orange", size=1.1, arrow = arrow(ends = "last")) +
  annotate("label", x = 1.1, y = 1.5, label = "hat(theta)[\"Lasso\"]",
           parse = TRUE, color = 'black', size = 4, fill = "orange")

grid.arrange(plot_l1_theta2, plot_l1_theta_lasso, ncol=2)