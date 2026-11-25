# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(MASS)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(mvtnorm)

# common settings
set.seed(1234)
plot_dpi <- 300
base_size <- 10
point_size <- 2

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(123)

n = 100

classa = data.frame(mvrnorm(n = n, 
                            mu = c(2, 2), 
                            Sigma = matrix(c(1, 0.1, 0.1, 1), 
                                           ncol = 2, 
                                           byrow = TRUE)))

classb = data.frame(mvrnorm(n = n, 
                            mu = c(10, 7), 
                            Sigma = matrix(c(5, -2, -2, 1), 
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

# Creating grid for predictions
grid = expand.grid(x1 = x1seq, x2 = x2seq)
grid_preds = as.data.frame(learner$predict_newdata(grid)$prob)
grid_preds$pred_class = factor(apply(grid_preds, 1, function(row) ifelse(row["a"] > row["b"], "a", "b")))
grid_preds$max_prob = apply(grid_preds[, c("a", "b")], 1, max)
grid = cbind(grid, grid_preds)

# Recompute density for visualizing distributions
grid_dens1 = grid
grid_dens1$dens = dmvnorm(grid_dens1[, c("x1", "x2")], mean = mu1, sigma = S1)
grid_dens2 = grid
grid_dens2$dens = dmvnorm(grid_dens2[, c("x1", "x2")], mean = mu2, sigma = S2)

# PLOT -------------------------------------------------------------------------

# Generate the plot
orig_data = as.data.frame(task$data())
pl = ggplot() +
  geom_tile(data = grid, aes(x = x1, y = x2, fill = pred_class, alpha = max_prob)) +
  geom_contour(data = grid_dens1, aes(x = x1, y = x2, z = dens), color = "#E69F00", alpha = 0.9, lwd = 0.5, bins = 10) +
  geom_contour(data = grid_dens2, aes(x = x1, y = x2, z = dens), color = "#56B4E9", alpha = 0.9, lwd = 0.5, bins = 10) +
  geom_point(data = orig_data, aes(x = x1, y = x2, color = y), size = point_size) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_fill_manual(values = c("a" = "#E69F00", "b" = "#56B4E9")) +
  scale_color_manual(values = c("a" = "#E69F00", "b" = "#56B4E9")) +
  labs(x = expression(x[1]), y = expression(x[2]), color = "class", fill = "class") +
  coord_fixed(ratio = 1) + 
  theme_minimal() +
  scale_alpha(range = c(0.1, 0.5), guide = 'none') +
  theme(
    plot.title = element_text(hjust = 0.5, size = base_size, face = "bold"),
    axis.title = element_text(size = base_size, face = "bold"),
    axis.text = element_text(size = base_size * 0.75, face = "bold"),
    legend.title = element_text(size = base_size, face = "bold"),
    legend.text = element_text(size = base_size * 0.75, face = "bold")
  )

# Save directly to PNG
ggsave(filename = "../figure/nb-db.png", plot = pl, dpi = plot_dpi)
