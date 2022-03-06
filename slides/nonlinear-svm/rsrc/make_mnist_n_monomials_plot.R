# ------------------------------------------------------------------------------
# FIG: N MONOMIALS PLOT
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------
d <- 1:5
p <- 16*16
num_monomials <- choose(p + d, p)-1

df_mon <- data.frame(degree = d, num_monomials = num_monomials)

# PLOTS ------------------------------------------------------------------------
p_mnist_n_monomials <- ggplot(df_mon, aes(x=d, y=num_monomials)) +
  geom_point(size=2) +
  geom_line() +
  scale_x_continuous(breaks = d) +
  scale_y_continuous(trans = "log10") +
  xlab("degree d") +
  ylab("Number of monomials")

ggsave("../figure/n_monomials.png", plot = p_mnist_n_monomials, width = 5, height = 2)