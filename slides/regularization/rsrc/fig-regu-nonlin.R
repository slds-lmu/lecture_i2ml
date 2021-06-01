################################################################################
####### Non-linear regularization: Neural net ##################################
################################################################################

library(mlr3)
library(mlr3learners)
library(mlr3viz)

library(ggplot2)

library(gridExtra)
library(grid)
#-------------------------------------------------------------------------------
options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))
#-------------------------------------------------------------------------------
# functions for plotting the weights 

plot_weights <- function (weights) {
  weight_data <- data.frame(value = weights, weights = seq_along(weights))
  
  ggplot(weight_data, aes(x=weights, y = value)) + 
    geom_bar(stat ="identity", color="black", fill="white") +
    ylim(c(-75, 75)) +
    ggtitle("Weights")
}

plot_histogram <- function (weights) {
  weight_data <- data.frame(value = weights)
  
  ggplot(weight_data, aes(x=weights)) + 
    geom_histogram (bins= 15, color="black", fill="white") +
    ggtitle("Histogram of weights") +
    xlab ("value of weights") +
    xlim(c(-100, 100)) #+
    #ylim(c(0,40))
}



# function for plotting the prediction

plot_prediction <- function (learner, task) {
  plot_learner_prediction(learner, task) + 
    scale_fill_viridis_d(end = .9) + 
    theme(legend.position = "none") +
    ggtitle("Prediction")
}

#-------------------------------------------------------------------------------
#spirals dataset
spirals_generator = tgen("spirals", sd = 0.1)

# get spirals data 
spirals_task = spirals_generator$generate(n=100) 


################################################################################
############ Different decay parameters ### ####################################
################################################################################
# decay parameter / lambda 
decay_list = list(0, 0.001, 0.005, 0.01, 0.05, 0.1)

# size of single hidden layer
size = 10


# plot for all decay paramters the predition & a plot of the weights
for(i in seq_along(decay_list)){
  set.seed(1234)
  learner = lrn("classif.nnet", size = size, decay = decay_list[[i]])
  
  learner$train(spirals_task)
  weights <- learner$model$wts
  weight_plot <- plot_weights(weights = weights) 
  historgram_plot <-plot_histogram(weights = weights)
  
  prediction_plot <- plot_prediction(learner, spirals_task)
  
  grid <- grid.arrange(prediction_plot,historgram_plot, weight_plot, ncol = 3, 
                       top = textGrob(bquote(lambda==.(decay_list[[i]])), 
                                      gp = gpar(fontsize = 14))) 
  
  ggsave(filename = paste0("../figure/fig-regu-nonlin-", i ,".png"), 
         plot = grid, width = 8, height = 3) 
  
}

################################################################################
############ Different size of hidden layer ####################################
################################################################################


size_list = list(1, 5, 10, 15, 30, 60)
decay = 0

for(i in seq_along(size_list)){
  set.seed(1234)
  learner = lrn("classif.nnet", size = size_list[[i]], decay = decay )
  
  learner$train(spirals_task)
  weights <- learner$model$wts
  weight_plot <- plot_weights(weights = weights) 
  historgram_plot <-plot_histogram(weights = weights)
  
  prediction_plot <- plot_prediction(learner, spirals_task)
  
  grid <- grid.arrange(prediction_plot, ncol = 1, 
                       top = textGrob(bquote(size~of~hidden~layer==.(size_list[[i]])), 
                                      gp = gpar(fontsize = 14))) 
  
  ggsave(filename = paste0("../figure/fig-regu-nonlin-size-", i ,".png"), 
         plot = grid, width = 3, height = 3) 
  
}

folds = 10; reps = 5; by = 3
#folds = 2; reps = 1; by = 10
decay = 0.01
size_list = seq(1, 100, by = by)

# this might run for 5 min
rdesc = rsmp("repeated_cv", folds = folds, repeats = reps)
lrns = lapply(size_list, function(s) lrn("classif.nnet", size = s, decay = decay))
gg = benchmark_grid(tasks = spirals_task, resamplings = rdesc, learners = lrns)
br = benchmark(gg)
a = br$aggregate(measures = msr("classif.ce"), params = TRUE)
a = mlr3misc::unnest(a, "params")
p = ggplot(data = a, aes(x = size, y = classif.ce)) +
  geom_line() + 
  xlab("size hidden layer") + ylab("classif err")
#print(p)

ggsave(filename = paste0("../figure/fig-regu-nonlin-svr.png"), 
  plot = p, width = 3, height = 3) 



