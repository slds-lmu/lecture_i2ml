library(vistool)
library(mlr3)
library(mlr3learners)
library(mlr3pipelines)

set.seed(1)

n = 40
x = runif(2 * n, min = 0, max = 7)
x1 = x[1:n]
x2 = x[(n + 1):(2 * n)]
y = factor(as.numeric((x1 + x2 + rnorm(n) > 7)))
df = data.frame(x1 = x1, x2 = x2, y = y)

task = TaskClassif$new("example task", 
                       backend = df, 
                       target = "y", 
                       positive = "0")


ff = function(type, file_name, ...) {
    
    learner = lrn(type, predict_type = "prob")
    
    vis = as_visualizer(task, learner)
    vis$init_layer_contour()
    vis$add_training_data()
    vis$add_decision_boundary()
    vis$plot()
    
    vis$save(file_name, width = 600, height = 500)
}

ff("classif.log_reg", "../figure/log_reg.png")
ff("classif.naive_bayes", "../figure/naive_bayes.png")
ff("classif.rpart", "../figure/cart_tree.png")
ff("classif.svm", "../figure/svm.png", sigma = 0.001)

library(gridExtra)
library(png)
library(grid)

log_reg = rasterGrob(readPNG("../figure/log_reg.png"), interpolate = TRUE)
naive_bayes = rasterGrob(readPNG("../figure/naive_bayes.png"), interpolate = TRUE)
cart_tree = rasterGrob(readPNG("../figure/cart_tree.png"), interpolate = TRUE)
svm = rasterGrob(readPNG("../figure/svm.png"), interpolate = TRUE)

png("../figure/db_examples.png", width = 1200, height = 1000)
grid.arrange(log_reg, naive_bayes, cart_tree, svm, ncol = 2, nrow = 2)
dev.off()

files_to_cleanup <- c("../figure/log_reg.png", 
                     "../figure/naive_bayes.png", 
                     "../figure/cart_tree.png", 
                     "../figure/svm.png")

file.remove(files_to_cleanup)
