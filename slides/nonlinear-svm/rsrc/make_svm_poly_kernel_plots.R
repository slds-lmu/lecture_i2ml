# ------------------------------------------------------------------------------
# FIG: SVM POLYNOMIAL KERNEL PLOTS
# ------------------------------------------------------------------------------

library(glue)
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

deg_coef0_pairs <- list(c(1,1),c(3,1),c(9,1),c(3,0))
for (deg_coef0 in deg_coef0_pairs) {
  deg <- deg_coef0[1]
  coef0 <- deg_coef0[2]
  p_lin <- plotSVM(tsk_lin, list(kernel = "polynomial", degree  = deg, coef0 = coef0)) +
    theme_minimal()
  p_spiral <- plotSVM(tsk_spiral, list(kernel = "polynomial", degree  = deg, coef0 = coef0)) +
    theme_minimal()
  p_poly <- grid.arrange(p_lin, p_spiral, ncol = 2)
  ggsave(glue("../figure/svm_poly_kernel_deg_{deg}_coef0_{coef0}.png"), plot = p_poly, width = 12, height = 6)
}
