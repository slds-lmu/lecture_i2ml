draw_cart_on_iris = function(depth, with_tree_plot = FALSE) {
  task = makeClassifTask(data = iris[,3:5], target = "Species")
  lrn = makeLearner("classif.rpart", cp = 0, minbucket = 4, maxdepth = depth)
  model = train(lrn, task)
  p = plotLearnerPrediction(lrn, task, gridsize = 100, cv = 0, prob.alpha = FALSE, err.mark = "train")
  p = p + 
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major = element_line(colour = "grey80"),
          panel.grid.minor = element_line(colour = "grey80"),
          panel.border = element_blank(),
          panel.background = element_blank()) + 
    ggtitle("Iris Data")
  print(p)
  if (with_tree_plot)
    # "palettes" should ensure that colors in tree growing in rectangles and tree match
    fancyRpartPlot(model$learner.model, sub = "", palettes = c("Reds", "Greens", "Blues"))
  invisible(model)
}
