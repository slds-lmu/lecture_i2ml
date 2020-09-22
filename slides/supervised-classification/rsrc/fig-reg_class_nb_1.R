 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)
library(MASS)
library(data.table)
library(BBmisc)
library(car)


library(party)
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

pdf("../figure/reg_class_nb_1.pdf", width = 8, height = 3.5)

# fake data
n = 300
classa = data.frame(mvrnorm(n = n, mu = c(2,2), Sigma = matrix(c(2, 0, 0, 2), ncol = 2, byrow = TRUE)))
classb = data.frame(mvrnorm(n = n, mu = c(10,7), Sigma = matrix(c(8, -6, -6, 8), ncol = 2, byrow = TRUE)))
df = cbind(classa, rep("a", ncol(classa)))
colnames(df) = c("x1", "x2", "y")
foo = cbind(classb, rep("b", ncol(classb)))
colnames(foo) = c("x1", "x2", "y")
df = rbind(df, foo)

task = makeClassifTask(data = df, target = "y")
lrn = makeLearner("classif.naiveBayes")
m = train(lrn, task)
mm = m$learner.model

tab = mm$tables
mus = data.frame(x1 = tab$x1[, 1], x2 = tab$x2[, 1])
mu1 = as.numeric(mus[1,])
mu2 = as.numeric(mus[2,])
sds = data.frame(x1 = tab$x1[, 2], x2 = tab$x2[, 2])
S1 = diag(sds[1,]) 
S2 = diag(sds[2,]) 

x1seq = seq(min(df$x1), max(df$x1), length.out = 100)
x2seq = seq(min(df$x2), max(df$x2), length.out = 100)
grid_dens1 = grid_dens2 = expand.grid(x1 = x1seq, x2 = x2seq)
grid_dens1$dens = dmvnorm(grid_dens1, mean = mu1, sigma = S1)
grid_dens2$dens = dmvnorm(grid_dens2, mean = mu2, sigma = S2)

pl = plot_lp("classif.naiveBayes", task, cv = 0L)
# pl = pl + geom_point(data = mu, size = 5)
pl = pl + geom_contour(data = grid_dens1, aes(z = dens), alpha = .6, lwd = 1.5, bins = 10) 
pl = pl + geom_contour(data = grid_dens2, aes(z = dens), alpha = .6, lwd = 1.4, bins = 10) 
print(pl)
ggsave("../figure/reg_class_nb_1.pdf", width = 8, height = 3.5)
dev.off()

