# PREREQ -----------------------------------------------------------------------
library(ggplot2)

source("train-vs-test-error.R")

# FUNCTIONS -------------------------------------------------------------------
plot_line <- function(results, xlab, ylab) {
  x = colnames(results)[[1]]
  y = colnames(results)[[2]]
  
  ggplot(data= results, aes_string(x,y)) +
    geom_line() +
    geom_point()+
    xlab(xlab) +
    ylab(ylab)
}

plot_boxplot <- function (results, xlab, ylab, ylim = c(NA, NA)){
  x = sprintf("factor(%s)",colnames(results)[[1]])
  y = colnames(results)[[2]]
  
  ggplot(data= results, aes_string(x = x, y= y)) +
    geom_boxplot() +
    xlab(xlab) +
    ylab("MSE")+ 
    theme(legend.position = "none") +
    ylim(ylim)
}
#-------------------------------------------------------------------------------
# Increasing training set size (Training error)
#-------------------------------------------------------------------------------

p1 <- plot_line(results = results_train1, 
                xlab = "size of training set", 
                ylab = "MSE (training error)")

p1

ggsave("../figure/fig-train-vs-test-error-1.pdf", p1, width = 8, height = 5)

#-------------------------------------------------------------------------------
# Increasing training set size (Test error)
#-------------------------------------------------------------------------------

p2 <- plot_line(results = results_train2, 
                xlab = "size of training set", 
                ylab = "MSE (test error)")

p2


ggsave("../figure/fig-train-vs-test-error-2.pdf", p2, width = 8, height = 5)
#-------------------------------------------------------------------------------
# Increasing test set size (Test error)
#-------------------------------------------------------------------------------

p3 <- plot_boxplot(results = results_test,
                   xlab = "size of test set", 
                   ylab = "MSE (test error)", 
                   ylim = c(0, 150))

p3 

ggsave("../figure/fig-train-vs-test-error-3.pdf", p3, width = 8, height = 5)
#-------------------------------------------------------------------------------
# Variation of model complexity (Train error)
#-------------------------------------------------------------------------------

p4 <- plot_line(results = results_complexity1, 
                xlab = "degree", 
                ylab = "MSE (train error)")

p4

ggsave("../figure/fig-train-vs-test-error-4.pdf", p4, width = 8, height = 5)

#-------------------------------------------------------------------------------
# Variation of model complexity (Test Error)
#-------------------------------------------------------------------------------

p5 <- plot_boxplot(results = results_complexity2,
                   xlab = "degree", 
                   ylab = "MSE (test error)", 
                   ylim = c(0, 100))
p5

ggsave("../figure/fig-train-vs-test-error-5.pdf", p5, width = 8, height = 5)
