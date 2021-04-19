

library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)
library(gridExtra)

x = seq(-5, 5, length.out = 200)
y = x
grid = data.frame(expand.grid(x, y))

grid$l1 = apply(grid[, 1:2], 1, function(x) sum(abs(x)))
grid$l2 = apply(grid[, 1:2], 1, function(x) sum(x^2))
grid$elasticnet = 0.9 * grid$l1 + 0.1 * grid$l2
df = melt(grid, id = c("Var1", "Var2"))

p = ggplot(data = df, aes(x = Var1, y = Var2, z = value, colour = variable))
p = p + geom_contour(bins = 3) + labs(colour = " ")
p = p + scale_colour_discrete(labels = c("L1 (Lasso)", "L2 (Ridge)", "Elastic Net"))
p = p + coord_fixed(ratio = 1)
p = p + xlab(expression(theta[1])) + ylab(expression(theta[2]))
p
#########################################################

load("rsrc/error_ridge_better.Rda")
load("rsrc/error_lasso_better.Rda")


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
grid.arrange(p1, p2 , nrow= 1)

###########################################################

load("rsrc/beta_ridge_better.Rda")
load("rsrc/beta_lasso_better.Rda")
p3 <- ggplot(data = beta_ridge_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge", trim = FALSE, scale = "width") +
  geom_boxplot(width = 0.4, color = "gray50", alpha = 0.5) +
  coord_flip()+
  facet_grid(reg~.)+
  xlab("value") +
  ylab("index of beta")+
  scale_y_continuous(breaks=c(1:10))+
  theme_gray(base_size = 14)

p4 <- ggplot(data = beta_lasso_better, aes(x=as.numeric(beta), y = as.numeric(index), group= as.numeric(index)))+
  geom_violin(position = "dodge", trim = FALSE, scale = "width") +
  geom_boxplot(width = 0.4, color = "gray50", alpha = 0.5) +
  coord_flip()+
  facet_grid(reg~.) +
  xlab("value") +
  ylab("index of beta")+
  scale_y_continuous(breaks=c(1:10))+
  theme_gray(base_size = 14)

grid.arrange(p3, p4 , nrow=1)

#########################################################

source("rsrc/regularized_log_reg.R")



