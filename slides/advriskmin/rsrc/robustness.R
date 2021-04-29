library(mvtnorm)
library(ggplot2)

set.seed(77)

sigma = matrix(c(1, 0.7, 0.7, 1), nrow = 2)
mat   = as.data.frame(rmvnorm(50, mean = c(5,5), sigma = sigma, method = "chol"))
outlier = c(2, 20)

# override the main matrix
mat = rbind(mat, outlier)

colnames(mat) = c("x", "y")
# fit the model
fit_l1 = rq(y ~ x, data = mat, tau = 0.5)

mat$predicted_l1 = predict(fit_l1) 
mat$residuals_l1 = residuals(fit_l1)
# https://drsimonj.svbtle.com/visualising-residuals
ggplot(mat, aes(x, y)) +
  geom_quantile(quantiles = 0.5, color = "lightgrey") +
  geom_segment(aes(xend = x, yend = predicted_l1), alpha = .2) +
  geom_point(aes(color = abs(residuals_l1), size = abs(residuals_l1))) +
  #  this does not work? scale_color_continuous(low = "black", high = "red") +
  guides(color = FALSE, size = FALSE) +  
  geom_point(aes(y = predicted_l1), shape = 1) +
  theme_minimal() + 
  theme(text = element_text(size = 30L))


######################################

p = ggplot(mat,aes(x,y)) + 
geom_point(color="grey", alpha = 0.8) + 
geom_point(color = "red", x = outlier[1], y = outlier[2]) + 
geom_smooth(method = 'lm', se = FALSE, aes(color = "L2-loss")) + 
geom_quantile(quantiles = 0.5, aes(color = "L1-loss")) + 
geom_smooth(method=MASS::rlm, se = FALSE, formula= y~x, aes(color = "Huber loss")) + 
scale_color_manual(name = "Regression", values = c("L2-loss" = "darkgreen", "L1-loss" = "orange", "Huber loss" = "blue")) +
theme_minimal() + 
theme(text = element_text(size = 20L)) 

ggplot2::ggsave("../figure/robustness.png", p, width = 6L, height = 4L)
