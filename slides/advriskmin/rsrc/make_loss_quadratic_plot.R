# ------------------------------------------------------------------------------
# FIG: QUADRATIC LOSS
# ------------------------------------------------------------------------------


library("ggplot2")
library("mvtnorm")
library("ggpubr")
library("quantreg")
library("dplyr")

source("helpers/loss_functions.R")

theme_set(theme_minimal())

set.seed(1)

# DATA -------------------------------------------------------------------------

sigma <- matrix(c(1, 0.7, 0.7, 1), nrow = 2)
linear_df <- as.data.frame(rmvnorm(50, mean = c(5, 5), sigma = sigma, method = "chol"))
colnames(linear_df) <- c("x", "y")

fitted_line <- lm(formula = y ~ x, data = linear_df)
linear_df$predicted <- predict(fitted_line)
linear_df$residual <- linear_df$y - linear_df$predicted
linear_df$residual_sqr <- linear_df$residual^2
linear_df$delta_x_residual <- linear_df$x - linear_df$residual
linear_df$delta_y_residual <- linear_df$y - linear_df$residual

idx <- order(linear_df$x)[c(10, 20, 30, 40, 50)]

linear_df_sampled <- linear_df[idx, ]

quad_loss_df <- data.frame(x = seq(-2, 2, by = 0.1))


# PLOTS ------------------------------------------------------------------------

p1 <- ggplot(data = linear_df, aes(x=x, y=y)) +
  geom_point() +
  geom_rect(data = linear_df_sampled, mapping = aes(xmin = x, xmax = delta_x_residual, ymin = y, ymax = delta_y_residual, fill = "red"), alpha = .5, color = NA) +
  geom_abline(slope = fitted_line$coefficients[[2]], intercept = fitted_line$coefficients[[1]]) +
  geom_segment(data = linear_df_sampled, aes(xend = x, yend = predicted), color = "red") +
  theme(text = element_text(size = 20L),
        legend.position = "none")


p2 <- ggplot(data = quad_loss_df, aes(x = x)) +
  geom_function(fun = L2, color = "black") +
  geom_point(data= linear_df_sampled, aes(x = residual, y = residual_sqr, shape = 21, stroke = 2), size = 3, color = "red") +
  geom_segment(data= linear_df_sampled, aes(x = residual, y = residual_sqr, xend = residual, yend = 0), color = "red") +
  scale_shape_identity() +
  xlab(expression(y - f(x))) +
  ylab(expression(L(y, f(x)))) +
  theme(text = element_text(size = 20),
        legend.position = "none")

p <- ggarrange(p1, p2, nrow = 1, ncol = 2)

p2_non_lab <- p2 +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        text = element_text(size = 10L))

ggsave(plot = p2_non_lab, filename = "../figure/loss_quadratic_1.png", width = 4, height = 3)

ggsave(plot = p, filename = "../figure/loss_quadratic_2.png", width = 11, height = 4)