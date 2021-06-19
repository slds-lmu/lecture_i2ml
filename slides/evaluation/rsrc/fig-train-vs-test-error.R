# PREREQ -----------------------------------------------------------------------
library(ggplot2)
library(tidyverse)
library(MASS)
library(dplyr)

# DATA -------------------------------------------------------------------------

set.seed(123L)
ss_iters = 50L


# EXPERIMENT -------------------------------------------------------------------

data = Boston
n = nrow(data)





plot_line <- function(results) {
  
}











#-------------------------------------------------------------------------------
# Increasing training set size (Traing error)
#-------------------------------------------------------------------------------

test_size = 206L
train_sizes = as.integer(c(seq(10, n-test_size, length.out= 8)))

x = colnames(data)[-c(4,14,2,9, 3, 12, 10)]
#formula = as.formula(paste('medv ~',paste('poly(',x,',1)',collapse = ' + '), '+ chas + zn + rad + indus +black+tax'))

formula = as.formula('medv ~ .')

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

p1 <- ggplot(data= results_train1, aes(x = train_size, y= mean_error)) +
  geom_line() +
  geom_point()+
  #theme_minimal() +
  #scale_color_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of training set") +
  ylab("MSE (training error)")

p1

ggsave("../figure/fig-train-vs-test-error-1.pdf", p1, width = 8, height = 5)

#-------------------------------------------------------------------------------
# Increasing training set size (Test error)
#-------------------------------------------------------------------------------

#test_size = 206L
##train_sizes = as.integer(c(3,seq(50, n-test_size, by= 50)))
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

p2 <- ggplot(data= results_train2, aes(x = train_size, y= mean_error)) +
  geom_line() +
  geom_point()+
  #theme_minimal() +
  #scale_color_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of training set") +
  ylab("MSE (test error)")

p2


ggsave("../figure/fig-train-vs-test-error-2.pdf", p2, width = 8, height = 5)



#-------------------------------------------------------------------------------
# Increasing test set size (Test error)
#-------------------------------------------------------------------------------

train_size = 306 
tests_sizes = as.integer(c(seq(50, n-train_size, length.out = 6)))

length = length(tests_sizes)*ss_iters
results_test = data.frame(error = numeric(length),
                           type = character(length),
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
p3 <- ggplot(data= results_test, aes(x = factor(test_size), y= error)) +
  geom_boxplot() +
  #theme_minimal() +
  #scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of test set") +
  ylab("MSE")+ 
  theme(legend.position = "none") +
  ylim(c(0,150))
p3 
ggsave("../figure/fig-train-vs-test-error-3.pdf", p3, width = 8, height = 5)
#-------------------------------------------------------------------------------
# Variation of model complexity (Train error)
#-------------------------------------------------------------------------------
complexity_k = seq(1, 10)
x = colnames(data)[-c(4,14,2,9, 3)]
formula_compl = lapply(complexity_k,
                       function (i)
                         as.formula(
                           paste('medv ~',paste('poly(',x,',', i, ')',collapse = ' + '), 
                                 '+ chas + zn + rad + indus')))

train_size = as.integer(0.7*n)

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


p4 <- ggplot(data= results_complexity1, aes(x = complexity, y= mean_error)) +
  geom_line() +
  geom_point()+
  #theme_minimal() +
  scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("degree") +
  #scale_x_discrete(limits = rev(unique(sort(results_complexity1$complexity)))) +
  ylab("MSE")
p4

ggsave("../figure/fig-train-vs-test-error-4.pdf", p4, width = 8, height = 5)

#-------------------------------------------------------------------------------
# Variation of model complexity (Test Error)
#-------------------------------------------------------------------------------

complexity_k = seq(1, 5)
x = colnames(data)[-c(4,14,2,9, 3)]
formula_compl = lapply(complexity_k,
                       function (i)
                       as.formula(
  paste('medv ~',paste('poly(',x,',', i, ')',collapse = ' + '), 
        '+ chas + zn + rad + indus')))

train_size = as.integer(0.7*n)

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
    
    pred_test = predict(lm, data[-train_set,])
    
    true_value = data$medv[-train_set]
    
    #calc MSE
    test_err = mean((pred_test - true_value)^2)
    
    
    #fill data frame 
    
    results_complexity2$complexity[index] = complexity_k[[j]]
    results_complexity2$error[index] = test_err
    results_complexity2$rep[index] = k
    index= index+1
  }
}


p5 <- ggplot(data= results_complexity2, aes(x = complexity, y= error)) +
  geom_boxplot() +
  #theme_minimal() +
  scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("degree") +
  ylab("MSE") +
  ylim(c(1,100))
p5

ggsave("../figure/fig-train-vs-test-error-5.pdf", p5, width = 8, height = 5)


