# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# FUNCTIONS --------------------------------------------------------------------

sigmoid = function(x) exp(x) / (1 + exp(x))

# DATA -------------------------------------------------------------------------

n = 100
grid = seq(from = -10, to = 10, length.out = n)

df_1 = data.frame(x = grid) %>% 
  mutate(y = sigmoid(x))

df_2 = data.frame(x = rep(grid, times = 3),
                  intercept = rep(c(-3, 0, 3), each = n)) %>% 
  mutate(y = sigmoid(intercept + x))

df_3 = data.frame(x = rep(grid, times = 4),
                  theta1 = rep(c(-2, -0.3, 1, 6), each = n)) %>% 
  mutate(y = sigmoid(x * theta1))

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_log_1.pdf", width = 8, height = 3.5)

ggplot(df_1) + 
  geom_line(aes(x = x, y = y)) + 
  scale_x_continuous("f") + 
  scale_y_continuous("s(f)")

ggsave("../figure/reg_class_log_1.pdf", width = 8, height = 3.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_log_2.pdf", width = 8, height = 2.2)

ggplot(df_2) + 
  geom_line(aes(x = x, y = y, group = intercept, color = factor(intercept))) +
  xlab("f") + 
  ylab("s(f)") +
  theme(legend.text.align = 1) +
  scale_color_viridis_d(expression(theta[0]), end = .9)

ggsave("../figure/reg_class_log_2.pdf", width = 8, height = 2.2)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/reg_class_log_3.pdf", width = 8, height = 2.2)

ggplot(df_3) + 
  geom_line(aes(x = x, y = y, group = theta1, color = factor(theta1))) +
  xlab("f") + 
  ylab("s(f)") +
  theme(legend.text.align = 1) +
  scale_color_viridis_d(expression(alpha), end = .9)

ggsave("../figure/reg_class_log_3.pdf", width = 8, height = 2.2)
dev.off()