library(ggplot2)
library(viridis)

load("mnist_svm_mixed.RData")

pl_df <- mnist_test_mmce_mixed[, c("mmce", "degree")]
pl_df <- pl_df[complete.cases(pl_df),]

p_mnist_svm_mmce <- ggplot(pl_df, aes(x=degree, y=mmce)) +
  geom_point(size=2) +
  geom_line() +
  scale_x_continuous(breaks = pl_df$degree) +
  xlab("degree d")

ggsave("../figure/mnist_svm_mmce.png", plot = p_mnist_svm_mmce, width = 4, height = 3)


############################################################################

d <- 1:5
p <- 16*16
num_monomials <- choose(p + d, p)-1

df_mon <- data.frame(degree = d, num_monomials = num_monomials)

p_mnist_n_monomials <- ggplot(df_mon, aes(x=d, y=num_monomials)) +
  geom_point(size=2) +
  geom_line() +
  scale_x_continuous(breaks = d) +
  scale_y_continuous(trans = "log10") +
  xlab("degree d") +
  ylab("Number of monomials")

ggsave("../figure/mnist_n_monomials.png", plot = p_mnist_n_monomials, width = 5, height = 2)