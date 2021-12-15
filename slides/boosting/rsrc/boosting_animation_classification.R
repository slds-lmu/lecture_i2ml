# ------------------------------------------------------------------------------
# FUN: BOOSTING ANIMATION CLASSIFICATION
# ------------------------------------------------------------------------------
library(mlr3)
library(ggplot2)
library(gridExtra)
library(data.table)
library(viridis)

theme_set(theme_gray())

set.seed(0)
# mlbench dataset circle
n_iter <- 100
n_train <- 100
n_test <- 10000
data_1 <- mlbench::mlbench.circle(n_train + n_test,2)
data <- data.table::data.table(data_1$x, data_1$classes)
data.table::setnames(data, c("x1", "x2", "y"))
y <- as.numeric(as.character(data$y))-1
X <- data[,c("x1", "x2")]

bernoulli_loss <- function(truth, pred) {
  N <- length(truth)
  acc <- 0
  for (i in 1:N) {
    acc <- acc + truth[i]*log(pred[i]) + (1-truth[i])*log(1-pred[i])
  }
  -1/N * acc
}

# create plot for simulation setting description
data_plot <- cbind(head(X, n_train), y=as.factor(head(y, n_train)))
plot_example <- ggplot() + geom_point(data = data_plot, aes(x = x1, y = x2, color =y), size = 3) + scale_color_manual(values = c("orange","darkblue"), breaks = c(0,1), labels = c(0,1))
ggsave("../figure/boosting_classif_example.png", plot_example, width = 5, height = 5)


# plot function
simulate_classif_boosting <- function(gridsize,
                                      iteration,
                                      init_constant,
                                      learning_rate) {

  # initialize overall prediction
  overall_pred <- rep(init_constant, length(y))
  
  # initialize output list
  plots_baselearner <- list()
  plots_boosting <- list()
  test_errors <- NULL
  train_errors <- NULL
  
  # Compute boosting procedure
  
  for (i in (seq_len(iteration))) {
    
    
    # calculate pseudo residuals
    pseudo_res <- y - (exp(overall_pred)/(1+exp(overall_pred)))
    
    
    # add pseudo_res to dataframe as target for base learner and fit glm
    task <- as_task_regr(cbind(X,pseudo_res=pseudo_res), target = "pseudo_res", id="circle")
    
    learner <- lrn("regr.rpart", maxdepth = 3)
    learner$train(task, row_ids=1:n_train)
    
    # baselearner logloss predictions for pseudo residuals
    baselearner_pred <- learner$predict(task)$data$response
    
    
    # calculate overall prediction for boosting model
    overall_pred <- overall_pred + learning_rate*baselearner_pred
    overall_prob <- exp(overall_pred)/(1+exp(overall_pred))
    train_errors <- c(train_errors, bernoulli_loss(head(y, n_train), head(overall_prob, n_train)))
    test_errors <- c(test_errors, bernoulli_loss(tail(y, n_test), tail(overall_prob, n_test)))
    
    #-----------------------------------------------------------------------------------------------
    # plot baselearner predictions
    
    # dataset for geom_point (true pseudo-residuals)
    data_plot_base <- data.frame(x1 = head(X, n_train)$x1, x2 = head(X, n_train)$x2, trueLabel = head(pseudo_res, n_train))
    
    # create grid with predictions of base learner
    grid <- expand.grid(seq(min(X$x1), max(X$x1), length.out = gridsize),
                       seq(min(X$x2), max(X$x2), length.out = gridsize))
    colnames(grid) <- c("x1","x2")
    pred_grid <- learner$predict_newdata(grid, task = task)
    grid$prob <- pred_grid$data$response
    
    # create plot
    p <- ggplot(mapping = aes_string(x = "x1", y = "x2"))
    
    # add baselearner predictions
    p <- p +
      geom_raster(data = grid, mapping = aes_string(fill = "prob")) + 
      scale_fill_gradientn(limits = c(-1,1), colors=c("orange", "darkblue"))
    
    # add pseudo residuals
    p <- p +
      geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel", y = "x2"), size = 3)  + 
      scale_colour_gradientn(limits = c(-1,1), colors=c("orange", "darkblue")) +
      geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
    
    # title / legend adjustments
    p <- p +
      guides(color = FALSE) + 
      ggtitle(expression(paste(tilde(r)," and ", hat(b)^{"[m]"})))  + 
      theme(legend.title=element_blank())
    
    # save plot
    plots_baselearner[[i]] <- p
    
    #-----------------------------------------------------------------------------------------------
    # plot overall predictions
    
    if(i == 1) pred_grid_cum <- 0
    
    # dataset for geom_point (true labels)
    data_plot_base <- data.frame(x1 = head(X, n_train)$x1, x2 = head(X, n_train)$x2, trueLabel = head(y, n_train))
    
    # add up base learner predictions for total boosting predictions and calculate probabilities
    pred_grid_cum <- pred_grid_cum + pred_grid$data$response
    prob_grid_cum <- exp(pred_grid_cum)/(1+exp(pred_grid_cum))
    grid <- expand.grid(seq(min(X$x1), max(X$x1), length.out = gridsize),
                       seq(min(X$x2), max(X$x2), length.out = gridsize))
    colnames(grid) <- c("x1","x2")
    grid$prob <- prob_grid_cum
    
    # create plot
    p <- ggplot(mapping = aes_string(x = "x1", y = "x2"))
    
    # add pi (predictions)
    p <- p +
      geom_raster(data = grid, mapping = aes_string(fill = "prob"))  + 
      scale_fill_gradientn(limits = c(0,1), colors=c("orange", "darkblue"))
    
    # add true Label y
    p <- p +
      geom_point(data = data_plot_base, mapping = aes_string(x = "x1", color = "trueLabel", y = "x2"), size = 3) + 
      scale_colour_gradientn(limits = c(0,1), colors=c("orange", "darkblue")) +
      geom_point(data = data_plot_base, mapping = aes(x = x1, y = x2), fill = NA, color = "white", pch = 21, size = 3)
    
    # title / legend adjustments
    p <- p +
      guides(color = FALSE) +
      ggtitle(expression(paste("y and ", hat(pi)(x))))
    
    # save plot
    plots_boosting[[i]] <- p
    
  }
  
 list(plots_baselearner=plots_baselearner,
      plots_boosting=plots_boosting,
      train_errors=train_errors,
      test_errors=test_errors)
  
}


# create plots
sims <- simulate_classif_boosting(gridsize = 50, iteration = n_iter, init_constant = 0, learning_rate = 0.2)

# save selected plots with ggsave
m <- c(1,2,5,10,100)

for (i in m) {
  p <- grid.arrange(sims$plots_boosting[[i]], sims$plots_baselearner[[i]], nrow = 1)
  ggsave(filename = paste0("../figure/boosting_classif_",i,".png"),plot = p, width = 9, height = 4)
}

error_df <- data.table(iter=1:n_iter, train_error=sims$train_errors, test_error=sims$test_errors)
error_df <- melt(error_df, id.vars = "iter", variable.name = "error_type", value.name = "loss_val")
colors <- viridis::viridis(2, end=0.9)
for (i in m) {
  p <- ggplot(data=error_df, mapping=aes(x=iter, y=loss_val, color=error_type)) +
    labs(x="iteration", y="bernoulli loss", color=element_blank()) +
    geom_line() +
    scale_color_viridis(discrete = TRUE, end=0.9) +
    geom_vline(xintercept = i, color="red") +
    geom_text(x=i + 1.5, y=0.2, label=i, color="red", size=3)


  ggsave(filename = paste0("../figure/boosting_classif_error_",i,".png"), plot = p, width = 10, height = 1.5)
}

