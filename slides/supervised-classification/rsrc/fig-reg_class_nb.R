# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(MASS)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(mvtnorm)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(123)

n = 300

classa = data.frame(mvrnorm(n = n, 
                            mu = c(2, 2), 
                            Sigma = matrix(c(2, 0, 0, 2), 
                                           ncol = 2, 
                                           byrow = TRUE)))

classb = data.frame(mvrnorm(n = n, 
                            mu = c(10, 7), 
                            Sigma = matrix(c(8, -6, -6, 8), 
                                           ncol = 2, 
                                           byrow = TRUE)))

df = cbind(classa, factor(rep("a", ncol(classa))))
colnames(df) = c("x1", "x2", "y")

foo = cbind(classb, factor(rep("b", ncol(classb))))
colnames(foo) = c("x1", "x2", "y")

df = rbind(df, foo)

task = TaskClassif$new("gauss_task", 
                       backend = df, 
                       target = "y", 
                       positive = "a")

learner = lrn("classif.naive_bayes", predict_type = "prob")
learner$train(task)

tab = learner$model$tables
mus = data.frame(x1 = tab$x1[, 1], x2 = tab$x2[, 1])
mu1 = as.numeric(mus[1,])
mu2 = as.numeric(mus[2,])
sds = data.frame(x1 = tab$x1[, 2], x2 = tab$x2[, 2])
S1 = diag(sds[1, ]) 
S2 = diag(sds[2, ]) 

x1seq = seq(min(df$x1), max(df$x1), length.out = 100)
x2seq = seq(min(df$x2), max(df$x2), length.out = 100)

grid_dens1 = 
  grid_dens2 = 
  expand.grid(x1 = x1seq, 
              x2 = x2seq)

grid_dens1$dens = dmvnorm(grid_dens1, mean = mu1, sigma = S1)
grid_dens2$dens = dmvnorm(grid_dens2, mean = mu2, sigma = S2)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_nb_1.pdf", width = 8, height = 3.5)

pl = plot_learner_prediction(learner, task)
pl = pl + guides(shape = FALSE, alpha = FALSE)
pl = pl + scale_fill_viridis_d(end = .9)
pl = pl + geom_contour(data = grid_dens1, 
                       aes(z = dens), 
                       alpha = .6, 
                       lwd = 1.5, 
                       bins = 10) 
pl = pl + geom_contour(data = grid_dens2, 
                       aes(z = dens), 
                       alpha = .6, 
                       lwd = 1.4, 
                       bins = 10) 
print(pl)

ggsave("../figure/reg_class_nb_1.pdf", width = 8, height = 3.5)
dev.off()