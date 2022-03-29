# ------------------------------------------------------------------------------
# FIG: SVM RBF KERNEL HYPERPARAMETERS PLOTS
# ------------------------------------------------------------------------------

library(gridExtra)
library(grid)

source("utils.R")

# DATA -------------------------------------------------------------------------
## Define two task: one almost linear and one spirals
set.seed(123L)
n <- 120
tsk_lin <- makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)

# PLOTS ------------------------------------------------------------------------
blank <- grid.rect(gp=gpar(col="white"))

p1 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = 1))
p2 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 0.1, gamma = 0.1))
p3 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 1000, gamma = 1))
p4 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 100, gamma = 20))

p <- grid.arrange(p1, blank, p2, p3, blank, p4, widths = c(2, 1, 2), ncol = 3)

ggsave("../figure/svm_rbf_hyperparams.png", plot = p, width = 15, height = 8.4)