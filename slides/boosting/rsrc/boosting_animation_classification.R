# ------------------------------------------------------------------------------
# FUN: BOOSTING ANIMATION CLASSIFICATION
# ------------------------------------------------------------------------------

# mlbench dataset circle
data_1 <- mlbench::mlbench.circle(50,2)
data <- data.table::data.table(data_1$x, data_1$classes)
data.table::setnames(data, c("x1", "x2", "y"))
y = as.numeric(as.character(data$y))-1
X = data[,c("x1", "x2")]


# create plot for simulation setting description
data_plot = cbind(X,y)
data_plot$y = as.factor(data_plot$y)
plot_example = ggplot() + geom_point(data = data_plot, aes(x = x1, y = x2, color =y), size = 3) + scale_color_manual(values = c("orange","darkblue"), breaks = c(0,1), labels = c(0,1))
ggsave("figure_man/boosting_classif_example.png", plot_example, width = 5, height = 5)


# plot function
plot_classif_boosting <- function(data, 
                                 y, 
                                 gridsize,
                                 iteration, 
                                 init_constant, 
                                 learning_rate) {
  
 
  # initialize overall prediction
  overall_pred <- rep(init_constant, length(y))
  
  # set pseudo_res to y
  pseudo_res <- y
  
  # initialize output list
  plots_baselearner = list()
  plots_boosting = list()
 
  
  # Compute boosting procedure
  
  for (i in (seq_len(iteration))) {
    
    
    # calculate pseudo residuals
    pseudo_res = y - (exp(overall_pred)/(1+exp(overall_pred)))
    
    
    # add pseudo_res to dataframe as target for base learner and fit glm 
    data$pseudo_res = pseudo_res
    task = makeRegrTask(data = data, target = "pseudo_res")
    
    learner = makeLearner("regr.rpart", maxdepth = 3)
    mod = train(learner, task)
    pred.train = predict(mod, task)
    
    # baselearner logloss predictions for pseudo residuals
    baselearner_pred = pred.train$data$response
    
    
    # calculate overall prediction for boosting model
    overall_pred <- c(overall_pred + learning_rate*baselearner_pred)
    overall_prob <- exp(overall_pred)/(1+exp(overall_pred))
    #data$baselearner_pred = baselearner_pred
    
    #-----------------------------------------------------------------------------------------------
    # plot baselearner predictions
    
    # dataset for geom_point (true pseudo-residuals)
    data_plot_base = data.frame(x1 = data$x1,x2 = data$x2, trueLabel = pseudo_res)
    
    # create grid with predictions of base learner
    grid = expand.grid(seq(min(data$x1), max(data$x1), length.out = gridsize), 
                       seq(min(data$x2), max(data$x2), length.out = gridsize))
    colnames(grid) = c("x1","x2")
    pred.grid = predict(mod, newdata = grid)
    pred_grid = pred.grid$data$response
    grid$prob = pred_grid
    
    # create plot
    p = ggplot(mapping = aes_string(x = "x1", y = "x2"))
    
    # add baselearner predictions
    p = p + 
      geom_raster(data = grid, mapping = aes_string(fill = "prob")) + 
      scale_fill_gradientn(limits = c(-1,1), colors=c("orange", "darkblue"))
    
    # add pseudo residuals
    p = p + 
      geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel", y = "x2"), size = 3)  + 
      scale_colour_gradientn(limits = c(-1,1), colors=c("orange", "darkblue")) +
      geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
    
    # title / legend adjustments
    p = p + 
      guides(color = FALSE) + 
      ggtitle(expression(paste(tilde(r)," and ", hat(b)^{"[m]"})))  + 
      theme(legend.title=element_blank())
    
    # save plot
    plots_baselearner[[i]] = p
    
    #-----------------------------------------------------------------------------------------------
    # plot overall predictions
    
    if(i == 1) pred.grid.cum = 0
    
    # dataset for geom_point (true labels)
    data_plot_base = data.frame(x1 = data$x1,x2 = data$x2, trueLabel = y)
    
    # add up base learner predictions for total boosting predictions and calculate probabilities
    pred.grid.cum = pred.grid.cum + pred.grid$data$response
    prob.grid.cum = exp(pred.grid.cum)/(1+exp(pred.grid.cum))
    grid = expand.grid(seq(min(data$x1), max(data$x1), length.out = gridsize), 
                       seq(min(data$x2), max(data$x2), length.out = gridsize))
    colnames(grid) = c("x1","x2")
    grid$prob = prob.grid.cum
    
    # create plot
    p = ggplot(mapping = aes_string(x = "x1", y = "x2"))
    
    # add pi (predictions)
    p = p + 
      geom_raster(data = grid, mapping = aes_string(fill = "prob"))  + 
      scale_fill_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    
    # add true Label y
    p = p + 
      geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel", y = "x2"), size = 3) + 
      scale_colour_gradientn(limits = c(0,1), colors=c("orange", "darkblue")) +
      geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
    
    # title / legend adjustments
    p = p + 
      guides(color = FALSE) +
      ggtitle(expression(paste("y and ", hat(pi)(x))))
    
    # save plot
    plots_boosting[[i]] = p
    
  }
  
 return(list(plots_baselearner, plots_boosting))
  
}


# create plots
plots = plot_classif_boosting(data = X, y = y, gridsize = 50, iteration = 100, init_constant = 0, learning_rate = 0.2)

# save selected plots with ggsave
m = c(1,2,5,10,100)

for(i in m){
  p = grid.arrange(plots[[2]][[i]], plots[[1]][[i]], nrow = 1)
  ggsave(filename = paste0("figure_man/boosting_classif_",i,".png"),plot = p, width = 9, height = 4)
}

