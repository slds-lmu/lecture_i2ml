# ------------------------------------------------------------------------------
# TAB: MNIST SVM KERNEL TEST MMCE
# ------------------------------------------------------------------------------

library(xtable)
load("mnist_svm_mixed.RData")

table_df <- as.data.frame(mnist_test_mmce_mixed$mmce[c(1, 2, 4, 5)])
rownames(table_df) <- c("linear", "poly (d = 2)", "RBF (gamma = 0.001)", "RBF (gamma = 1)")
colnames(table_df) <- "Error"

print(xtable(signif(table_df, 3), digits = 3, display = rep("fg", 2), align = "r|l"),
  row.names = FALSE, sanitize.colnames.function = function(x) x, include.rownames = TRUE,
  hline.after = 0, latex.environments = "small")