 
library(mlr3)
library(R6)


#' @title MetaCost Class
#' 
#' @include Feedback.R
#'
#' @description
#' This is the class for the MetaCost algorithm.
#'



MetaCost = R6Class("MetaCost",
                  public = list(
                    
                    
                    #' @field classifier \cr
                    #' A character denoting the name of the classifier method (mlr3 package)
                    classifier = "classifier",
                    
                    #' @field metaclassifier \cr
                    #' A character denoting the name of the classifier method (mlr3 package)
                    meta_classifier = "classifier",
                    
                    #' @field task \cr
                    #' Stores data and metadata (mlr3 package)
                    task = 0,
                    
                    #' @field task_new \cr
                    #' Stores relabeld data and metadata (mlr3 package)
                    task_new = 0,
                    
                    #' @field C \cr
                    #' The cost matrix (dimensionality: g times g).
                    C = NULL,
                    
                    #' @field L \cr
                    #' Bagging iteration (integer).
                    L = 1,
                    
                    #' @field B \cr
                    #' Bootstrap sample size (integer).
                    B = 1,
                    
                    
                    
                    #' @description
                    #' Creates a new instance of this [R6][R6::R6Class] class.
                    #'
                    initialize = function(classifier, task, C, L, B){
                      
                      self$classifier           = classifier
                      self$C                    = C
                      self$L                    = L
                      self$B                    = B
                      self$meta_classifier      = classifier
                      self$task                 = task
                      
                    },
                    
                    
                    #' @description
                    #' running the MetaCost algorithm for the given problem instance (described by task).
                    #'
                    #' 
                    #'
                    train = function(row_ids) {
                      
                      # 1st phase: Bagging
                      
                      indices = matrix(rep(0,self$B*self$L),ncol=self$L)
                      
                      classifiers = c()
                    
                      for (l in 1:self$L){
                        
                        # bootstrapped data set (or rather the indices)
                        indices[,l]         = sort(sample(row_ids, size=self$B, replace = TRUE))
                        # fit classifier on bootstrapped data set
                        learner             = lrn(self$classifier, predict_type = "prob")
                        classifiers         = c(classifiers,learner$train(task, row_ids = indices[,l]))
                        
                      }
                      
                      #    2nd phase: Relabeling
                      
                      y_tilde               = task$data()[,1]
                      # compute the proxy probability vector
                      p                     = rep(0,g)
                      
                      for (i in row_ids){
                        
                        
                        # compute the proxy probability vector
                        p                   = rep(0,g)
 
                        tilde_L             = c()
                        
                        # get all bootstrapped data sets, where i is not included
                        
                        temp                = which(colSums(i==indices)==0)
                        
                        if (length(temp)==0){ # the data point appears in each bootstrapped sample -> use all classifiers
                          tilde_L     = 1:L
                        }
                        else { # only use classifiers which haven't seen the data point during training
                          tilde_L     = sort(temp)
                        }
                        
                        
                        for (l in tilde_L){
                          prediction  = classifiers[[l]]$predict(self$task, row_ids = c(i))
                          p           = p + prediction$prob
                        }
                        # average it
                        p             = p/length(tilde_L)
                        
                        # relabeling
                        # computes the estimated expected costs for predicting class 1,..,g
                        est_cost        = C %*% t(p)
                        # assign y the class with lowest estimated expected costs
                        y_tilde[i]      = which(est_cost==min(est_cost))[1]
                        
                      }
                      
                      # create the relabeled data set
                      data_rel        =  task$data()
                      #if(length(unique(y_tilde))==1){
                      #  y_tilde         =  c(y_tilde,unique(y_tilde))
                      #}

                      data_rel[,1]    =  y_tilde
                      self$task_new   =  TaskClassif$new("rel_data", backend = data_rel, target = task$target_names )
                      
                      print("Number of relabeled data points")
                      print(sum(self$task_new$data()[,1]!=self$task$data()[,1]))
                      
                      # initialize the cost-sensitive classifier
                      self$meta_classifier = lrn(self$classifier, predict_type = "prob")
                      
                      # 3rd phase: make classifier cost-sensitive
                      self$meta_classifier$train(self$task_new, row_ids = row_ids)         
                     
                    },
                    
                    
                    #' @description
                    #' running the MetaCost algorithm for the given problem instance (described by task).
                    #'
                    #' 
                    #'
                    predict = function(row_ids) {
                      self$meta_classifier$predict(self$task_new, row_ids = row_ids )
                    }
                    
                    
                  ),
                  
                  
                  
)

#
set.seed(123)

# we use the spam data in the mlr3 package (spam=positive)
task        = tsk("spam")
data        = task$data()
n_vec       = table(data[,1])
g           = length(n_vec) # number of classes (two of course)

# we make a random training-test split
train_set   = sort(sample(task$nrow, 0.8 * task$nrow))
#unique(data[train_set,1])

test_set    = setdiff(seq_len(task$nrow), train_set)
n           = length(train_set)

# we use a CART as a classifier
classifier  = "classif.rpart"

# Create the cost matrix via the heuristic

C = matrix(rep(0,g*g),ncol=2)

for (i in 1:g){
  for (j in 1:g){
    C[i,j]=max(n_vec[i]/n_vec[j],1)
  }
  C[i,i] = 0
}


meta      = MetaCost$new(classifier = classifier, task = task, C = C, L = 3, B = 10)
meta$train(row_ids = train_set)
meta_pred = meta$predict(row_ids = test_set)

# train also the cost-insensitive CART
learner     = lrn("classif.rpart", predict_type = "prob")
learner$train(task, row_ids = train_set)
CART_pred   = learner$predict(task, row_ids = test_set)


total_costs <- function(pred_vec,C){
  costs = 0
  for (i in 1:length(pred_vec)){
    costs = costs + C %*% t(pred_vec$prob[i])
  }
}

total_costs(meta_pred,C)
total_costs(CART_pred,C)




