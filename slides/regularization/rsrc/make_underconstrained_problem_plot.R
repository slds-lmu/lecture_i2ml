# ------------------------------------------------------------------------------
# FIG: UNDER-CONSTRAINED PROBLEM
# ------------------------------------------------------------------------------

library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(viridis)

# DATA -------------------------------------------------------------------------

y <- as.numeric(as.character(X$type[1:6]))
emp_risk_all_cor <- function(theta){
  sum(log(1 + exp(-y * (cor_X %*% theta))))
}

emp_risk_all_cor_ridge <- function(theta, lambda=0.5){
  sum(log(1 + exp(-y * (cor_X %*% theta)))) + lambda/2*sqrt(sum(theta^2))
}

x1 <- seq(0,20,length.out = 200)
x2 <- seq(0,-20,length.out = 200)

eval_grid <- expand.grid(x1,x2)

res <- eval_grid
res$r_emp <- apply(eval_grid, 1, emp_risk_all_cor)
res$r_reg <- apply(eval_grid, 1, emp_risk_all_cor_ridge)

# PLOTS ------------------------------------------------------------------------

plot_emp <-ggplot(res) +
  geom_raster(aes(x=Var1, y=Var2, fill=r_emp)) +
  geom_contour(aes(x=Var1, y=Var2, z=r_emp), colour="white") +
  xlab(expression(theta[1])) +
  ylab(expression(theta[2])) +
  labs(fill=expression(R[emp]), caption=expression('non-regularized '~R[emp])) +
  coord_fixed() +
  coord_fixed() +
  geom_abline(slope = -1, intercept=0, colour="white", linetype="dashed", size=1) +
  scale_fill_viridis(end = 0.9)

plot_reg <- ggplot(res) +
  geom_raster(aes(x=Var1, y=Var2, fill=r_emp)) +
  geom_contour(aes(x=Var1, y=Var2, z=r_reg), colour="white") +
  xlab(expression(theta[1])) +
  ylab(expression(theta[2])) +
  labs(fill=expression(R[reg]), caption=expression('L2 regularized '~R[emp])) +
  coord_fixed() + geom_abline(slope = -1, intercept=0, colour="white",
                              linetype="dashed", size=1) +
  scale_fill_viridis(end = 0.9)


p <- grid.arrange(plot_emp, plot_reg, ncol=2)

ggsave("../figure/underconstrained_problem.png", plot = p, width = 7, height = 2.5)