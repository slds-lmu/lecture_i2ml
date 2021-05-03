

library(ggplot2)
library(gridExtra)
library(randomForest)
library(colorspace)
library(mlr)
library(mboost)
library(mlbench)

source("rsrc/cim1_optim.R")
############################################# APPROXIMATE SPLIT-FINDING ALGORITHMS
########## global
n = 5000
bins = 100
set.seed(123)
data = rexp(n,  0.5)
q = quantile(data, seq(0,1, by = 0.1))
split = q[8]
p1 = ggplot(data = data.frame(x1 = data), aes(x = x1)) + geom_histogram(bins = bins) + geom_vline(xintercept = q, color = "blue", linetype = 2) + xlim(0, 12) + geom_vline(xintercept = split, color = "red") + ylim(0, 500)
p2 = ggplot(data = data.frame(x1 = data[data > split]), aes(x = x1)) + geom_histogram(bins = bins/2) + geom_vline(xintercept = q, color = "blue", linetype = 2) + geom_vline(xintercept = split, color = "red")+ xlim(0, 12) + ylim(0, 500)
p3 =  ggplot(data = data.frame(x1 = data[data <= split]), aes(x = x1)) + geom_histogram(bins = bins/2) + geom_vline(xintercept = q, color = "blue", linetype = 2) + geom_vline(xintercept = split, color = "red")+ xlim(0, 12) + ylim(0, 500)
grid.arrange(p1, p2, p3, layout_matrix = matrix(c(1,3,1,2), ncol = 2), nrow = 2)

############################################################
########## local
p1 = ggplot(data = data.frame(x1 = data), aes(x = x1)) + geom_histogram(bins = bins) + geom_vline(xintercept = q, color = "blue", linetype = 2) + xlim(0, 12) + geom_vline(xintercept = split, color = "red") + ylim(0, 500)
q2 = quantile(data[data > split], seq(0,1, by = 0.1))
p2 = ggplot(data = data.frame(x1 = data[data > split]), aes(x = x1)) + geom_histogram(bins = bins/2) + geom_vline(xintercept = q2, color = "blue", linetype = 2) + geom_vline(xintercept = split, color = "red")+ xlim(0, 12) + ylim(0, 500)
q3 = quantile(data[data <= split], seq(0,1, by = 0.1))
p3 =  ggplot(data = data.frame(x1 = data[data <= split]), aes(x = x1)) + geom_histogram(bins = bins/2) + geom_vline(xintercept = q3, color = "blue", linetype = 2) + geom_vline(xintercept = split, color = "red")+ xlim(0, 12) + ylim(0, 500)
grid.arrange(p1, p2, p3, layout_matrix = matrix(c(1,3,1,2), ncol = 2), nrow = 2)

