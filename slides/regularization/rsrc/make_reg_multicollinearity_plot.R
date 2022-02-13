
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

######################################################


source("make_regu_example_multicollinearity_plot.R")

lambda_seq_mc <- 2^seq(-10, 20, length.out = 50)

path_l1_mc <- compute_coef_paths(task_mc, "lambda1", lambda_seq_mc)
path_l2_mc <- compute_coef_paths(task_mc, "lambda2", lambda_seq_mc)

p_l1 <- plot_coef_paths_mc(path_l1_mc, featnames_mc, "Lasso / lambda")
p_l2 <- plot_coef_paths_mc(path_l2_mc, featnames_mc, "Ridge / lambda")

p <- grid.arrange(p_l1, p_l2, nrow = 1)

p