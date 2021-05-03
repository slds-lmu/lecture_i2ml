################################################################################
#######################  Visualising AdaBoost in mlr2 ##########################
################################################################################


################################################################################
#Libraries
################################################################################
library(ggplot2)
library(mlr)
library(grid)
library(gridExtra)

source("rsrc/plotLearnerPrediction.R")
theme_set(theme_bw())

################################################################################
#Adaboost Algorithm 
################################################################################

adaboost_plot <- function(M){
  
  ################################################################################
  #Initializing values
  ################################################################################
  
  browser()
  # #create toy data frame
  ################################################################
  x1 <-c(10,12,16,18,3,7,12,4,6,18)
  x2 <-c(19,22,18,20,12,13,11,5,2,5)
  class <-  c(1,1,1,-1,1,-1,-1,1,-1,-1)
  label <- seq(1,10)
  df <- data.frame (x1 = x1, x2 = x2, class = factor(class),  label = label)
  #############################################################
  
  #number of observations
  n <- nrow(df)
  
  #initialize vectors
  beta_hat <- c()
  b_hat <- list()
  
  #Initialize observation weights: w[1](i) = 1/n
  weights <- rep(1/n, n)
  
  plots = list()

  #repeat for m interations
  for(m in (1:M)){
    
    #update weights
    task = makeClassifTask(id = "toy_data", 
                           data = data.frame(x1 = x1,
                                             x2 = x2,
                                             class = factor(class)),
                           weights = weights, 
                           target = "class")
    
    learner = makeLearner("classif.rpart", maxdepth = 1, minsplit = 1)
    #learner = makeWeightedClassesWrapper(learner, wcw.weight = weights)
    
    #Fit classifier to training data with weights w[m] and get ^b[m
    learner_train = train(learner,task, weights = weights)
    
    # prediction with rpart
    prediction = predict(learner_train, task, predict_type = "response")
    
    prediction <- as.data.frame(prediction)
    
    #vector which predictions are misclassified 
    misclassified <- (!prediction$truth==prediction$response)
    
    #Calculate weighted in-sample misclassification rate
    
    error <- sum(weights[misclassified])#/sum(weights)
    
    # beta hat
    beta_hat[m] <- 0.5*log((1-error)/error)
    
    #set new weights
    #weights <- weights * exp(beta_hat[m]*as.numeric(misclassified))
    weights <- weights * exp(-beta_hat[m]*as.numeric(as.character(prediction$truth))*as.numeric(as.character(prediction$response)))
    
    # normalize weights
    weights = weights/sum(weights)
    print(m) 
    plots[[m]] <- plotLearnerPrediction(learner, task, prob.alpha = FALSE)+ 
      ggtitle("")+
      xlab(expression(x[1]))+
      ylab(expression (x[2])) 
  }
  
  # plot <- ggplot(df, aes(x=x1, y = x2, shape = class)) +
  #   geom_point(fill="lightgray", size = weights*20) +
  #   scale_shape_manual(values = c(16, 17)) +
  #   theme_light()+
  #   xlim(c(0,25)) +
  #   ylim(c(0,25)) +
  #   # geom_text(aes(label=label),hjust=0, vjust=-1.5)+
  #   theme_grey() + 
  #   ggtitle("")+
  #   xlab(expression(x[1]))+
  #   ylab(expression (x[2]))  
  
  
  
  return(plots)
}

plots = adaboost_plot(3)

g1 = grid.arrange(plots[[1]])

g2 <- do.call(grid.arrange, c(plots[2:3], nrow=2))
# print(g)
ggsave(file = "figure_man/adaboost_viz_mlr_1.png", g1, height = 4)
ggsave(file = "figure_man/adaboost_viz_mlr_2.png", g2, height = 8)




