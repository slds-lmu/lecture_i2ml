library(mlr3)
library(mlr3viz)
library(ggplot2)
library(rattle)
library(viridis)

draw_cart_on_iris = function(depth, with_tree_plot = FALSE) {
  
  task = tsk("iris")
  task$select(c("Petal.Width", "Petal.Length"))
  
  learner = lrn("classif.rpart", cp = 0, minbucket = 4, maxdepth = depth)
  
  learner$train(task)
  model = learner$model
  
  p = plot_learner_prediction(learner, task)
  p = p + guides(shape = FALSE)
  p = p + 
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major = element_line(colour = "grey80"),
          panel.grid.minor = element_line(colour = "grey80"),
          panel.border = element_blank(),
          panel.background = element_blank()) + 
    ggtitle("Iris Data")
  print(p)
  
  if (with_tree_plot) {
    
    # "palettes" should ensure that colors in tree growing in rectangles and 
    # tree match
    
    fancyRpartPlot(model, 
                   sub = "", 
                   palettes = c("Reds", "Greens", "Blues"))
    
  }
    
  invisible(model)
  
}
