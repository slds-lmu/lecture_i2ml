# ------------------------------------------------------------------------------
# FIG: MNIST SVM MMCE
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)

# DATA -------------------------------------------------------------------------
load("mnist_svm_mixed.RData")

# PLOTS ------------------------------------------------------------------------
pl_df <- mnist_test_mmce_mixed[, c("mmce", "degree")]
pl_df <- pl_df[complete.cases(pl_df),]

p_mnist_svm_mmce <- ggplot(pl_df, aes(x=degree, y=mmce)) +
  geom_point(size=2) +
  geom_line() +
  scale_x_continuous(breaks = pl_df$degree) +
  xlab("degree d")

ggsave("../figure/mnist_svm_mmce.png", plot = p_mnist_svm_mmce, width = 4, height = 3)
