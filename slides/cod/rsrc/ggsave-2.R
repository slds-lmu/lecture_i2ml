library(reshape2)
library(mvtnorm)
library(gridExtra)

################################################################################
# add CIM2 scheme

library(ggplot2)
library(viridis)
theme_set(theme_minimal(base_size = 17))
scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
scale_f_d <- scale_fill_discrete <-
  function(...) viridis::scale_fill_viridis(..., end = .9,  discrete = TRUE, drop = TRUE)
scale_c <- scale_colour_continuous <- scale_color_continuous <-
  function(...) viridis::scale_color_viridis(..., end = .9)
scale_f <- scale_fill_continuous <-
  function(...) viridis::scale_fill_viridis(..., end = .9)

pal_2 <- viridisLite::viridis(2, end = .9)
pal_3 <- viridisLite::viridis(3, end = .9)
pal_4 <- viridisLite::viridis(4, end = .9)
pal_5 <- viridisLite::viridis(5, end = .9)

################################################################################
plotSVM = function(tsk, par.vals) {
  
  lrn = makeLearner("classif.ksvm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model@SVindex
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]
  
  set.seed(123L)
  par.set = c(list("classif.ksvm", tsk), par.vals)
  q = do.call("plotLearnerPrediction", par.set) + scale_f_d()
  #q = q + geom_point(data = df, color = "black",
  #  size = 6, pch = 21L)
  q
}
set.seed(123L)
makeSimulatedTask = function(size) {
  cluster.size = floor(size / 3)
  x1 = c(rnorm(cluster.size, mean = - 1.5), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1.5))
  x2 = c(rnorm(cluster.size, mean = - 1), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1))
  y = factor(c(rep("a", times = cluster.size), sample(c("a", "b"),
                                                      size = cluster.size/2, replace = TRUE), rep("b", times = cluster.size)))
  sim.df = data.frame(x1 = x1, x2 = x2, y = y)
  makeClassifTask("simulated example", data = sim.df, target = "y")
}

############################################################################

library(FNN)
library(purrr)

dist_p <- function(dims, n_per_dim = 1e4, k = 1) {
  x <- matrix(runif(dims * n_per_dim), ncol = dims)
  dist <- as.vector(dist(x))
  dist_nn <- FNN::knn.dist(x, k = k)
  data.frame(dim = dims,
             min = min(dist),
             mean = mean(dist),
             max = max(dist),
             mean_nn = mean(dist_nn),
             max_nn = max(dist_nn))
}


############################################################################

library(xtable)
distances <- readRDS("distances.rds")
names(distances) <- c("$p$", "$\\min(d(\\xv,\\tilde{\\xv}))$",  "$\\overline{d(\\xv,\\tilde{\\xv})}$", "$\\max(d(\\xv,\\tilde{\\xv}))$",
                      "$\\overline{d_{NN1}(\\xv)}$", "$\\max(d_{NN1}(\\xv))$")
print(xtable(signif(distances, 2), digits = 2, display = rep("fg", 7), align = "rr|lllll"),
      row.names = FALSE, sanitize.colnames.function = function(x) x, include.rownames = FALSE,
      hline.after = 0, latex.environments = "small")

############################################################################

distances <- readRDS("distances.rds")

distances$contr <- (distances$max - distances$min)/distances$max
distances$local <- ( distances$mean - distances$mean_nn) / distances$mean

plot_df <- melt(distances[, c("dim", "contr", "local")], id.vars = "dim")

ggplot(plot_df, aes(x=dim, y=value)) +
  geom_line(aes(color = variable)) + 
  geom_point(aes(color = variable)) + 
  labs(color=NULL) + 
  ylab(NULL) +
  xlab("p") +
  scale_colour_discrete(name = "", labels = c("c(p)", "l(p)"))


############################################################################

d = 1
a = rep(2 / sqrt(d), d)
x = seq(-6, 6, length.out = 500)

datagrid = data.frame(x = x)
datagrid$`1` = dnorm(datagrid$x, mean = a)
datagrid$`2` = dnorm(datagrid$x, mean = - a)
df = melt(datagrid, id.vars = "x")

samples = data.frame(`1` = rnorm(10, mean = a), `2` = rnorm(10, mean = -a))
samplesr = melt(samples)
levels(samplesr$variable) = c(1, 2)

p1 = ggplot()
p1 = p1 + theme_bw()
p1 = p1 + geom_line(data = df, aes(x = x, y = value, colour = variable))
p1 = p1 + geom_point(data = samplesr, aes(x = value, y = 0, colour = variable))
p1 = p1 + xlab("x") + ylab("density") + labs(colour = "class")
p1 = p1 + ggtitle(paste("Dimension p =", d)) + theme(legend.position = "none")
p1 = p1 + coord_fixed(xlim = c(- 5, 5), ylim = c(0, 0.5), ratio = 20)

# 2d case
d = 2
a = rep(2 / sqrt(d), d)
x = seq(-6, 6, length.out = 100)
datagrid = expand.grid(x1 = x, x2 = x)
datagrid$`1` = dmvnorm(datagrid[, 1:d], mean = a)
datagrid$`2` = dmvnorm(datagrid[, 1:d], mean = - a)
df = melt(datagrid, id.vars = c("x1", "x2"))
datagrid$density = datagrid$`1` + datagrid$`2`

samples = data.frame(class = rep(1:2, each = 10))
samples = cbind(samples, t(vapply(samples$class, function(x) rmvnorm(1, mean = rep((- 1)^(x + 1), 2)), numeric(2))))
samples$class = factor(samples$class)
names(samples)[2:3] = c("x1", "x2")

p2 = ggplot()
p2 = p2 + theme_bw()
p2 = p2 + geom_raster(data = datagrid, aes(x = x1, y = x2, fill = density))
p2 = p2 + geom_contour(data = df, aes(x = x1, y = x2, z = value, colour = variable))
p2 = p2 + coord_fixed(xlim = c(- 4, 4), ylim = c(- 4, 4), ratio = 1)
p2 = p2 + scale_fill_gradient(low = "white", high = "darkgrey")
p2 = p2 + geom_point(data = samples, aes(x = x1, y = x2, colour = class), size = 2)
p2 = p2 + ggtitle(paste("Dimension p =", d))
p2 = p2 + labs(colour = "Class")


grid.arrange(p1, p2, nrow = 1)

############################################################################

# Optimal Bayes classifier 1d
p3 = p1 + geom_rect(data = data.frame(xmin = c(0, -Inf), xmax = c(Inf, 0), ymin = c(-Inf, -Inf), ymax = c(Inf, Inf), group = as.factor(c(1, 2))), mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=group), color="black", alpha=0.2) 

# Optimal Bayes classifier 2d
p3_2 = p2 + geom_abline(slope = -1, intercept = 0) + 
  geom_polygon(data = data.frame(x = c(-Inf, Inf, -Inf), y = c(Inf, -Inf, -Inf)),
               aes(x,y), fill=3, alpha=0.2) + 
  geom_polygon(data = data.frame(x = c(-Inf, Inf, Inf), y = c(Inf, Inf, -Inf)),
               aes(x,y), fill=2, alpha=0.2)  

# Bayes Error 1d
a_1 = 2
p4 = p1 + stat_function(data = data.frame(x = c(1, 2)), aes(x), fun = function(x) dnorm(x, mean = -a_1 ), geom = "area", alpha = 0.5, xlim = c(0, 5)) 
p4 = p4 + stat_function(data = data.frame(x = c(1, 2)), aes(x), fun = function(x) dnorm(x, mean = a_1 ), geom = "area", alpha = 0.5, xlim = c(- 5, 0)) 
p4 = p4 + ggtitle("Bayes error (p = 1)")

# Bayes Error 2d
d = 2
a = rep(2 / sqrt(d), d)
x = seq(-6, 6, length.out = 100)
datagrid_bayes = expand.grid(x1 = x, x2 = x)

datagrid_bayes$`1` = dmvnorm(datagrid_bayes[, 1:d], mean = - a) - 
  dmvnorm(datagrid_bayes[, 1:d], mean = a)
datagrid_bayes$`2` = dmvnorm(datagrid_bayes[, 1:d], mean = a) - 
  dmvnorm(datagrid_bayes[, 1:d], mean = - a)

idx_1 = (datagrid_bayes$x1 >= 0 & datagrid_bayes$x2 >= 0) | 
  (datagrid_bayes$x1 * datagrid_bayes$x2 <= 0 & -datagrid_bayes$x1 <= datagrid_bayes$x2)

idx_2 = (datagrid_bayes$x1 < 0 & datagrid_bayes$x2 < 0) | 
  (datagrid_bayes$x1 * datagrid_bayes$x2 < 0 & -datagrid_bayes$x1 > datagrid_bayes$x2)

datagrid_bayes$density = 0.
datagrid_bayes[idx_1, "density"] = dmvnorm(datagrid_bayes[idx_1, 1:d], mean = - a)
datagrid_bayes[idx_2, "density"] = dmvnorm(datagrid_bayes[idx_2, 1:d], mean = a)


p4_2 = ggplot() +
  theme_bw() +
  geom_raster(data=datagrid_bayes, aes(x = x1, y = x2, fill = density)) +
  geom_contour(data = df, aes(x = x1, y = x2, z = value, colour = variable)) +
  coord_fixed(xlim = c(- 5, 5), ylim = c(- 5, 5), ratio = 1) +
  scale_fill_gradient(low = "white", high = "black") +
  geom_point(data = samples, aes(x = x1, y = x2, colour = class), size = 2) +
  ggtitle(paste0("Bayes error (p = ", d,")")) +
  labs(colour = "Class") 

grid.arrange(p3, p3_2, p4, p4_2 , nrow = 2)

############################################################################

bres = readRDS("code/cod_knn.rds")
p = ggplot(data = bres[bres$learner == "Bayes Optimal Classifier", ], aes(x = d, y = mmce.test.mean, colour = learner))
p = p + theme_bw()
p = p + geom_line()
p = p + xlab("p") + ylab("Mean Misclassification Error") + labs(colour = "Learner")
p = p + ylim(c(0, 0.4))
p

############################################################################


p = ggplot(data = bres, aes(x = d, y = mmce.test.mean, colour = learner))
p = p + theme_bw()
p = p + geom_line()
p = p + xlab("p") + ylab("Mean Misclassification Error") + labs(colour = "Learner")
p = p + ylim(c(0, 0.4))
p 

ggsave("../figure_man/knn_misclassification.png", width = 7.5, height= 2.5)

############################################################################

bres = readRDS("code/cod_lm_rpart.rds")
bres = melt(bres, id.vars = c("task.id", "learner.id", "d"))
p = ggplot(data = bres[bres$d != 500, ], aes(x = d, y = value, colour = learner.id))
p = p + geom_line()
p = p + xlab("Number of noise variables") + ylab("Mean Squared Error") + labs(colour = "Learner")
p = p + ylim(c(0, 300))
p


ggsave("../figure_man/MSE.png", width = 7.5, height= 2.5)


############################################################################

noise_prop = readRDS("code/cod_lm_noise.rds")

plot_noise <- ggplot(noise_prop, aes(x=X2, y=value)) +
  geom_boxplot() + 
  ylab(expression(kappa)) + 
  xlab("Number of noise features added")

plot_noise

ggsave("../figure_man/added_noise.png",width = 7.5, height= 4)

############################################################################
