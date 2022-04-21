# PREREQS ----------------------------------------------------------------------

library(plot3D)
library(data.table)
library(mlr3verse)
library(ggplot2)

# DATA -------------------------------------------------------------------------

# Example data

set.seed(123L)
x_1 <- runif(50, -10, 10)
x_2 <- runif(50, -10, 10)
y_obs <- 0.5 * x_1 + 0.5 * x_2 + rnorm(length(x_1), 0, 1)
class <- ifelse(y_obs > 0, 0, 1)

dt <- data.table(x_1, x_2, as.factor(class))
setnames(dt, c("x_1", "x_2", "class"))

task <- TaskClassif$new("foo", backend = dt, target = "class")
learner <- lrn("classif.log_reg")
theta <- learner$train(task)$model$coefficients[2:3]

# Points for logistic function surface

softmax <- function(x, y, theta) {
  mat <- matrix(c(x, y), ncol = 2L)
  1 / (1 + exp(-(mat %*% theta)))
}

x <- y <- seq(-10, 10, length = 100)
z <- outer(x, y, softmax, theta = theta)

# PLOT 1 -----------------------------------------------------------------------

png("../figure/logreg_3d.png", width = 350L, height = 350L)

persp3D(
  x, 
  y, 
  z, 
  theta = 45, 
  phi = 30, 
  col = "darkgray", 
  alpha = 0.3, 
  xlab = "x1",
  ylab = "x2",
  zlab = ""
)
points3D(
  dt[class == 0, x_1], 
  dt[class == 0, x_2], 
  softmax(dt[class == 0, x_1], dt[class == 0, x_2], theta), 
  add = TRUE, 
  col = "darkorange1", 
  colvar = NULL,
  pch = 19L
)
points3D(
  dt[class == 1, x_1], 
  dt[class == 1, x_2], 
  softmax(dt[class == 1, x_1], dt[class == 1, x_2], theta), 
  add = TRUE, 
  col = "cornflowerblue", 
  colvar = NULL,
  pch = 19L
)

dev.off()

# PLOT 2 -----------------------------------------------------------------------

dt$class <- as.factor(dt$class)

p <- plot_learner_prediction(learner, task) + 
  labs(x = "x1", y = "x2") +
  scale_fill_manual(values = c("darkorange1", "cornflowerblue")) +
  guides(fill = "none", shape = "none") +
  theme_minimal() +
  theme(axis.ticks = element_blank(), axis.text = element_blank())
  
ggsave(
  "../figure/logreg_2d.png",
  p,
  height = 2L,
  width = 2L
)
