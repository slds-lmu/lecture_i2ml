# PREREQ -----------------------------------------------------------------------
library(tidyverse)
library(MASS)
library(dplyr)

# DATA -------------------------------------------------------------------------

set.seed(123L)
ss_iters = 50L

# EXPERIMENT -------------------------------------------------------------------
data = Boston
n = nrow(data)

#-------------------------------------------------------------------------------
# Increasing training set size (Training error)
#-------------------------------------------------------------------------------

test_size = 206L
train_sizes = as.integer(c(seq(10, n-test_size, length.out= 8)))

formula = as.formula('medv ~ .')

#data frame
length = length(train_sizes)*ss_iters
results_train1 = data.frame(error = numeric(length),
                            train_size = numeric(length),
                            rep = numeric(length),
                            stringsAsFactors = FALSE)

index = 1  
for (j in seq_along(train_sizes)) {
  
  for(k in seq_len(ss_iters)){
    
    #select train set
    train_set = sample(n, train_sizes[[j]])
    
    #train model
    lm=lm(formula, data=data[train_set,])
    
    # true and predicted values of the train set
    pred_train = predict(lm)
    true_value = data$medv[train_set]
    
    #calc MSE
    train_err = mean((pred_train - true_value)^2)
    
    #fill data frame 
    results_train1$train_size[index] = train_sizes[[j]]
    results_train1$error[index] = train_err
    results_train1$rep[index] = k
    
    index = index + 1
    
  }
}

results_train1 <- results_train1 %>% 
  group_by(train_size) %>% 
  mutate(mean_error = mean(error))  %>%
  dplyr::select(train_size, mean_error) %>%
  distinct()
#-------------------------------------------------------------------------------
# Increasing training set size (Test error)
#-------------------------------------------------------------------------------

train_sizes = c(30, 50, 75, 100, 150, 200,250, 300)

#data frame
length = length(train_sizes)*ss_iters
results_train2 = data.frame(error = numeric(length),
                            train_size = numeric(length),
                            rep = numeric(length),
                            stringsAsFactors = FALSE)

index=1
for (j in seq_along(train_sizes)) {
  for(k in seq_len(ss_iters)){
    
    #select train set
    train_set = sample(n, train_sizes[[j]])
    
    #train model
    lm =lm(formula, data=data[train_set,])
    
    # true and predicted values of the test set
    pred_test = predict(lm, data[-train_set,])
    true_value = data$medv[-train_set]
    
    #calc MSE
    test_err = mean((pred_test - true_value)^2)
    
    #fill data frame 
    results_train2$train_size[index] = train_sizes[[j]]
    results_train2$error[index] = test_err
    results_train2$rep[index] = k
    
    index = index + 1
  }
}


results_train2 <- results_train2 %>% 
  group_by(train_size) %>% 
  mutate(mean_error = mean(error))  %>%
  dplyr::select(train_size, mean_error) %>%
  distinct()

#-------------------------------------------------------------------------------
# Increasing test set size (Test error)
#-------------------------------------------------------------------------------

train_size = 306 
tests_sizes = as.integer(c(seq(50, n-train_size, length.out = 6)))

length = length(tests_sizes)*ss_iters
results_test = data.frame(error = numeric(length),
                          test_size = numeric(length),
                          rep = numeric(length),
                          stringsAsFactors = FALSE)


index=1
for (j in seq_along(tests_sizes)) {
  for(k in seq_len(ss_iters)){
    
    #select train set
    train_set = sample(n, train_sizes[[j]])
    
    #train model
    lm =lm(formula, data=data[train_set,])
    
    # true and predicted values of the test set
    pred_test = predict(lm, data[-train_set,])
    true_value = data$medv[-train_set]
    
    #calc MSE
    test_err = mean((pred_test - true_value)^2)
    
    
    #fill data frame
    results_test$test_size[index] = tests_sizes[[j]]
    results_test$error[index] = test_err
    results_test$rep[index] = k
    index=index+1
  }
}

results_test <- results_test %>% 
  dplyr::select(test_size, error) %>%
  distinct()


#-------------------------------------------------------------------------------
# Variation of model complexity (Train error)
#-------------------------------------------------------------------------------

#complexity
complexity_k = seq(1, 10)
x = colnames(data)[-c(4,14,2,9,3)]
formula_compl = lapply(complexity_k,
                       function (i)
                         as.formula(
                           paste('medv ~',paste('poly(',x,',', i, ')',
                                                collapse = ' + '), 
                                 '+ chas + zn + rad + indus')))

train_size = as.integer(0.7*n)

#data frame
length = length(complexity_k)*ss_iters
results_complexity1 = data.frame(error = numeric(length),
                                 complexity = numeric(length),
                                 rep = numeric(length),
                                 stringsAsFactors = FALSE)


index=1
for (j in seq_along(complexity_k)) {
  for(k in seq_len(ss_iters)){
    
    #select train set
    train_set = sample(n, train_size)
    
    #train model
    lm =lm(formula_compl[[j]], data=data[train_set,])
    
    # true and predicted values of the train set
    pred_train = predict(lm)
    true_value = data$medv[train_set]
    
    #calc MSE
    train_err = mean((pred_train - true_value)^2)
    
    #fill data frame 
    results_complexity1$complexity[index] = complexity_k[[j]]
    results_complexity1$error[index] = train_err
    results_complexity1$type[index] = "train error"
    results_complexity1$rep[index] = k
    index= index+1
    
  }
}

results_complexity1 <- results_complexity1 %>% 
  group_by(complexity) %>% 
  mutate(mean_error = mean(error))  %>%
  dplyr::select(complexity, mean_error) %>%
  distinct()

#-------------------------------------------------------------------------------
# Variation of model complexity (Test Error)
#-------------------------------------------------------------------------------
complexity_k = seq(1, 5)
formula_compl = formula_compl [1:length(complexity_k)]

#data frame
length = length(complexity_k)*ss_iters
results_complexity2 = data.frame(error = numeric(length),
                                 complexity = factor(length, levels = complexity_k),
                                 rep = numeric(length),
                                 stringsAsFactors = FALSE)

index=1
for (j in seq_along(complexity_k)) {
  for(k in seq_len(ss_iters)){
    
    #select train set
    train_set = sample(n, train_size)
    
    #train model
    lm =lm(formula_compl[[j]], data=data[train_set,])
    
    # true and predicted values of the test set
    pred_test = predict(lm, data[-train_set,])
    true_value = data$medv[-train_set]
    
    #calculate MSE
    test_err = mean((pred_test - true_value)^2)
    
    
    #fill data frame 
    results_complexity2$complexity[index] = complexity_k[[j]]
    results_complexity2$error[index] = test_err
    results_complexity2$rep[index] = k
    index= index+1
  }
}

results_complexity2 <- results_complexity2 %>% 
  dplyr::select(complexity, error) %>%
  distinct()