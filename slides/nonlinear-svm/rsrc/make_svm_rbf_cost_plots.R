# ------------------------------------------------------------------------------
# FIG: SVM RBF KERNEL COST PLOTS
# ------------------------------------------------------------------------------

library(gridExtra)
library(grid)

source("utils.R")

## Define two task: one almost linear and one spirals
set.seed(123L)
n <- 120
tsk_lin <- makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)


blank <- grid.rect(gp=gpar(col="white"))
############################################################################


p1 <- plotSVM(tsk_lin, list(kernel = "radial", cost = 0.035, gamma = 1))
p2 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 0.035, gamma = 1))
p12 <- grid.arrange(p1, blank, p2, ncol = 3, widths = c(2, 1, 2))

ggsave("../figure/svm_rbf_cost_1.png", plot = p12, width = 15, height = 4.2)
############################################################################

p3 <- plotSVM(tsk_lin, list(kernel = "radial", cost = 100, gamma = 1))
p4 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 100, gamma = 1))
p34 <- grid.arrange(p3, blank, p4, ncol = 3, widths = c(2, 1, 2))

ggsave("../figure/svm_rbf_cost_2.png", plot = p34, width = 15, height = 4.2)



