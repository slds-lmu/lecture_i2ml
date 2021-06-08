# ------------------------------------------------------------------------------
# FUN: BOOSTING ANIMATION GAM
# ------------------------------------------------------------------------------

# Purpose: perform boosting for regression with GAM
data_1 <- mlbench::mlbench.circle(50,2)
data_dt_1 <- data.table::data.table(data_1$x, data_1$classes)
data_dt_1$y = as.numeric(data_dt_1$y)-1



# set.seed(2L)
# data_2 <- mlbench::mlbench.spirals(n = 200L, sd = 0.2)
# data_dt_2 <- data.table::data.table(data_2$x, data_2$classes)

data <- list(data_dt_1)

data = lapply(
  data, 
  function(i) data.table::setnames(i, c("x1", "x2", "y")))[[1]]
y = as.numeric(as.character(data$y))-1
X = data[,c("x1", "x2")]

data_plot = cbind(X,y)
data_plot$y = as.factor(data_plot$y)
plot_example = ggplot() + geom_point(data = data_plot, aes(x = x1, y = x2, color =y), size = 3) + scale_color_manual(values = c("orange","darkblue"), breaks = c(0,1), labels = c(0,1))
ggsave("figure_man/boosting_classif_example.png", plot_example, width = 5, height = 5)

options(warn = -1)

plot_classif_boosting <- function(data, 
                                 y, 
                                 gridsize,
                                 iteration, 
                                 distribution, 
                                 learning_rate) {
  
  # Set initial, constant prediction
  
  #X <- basis_fun(x)
  
  init_constant <- switch(
    distribution,
    gaussian = mean(y),
    laplace = median(y),
    huber = median(y),
    logloss = 0)
  
  overall_pred <- rep(init_constant, length(y))
  pseudo_res <- y
  plots_baselearner = list()
  plots_boosting = list()
  #coefs <- matrix(0L, nrow = iteration + 1L, ncol = ncol(X))
  
  # ylim <- switch(
  #   distribution,
  #   gaussian = c(min(y) - mean(y), max(y)),
  #   laplace = c(-1.5, 1.5),
  #   huber = c(min(y) - mean(y), max(y)),
  #   logloss = c(0,1))
  
  preds <- list(overall_pred)
  
  # Compute boosting procedure
  
  for (i in (seq_len(iteration))) {
    
    # Update step
    
    # calculate pseudo residuals
    pseudo_res <- switch(
      distribution,
      gaussian = y - overall_pred,
      laplace = sign(y - overall_pred),
      huber = ifelse(
        abs(y - overall_pred) <= alpha, 
        y - overall_pred, 
        alpha * sign(y - overall_pred)),
      logloss = y - (exp(overall_pred)/(1+exp(overall_pred))))
    
    pseudo_res_prob = exp(pseudo_res)/(1+exp(pseudo_res))
   
    
    # add pseudo_res to dataframe as target for base learner and fit glm 
    data$pseudo_res = pseudo_res
    task = makeRegrTask(data = data, target = "pseudo_res")
    
    learner = makeLearner("regr.rpart")
    mod = train(learner, task)
    pred.train = predict(mod, task)
    
    # baselearner logloss predictions for pseudo residuals
    baselearner_pred = pred.train$data$response
    baselearner_prob = exp(baselearner_pred)/(1+exp(baselearner_pred))
    
    # calculate overall prediction for boosting model
    overall_pred <- c(overall_pred + learning_rate*baselearner_pred)
    overall_prob <- exp(overall_pred)/(1+exp(overall_pred))
    #data$baselearner_pred = baselearner_pred
    
    
    #preds[[i]] <- overall_pred
    
    # plot baselearner predictions
    data_plot_base = data.frame(x1 = data$x1,x2 = data$x2, trueLabel = pseudo_res_prob)
    grid = expand.grid(seq(min(data$x1), max(data$x1), length.out = gridsize), 
                       seq(min(data$x2), max(data$x2), length.out = gridsize))
    colnames(grid) = c("x1","x2")
    pred.grid = predict(mod, newdata = grid)
    pred_grid = exp(pred.grid$data$response)/(1+exp(pred.grid$data$response))
    #grid[, "y"] = pred.grid$data$response
    #grid$y = as.factor(ifelse(pred_grid < 0.5, 0, 1))
    grid$prob = pred_grid
    p = ggplot(mapping = aes_string(x = "x1", y = "x2"))
    p = p + geom_raster(data = grid, mapping = aes_string(fill = "prob")) + scale_fill_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    
    p = p + geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel",
                                                         y = "x2"), size = 3)  + scale_colour_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    p = p + geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
   
    p = p + guides(color = FALSE) + ggtitle(expression(paste("probability of ", tilde(r)," and ", hat{b}^{"[m]"})))
    
    plots_baselearner[[i]] = p
    
    
    # plot overall predictions
    if(i == 1) pred.grid.cum = 0
    data_plot_base = data.frame(x1 = data$x1,x2 = data$x2, trueLabel = y)
    pred.grid.cum = pred.grid.cum + pred.grid$data$response
    prob.grid.cum = exp(pred.grid.cum)/(1+exp(pred.grid.cum))
    grid = expand.grid(seq(min(data$x1), max(data$x1), length.out = gridsize), 
                       seq(min(data$x2), max(data$x2), length.out = gridsize))
    colnames(grid) = c("x1","x2")
    #grid$y = as.factor(ifelse(prob.grid.cum < 0.5, 0, 1))
    grid$prob = prob.grid.cum
    p = ggplot(mapping = aes_string(x = "x1", y = "x2"))
    p = p + geom_raster(data = grid, mapping = aes_string(fill = "prob"))  + scale_fill_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    
    p = p + geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel",
                                                                   y = "x2"), size = 3) + scale_colour_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    p = p + geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
    
    p = p + guides(color = FALSE)
    
    p = p + ggtitle(expression(paste("y and probability of ", hat{f}^{"[m]"})))
    
    plots_boosting[[i]] = p
    
  }
  
 return(list(plots_baselearner, plots_boosting))
  
}



plots = plot_classif_boosting(data = X, y = y, gridsize = 50, iteration = 100, distribution = "logloss", learning_rate = 0.2)

# save selected plots with ggsave
m = c(1,2,5,10,100)

for(i in m){
  p = grid.arrange(plots[[2]][[i]], plots[[1]][[i]], nrow = 1)
  ggsave(filename = paste0("figure_man/boosting_classif_",i,".png"),plot = p, width = 9, height = 4)
}

