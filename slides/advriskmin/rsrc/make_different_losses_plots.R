library(mvtnorm)
library(ggplot2)
library(gridExtra)

set.seed(77)

sigma = matrix(c(1, 0.7, 0.7, 1), nrow = 2)
mat   = as.data.frame(rmvnorm(50, mean = c(5,5), sigma = sigma, method = "chol"))

# override the main matrix
mat = rbind(mat)
colnames(mat) = c("x", "y")

mat_outlier = rbind(mat, c(2, 10))

######################################

# No outlier 
p1 = ggplot(mat,aes(x,y)) + 
geom_point(color="grey", alpha = 0.8) + 
geom_smooth(method = 'lm', se = FALSE, aes(color = "L2-loss")) + 
geom_quantile(quantiles = 0.5, aes(color = "L1-loss")) + 
geom_smooth(method=MASS::rlm, se = FALSE, formula= y~x, aes(color = "Huber loss")) + 
scale_color_manual(name = "Regression", values = c("L2-loss" = "darkgreen", "L1-loss" = "orange", "Huber loss" = "blue")) + 
ylim(c(0, 10)) + theme(legend.position = "bottom")

ggsave("../figure/different_losses_1.png", p1, width = 6, height = 4)


# Outlier (red) 
p2 = p1 + 
geom_point(aes(x = 2, y = 10), color="red", alpha = 0.8) + 
geom_smooth(data = mat_outlier, method = 'lm', se = FALSE, aes(color = "L2-loss"), lty = 2) + 
geom_quantile(data = mat_outlier, quantiles = 0.5, aes(color = "L1-loss"), lty = 2) + 
geom_smooth(data = mat_outlier, method=MASS::rlm, se = FALSE, formula= y~x, aes(color = "Huber loss"), lty = 2) + 
scale_color_manual(name = "Regression", values = c("L2-loss" = "darkgreen", "L1-loss" = "orange", "Huber loss" = "blue"))

ggsave("../figure/different_losses_2.png", p2, width = 6, height = 4)
