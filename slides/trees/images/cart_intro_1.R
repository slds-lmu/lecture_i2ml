setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


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


scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


library(plyr)
library(kernlab)
set.seed(600000)
pdf("cart_intro_1.pdf", width = 8, height = 2.2)
model = draw_cart_on_iris(depth = 2)

ggsave("cart_intro_1.pdf", width = 8, height = 2.2)
dev.off()

