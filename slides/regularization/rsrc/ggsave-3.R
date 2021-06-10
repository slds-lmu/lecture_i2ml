
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(tidyr)
library(colorspace)
library(BBmisc)
library(data.table)
library(penalized)
library(reshape)
library(gridExtra)
#######################################################

library(ggrepel)
load("rsrc/regu_example_1.RData")
plot_coef_paths = function(path, featnames, xlab) {
  ggd = melt(path, efs, id.var = "lambda", measure = featnames, variable.name = "featname", value.name = "coefval")
  ggd$label = ifelse(ggd$lambda == min(lambda_seq), as.character(ggd$featname), NA)
  pl = ggplot(data = ggd, aes(x = lambda, y = coefval, group = featname, col = featname))
  pl = pl + geom_line()
  pl = pl + geom_label_repel(aes(label = label), na.rm = TRUE)
  pl = pl + scale_color_discrete(guide = FALSE)
  pl = pl + scale_x_log10()
  pl = pl + xlab(xlab)
  pl = pl + theme_bw()
}
plot_cv_path = function(cv_lam, xlab) {
  pl = ggplot(data = cv_lam, aes(x = lambda, y = mse))
  pl = pl + geom_line()
  pl = pl + scale_x_log10()
  pl = pl + xlab(xlab)
}
pl1 = plot_coef_paths(path_l1$path, featnames, "Lasso / lambda")
pl2 = plot_coef_paths(path_l2$path, featnames, "Ridge / lambda")
pl3 = plot_cv_path(path_l1$cv_lam, "Lasso / lambda") + ylim(25,90) 
pl4 = plot_cv_path(path_l2$cv_lam, "Ridge / lambda") + ylim(20,90)
grid.arrange(pl1, pl2, pl3, pl4, nrow = 2)

###########################################################

load("rsrc/regu_example_2.RData")
d_l1 = rbind(
  data.frame(lam = paste("L1-", lams[1]), coefval = cc_l1_1),
  data.frame(lam = paste("L1-", lams[2]), coefval = cc_l1_2)
)
d_l1$lam = as.factor(d_l1$lam)
d_l2 = rbind(
  data.frame(lam = paste("L2-", lams[1]), coefval = cc_l2_1),
  data.frame(lam = paste("L2-", lams[2]), coefval = cc_l2_2)
)
d_l2$lam = as.factor(d_l2$lam)
plot_coef_hist = function(d) {
  pl = ggplot(d, aes(x = coefval, fill = lam))
  pl = pl + geom_histogram(alpha = 0.9, position = "dodge") + theme_gray(base_size = 14)
  return(pl)
}
plot_cv_path = function(cv_lam, xlab) {
  pl = ggplot(data = cv_lam, aes(x = lambda, y = mse))
  pl = pl + geom_line()
  pl = pl + scale_x_log10()
  pl = pl + ylim(1, 10)
  pl = pl + xlab(xlab) + theme_gray(base_size = 14)
}
pl1 = plot_coef_hist(d_l1) + guides(fill=guide_legend(title="lambda"))
pl2 = plot_coef_hist(d_l2)+ guides(fill=guide_legend(title="lambda")) +
  ylim(0, 50)
pl3 = plot_cv_path(cv_l1, "lambda")
pl4 = plot_cv_path(cv_l2, "lambda")
grid.arrange(pl1, pl2, pl3, pl4, nrow = 2)

#######################################################

library(glmnet)
set.seed(2020-06-03)
# create data => 100 x 5 matrix (5 features)
X = matrix(rnorm(100 * 5), 100, 5)
colnames(X) <- paste0("x",1:5)
# response only relates to first feature
y = X[,1] + rnorm(100)
# fit Lasso with lambda = 0.5
fit1 = glmnet(X, y)
# print model coefficients
round(t(as.matrix(coef(fit1, s = 0.5)))[,1:5],3)

# rescale second feature
X[,2] = X[,2] * 10000
# and turn internal standardization off
fit1 = glmnet(X, y, standardize = FALSE)
round(t(as.matrix(coef(fit1, s = 0.5)))[,1:5],6)
######################################################


source("rsrc/regu_example_multicollinearity.R")

lambda_seq_mc = 2^seq(-10, 20, length.out = 50)

path_l1_mc = compute_coef_paths(task_mc, "lambda1", lambda_seq_mc)
path_l2_mc = compute_coef_paths(task_mc, "lambda2", lambda_seq_mc)

p_l1 = plot_coef_paths_mc(path_l1_mc, featnames_mc, "Lasso / lambda")
p_l2 = plot_coef_paths_mc(path_l2_mc, featnames_mc, "Ridge / lambda")

g = grid.arrange(p_l1, p_l2, nrow = 1)
x = capture.output(print(g))