# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mvtnorm)
library(ggplot2)
library(MASS)
library(tidyverse)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(1020)

# Create data as mixture of Gaussians

mu_1 = c(6, 4)
mu_2 = c(4, 6)
Sigma = matrix(c(4, 3, 3, 4), ncol = 2)

cluster_1 = rmvnorm(1000, 
                    mean = mu_1, 
                    sigma = Sigma)

cluster_2 = rmvnorm(1000, 
                    mean = mu_2, 
                    sigma = Sigma)

data_bvnorm = data.frame(
  cbind(
    rbind(cluster_1, cluster_2),
    rep(0, length(cluster_1))
  )
)

colnames(data_bvnorm) = c("x_1", "x_2", "is_sampled")

sampled = sample(seq_len(nrow(data_bvnorm)), 2, replace = FALSE)
data_bvnorm[sampled, "is_sampled"] = 1

highlight = data_bvnorm %>% 
  filter(is_sampled == 1)

x_1_sampled = highlight[1, 1:2]
x_2_sampled = highlight[2, 1:2]

density_2d = kde2d(data_bvnorm$x_1, data_bvnorm$x_2)

# PLOT -------------------------------------------------------------------------

# pdf("../figure/ml-basics-sample-from-dgp.pdf", width = 8, height = 2.5)

pmat = persp(density_2d, box = FALSE, phi = 40)

my_points = trans3d(
  
  c(as.numeric(x_1_sampled[1]), as.numeric(x_2_sampled[1])), 
  c(as.numeric(x_1_sampled[2]), as.numeric(x_2_sampled[2])), 
  c(0, 0), 
  pmat = pmat
  
)

points(my_points, pch = 19, col = "red", cex = 1.6)

p_1 = recordPlot()

p_2 = ggplot(data_bvnorm, aes(x = x_1, y = x_2)) + 
  geom_point(alpha = 0.6) + 
  labs(x = expression(x[1]), y = expression(x[2])) + 
  geom_point(data = highlight, col = "red", size = 4) +
  theme_bw()

plot_grid(p_1, p_2)

# ggsave("../figure/ml-basics-sample-from-dgp.pdf", width = 8, height = 2.5)
# dev.off()