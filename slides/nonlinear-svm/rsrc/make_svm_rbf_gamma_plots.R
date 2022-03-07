# ------------------------------------------------------------------------------
# FIG: SVM RBF KERNEL GAMMA PLOTS
# ------------------------------------------------------------------------------

library(gridExtra)
source("utils.R")

# DATA -------------------------------------------------------------------------
set.seed(123L)
x <- cbind(
  c(2,3,4,5,6,0,1,2,3,1,2,3),
  c(0,0,0,0,0,0,1,2,3,-1,-2,-3))
y <- c(-1,-1,-1,-1,-1,1,1,1,1,1,1,1)
df <- data.frame (x = x, y = as.factor(y))
tsk <- makeClassifTask(data = df, target = 'y')

## Define two task: one almost linear and one spirals
set.seed(123L)
n <- 120
tsk_lin <- makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)

# PLOTS ------------------------------------------------------------------------

p1 <- plotSVM(tsk_lin, list(kernel = "radial", cost = 1, gamma = 0.01))
p2 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = 0.08))
p12 <- grid.arrange(p1, p2, ncol = 2)

ggsave("../figure/svm_rbf_kernel_gamma_1.png", plot = p12, width = 10, height = 5)

#-------------------------------------------------------------------------------

p3 <- plotSVM(tsk_lin, list(kernel = "radial", cost = 1, gamma = 100))
p4 <- plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = 10))
p34 <- grid.arrange(p3, p4, ncol = 2)

ggsave("../figure/svm_rbf_kernel_gamma_2.png", plot = p34, width = 10, height = 5)
