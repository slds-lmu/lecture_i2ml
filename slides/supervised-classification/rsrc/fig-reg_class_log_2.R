# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# FUNCTIONS --------------------------------------------------------------------

bernoulli = function(y, pix) -y * log(pix) - (1 - y) * log(1 - pix)

# DATA -------------------------------------------------------------------------

x = seq(0, 1, by = 0.001)
df = data.frame(x = x, y = 1, pi = bernoulli(1, x))
df = rbind(df, data.frame(x = x, y = 0, pi = bernoulli(0, x)))
df$y = as.factor(df$y)

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_log_4.pdf", width = 8, height = 3)

ggplot(data = df, aes(x = x, y = pi, color = y)) + 
  geom_line() + 
  xlab(expression(pi(x))) + 
  ylab(expression(L(y, pi(x)))) +
  scale_color_viridis_d(end = .9)

ggsave("../figure/reg_class_log_4.pdf", width = 8, height = 3)
dev.off()