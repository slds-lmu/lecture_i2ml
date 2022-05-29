# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(MASS)
library(mlr3)
library(mlr3learners)
library(mvtnorm)
library(plotly)

options(
  digits = 3,
  width = 65,
  str = strOptions(strict.width = "cut", vec.len = 3)
)
set.seed(123)

# FUNCTION ---------------------------------------------------------------------
### Input Arguments: 
### dfTrain: DataFrame
### upper: Numeric(1), upper bound of range to be displayed in plot
### lover: Numeric(1), lower bound of range to be displayed in plot
### sLearner: String, mlr3 name of learner to be used (e.g. "classif.qda")
### task: mlr3-Task
createPlot <- function(dfTrain, upper, lower, sLearner, task) {
  x1s <- seq(upper, lower, length.out = 100)
  x2s <- seq(upper, lower, length.out = 100)
  
  dfPredict <- as.data.frame(cbind(
    "x1" = rep(x1s, each = 100),
    "x2" = rep(x2s, time = 100)
  ))
  
  learner = lrn(sLearner, predict_type = "prob")
  learner$train(task)
  predictions <- predict(learner, dfPredict)
  dfPredict$y <- predictions
  
  # create data for contour plots 
  means <- learner_qda$model$means
  muA = as.numeric(means[1,])
  muB = as.numeric(means[2,])
  foo_a = foo_b = matrix(c(0, 0, 0, 0), ncol = 2)
  for (i in 1:nrow(df[which(dfTrain$y == "a"), ])) {
    
    temp = as.matrix(dfTrain[which(dfTrain$y == "a"), ][i, c(1, 2)] - muA)
    foo_a = foo_a + crossprod(temp)
    
  }
  
  var_qda_a = (1 / (nrow(classa) - 1)) * foo_a
  
  for (i in 1:nrow(dfTrain[which(dfTrain$y == "b"), ])) {
    
    temp = as.matrix(dfTrain[which(dfTrain$y == "b"), ][i, c(1, 2)] - muB)
    foo_b = foo_b + crossprod(temp)
    
  }
  
  var_qda_b = (1 / (nrow(classb) - 1)) * foo_b
  
  x1seq = seq(min(df$x1), max(df$x1), length.out = 100)
  x2seq = seq(min(df$x2), max(df$x2), length.out = 100)
  grid_densA =
    grid_densB =
    expand.grid(x1 = x1seq,
                x2 = x2seq)
  
  grid_densA$dens = dmvnorm(grid_densA, mean = muA, sigma = var_qda_a)
  grid_densB$dens = dmvnorm(grid_densB, mean = muB, sigma  = var_qda_b)
  
  # plot data
  plotDec <- ggplot(data = dfTrain, aes(x1, x2))  +
    scale_shape_manual(values = c(21, 24)) +
    geom_point(
      aes(x1, x2, col = y),
      data = dfPredict,
      shape = 15,
      size = 2,
      show.legend = FALSE
    ) +
    geom_point(
      aes(fill = y),
      shape = 21,
      col = "black",
      size = 1,
      stroke = 1
    ) +
    labs(fill = 'Response')  +
    geom_contour(
      aes(x1, x2, z = as.integer(y)),
      data = dfPredict,
      inherit.aes = FALSE,
      color = "white",
      alpha = .6,
      size = 1
    ) +
    geom_contour(
      data = grid_densA,
      aes(z = dens),
      alpha = .6,
      lwd = 1,
      bins = 5,
    ) +
    geom_contour(
      data = grid_densB,
      aes(z = dens),
      alpha = .6,
      lwd = 1,
      bins = 5
    ) + scale_color_viridis_d() + scale_fill_viridis_d(end = .9)
  
    return(plotDec)
}

# DATA -------------------------------------------------------------------------
n = 300

classa = data.frame(mvrnorm(
  n = n,
  mu = c(0, 0),
  Sigma = matrix(c(2, 1, 1, 1),
                 ncol = 2,
                 byrow = TRUE)
))

classb = data.frame(mvrnorm(
  n = n,
  mu = c(10, 0),
  Sigma = matrix(c(2, -1, -1, 1),
                 ncol = 2,
                 byrow = TRUE)
))

### create df per class
df_a = cbind(classa, factor(rep("a", ncol(classa))))
colnames(df_a) = c("x1", "x2", "y")


df_b = cbind(classb, factor(rep("b", ncol(classb))))
colnames(df_b) = c("x1", "x2", "y")

### create complete dataset for task
df = rbind(df_a, df_b)

# DEFINE TASK ------------------------------------------------------------------
task = TaskClassif$new(
  "gauss_task",
  backend = df,
  target = "y",
  positive = "a"
)

# GENERATE PLOTS ---------------------------------------------------------------
plot10x20 <- createPlot(df, 20,-10, "classif.qda", task)
plot150x150 <- createPlot(df, 150,-150, "classif.qda", task)

print(plot10x20)
print(plot150x150)


# SAVE PLOTS -------------------------------------------------------------------
pdf("../figure/reg_class_qda10x20.pdf",
    width = 8,
    height = 8)
print(plot10x20)
ggsave("../figure/reg_class_qda10x20.pdf",
       width = 8,
       height = 8)
dev.off()

pdf("../figure/reg_class_qda150x150.pdf",
    width = 8,
    height = 8)
print(plot150x150)
ggsave("../figure/reg_class_qda150x150.pdf",
       width = 8,
       height = 8)
dev.off()
