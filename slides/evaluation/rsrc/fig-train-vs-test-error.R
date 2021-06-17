# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)
library(ggplot2)
library(tidyverse)

# DATA -------------------------------------------------------------------------

set.seed(1L)

#n_reps = 2L #50 !!
ss_iters = 50L

#n = 5000L
#n_2 = 50L
#data = data.table::as.data.table(mlbench::mlbench.spirals(n, sd = 1))

# EXPERIMENT -------------------------------------------------------------------
task = tsk("boston_housing")
n = task$nrow
#mlr3::TaskClassif$new("spirals", backend = data, target = "classes")
learner = lrn("regr.kknn", k = 2)

#-------------------------------------------------------------------------------
# Increasing training set size (Traing error)
#-------------------------------------------------------------------------------

test_size = 206L
train_sizes = as.integer(c(seq(10, n-test_size, length.out= 8)))
#task_sizes = test_size + train_sizes

length = length(train_sizes)*ss_iters
results_train1 = data.frame(error = numeric(length),
                  train_size = numeric(length),
                  rep = numeric(length),
                  stringsAsFactors = FALSE)

index = 1  
for (j in seq_along(train_sizes)) {
  
  #task_subset = task$clone()$filter(sample(n, task_sizes[[j]]))
  

  for(k in seq_len(ss_iters)){
    
    train_set = sample(task$nrow, train_sizes[[j]])
    test_set = setdiff(seq_len(task$nrow), train_set)
    
    learner$train(task, row_ids = train_set)
    
    #calculate training error
    pred_train = learner$predict(task, row_ids = train_set)
    train_err = pred_train$score() 
    
    
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
  select(train_size, mean_error) %>%
  distinct()

p1 <- ggplot(data= results_train1, aes(x = train_size, y= mean_error)) +
  geom_line() +
  geom_point()+
  theme_minimal() +
  #scale_color_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of training set") +
  ylab("MSE (training error)")

p1

ggsave("../figure/fig-train-vs-test-error-1.pdf", p1, width = 8, height = 3.5)

#-------------------------------------------------------------------------------
# Increasing training set size (Test error)
#-------------------------------------------------------------------------------
learner = lrn("regr.kknn", k = 2)
test_size = 206L
train_sizes = as.integer(c(3,seq(50, n-test_size, by= 50)))
#task_sizes = test_size + train_sizes

length = length(train_sizes)*ss_iters
results_train2 = data.frame(error = numeric(length),
                           train_size = numeric(length),
                           rep = numeric(length),
                           stringsAsFactors = FALSE)

index=1
for (j in seq_along(train_sizes)) {
  
  #task_subset = task$clone()$filter(sample(n, task_sizes[[j]]))
  
  
  for(k in seq_len(ss_iters)){
    
    train_set = sample(task$nrow, train_sizes[[j]])
    test_set = setdiff(seq_len(task$nrow), train_set)
    
    learner$train(task, row_ids = train_set)

    #calculate test error
    pred_test = learner$predict(task, row_ids = test_set)
    test_err = pred_test$score()
    
    
    #fill data frame 
    results_train2$train_size[index] = train_sizes[[j]]
    results_train2$error[index] = test_err
    results_train2$rep[index] = k
    
    index = index + 1
  }
}


# 
# results_train2 <- results_train2 %>% 
#   group_by(train_size) %>% 
#   mutate(mean_error = mean(error))  %>%
#   select(train_size, mean_error) %>%
#   distinct()

p2 <- ggplot(data= results_train2, aes(x = factor(train_size), y= error)) +
  geom_boxplot() +
  theme_minimal() +
  #scale_color_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of trainig set") +
  ylab("MSE (test error)")
p2



ggsave("../figure/fig-train-vs-test-error-2.pdf", p2, width = 8, height = 3.5)





#-------------------------------------------------------------------------------
# Increasing test set size (Test error)
#-------------------------------------------------------------------------------
learner = lrn("regr.kknn", k = 2)
train_size = 306 
tests_sizes = as.integer(c(seq(5L, n-train_size, length.out = 6)))
#task_sizes = tests_sizes + train_size



length = length(tests_sizes)*ss_iters
results_test = data.frame(error = numeric(length),
                           type = character(length),
                           test_size = numeric(length),
                           rep = numeric(length),
                           stringsAsFactors = FALSE)


index=1
for (j in seq_along(tests_sizes)) {
  
 #task_subset = task$clone()$filter(sample(n, task_sizes[[j]]))
  

  for(k in seq_len(ss_iters)){
    
    test_set = sample(task$nrow, tests_sizes[[j]])
    train_set = setdiff(seq_len(task$nrow), test_set)
    
    learner$train(task, row_ids = train_set)
  
    
    #calculate test error
    pred_test = learner$predict(task, row_ids = test_set)
    test_err = pred_test$score()
    
    
    #fill data frame
    
    results_test$test_size[index] = tests_sizes[[j]]
    results_test$error[index] = test_err
    results_test$rep[index] = k
    index=index+1
  }
}
p3 <- ggplot(data= results_test, aes(x = factor(test_size), y= error)) +
  geom_boxplot() +
  theme_minimal() +
  #scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("size of test set") +
  ylab("MSE")+ 
  theme(legend.position = "none")
p3 
ggsave("../figure/fig-train-vs-test-error-3.pdf", p3, width = 8, height = 3.5)
#-------------------------------------------------------------------------------
# Variation of model complexity (Train error)
#-------------------------------------------------------------------------------

complexity_k = c(5,  10, 50, 100, 150)
 

learners_complexity = lapply(
   complexity_k,
   function(i) mlr3::lrn("regr.kknn", k = i))

train_size = as.integer(0.7*n)

length = length(learners_complexity)*ss_iters
results_complexity1 = data.frame(error = numeric(length),
                           complexity = numeric(length),
                           rep = numeric(length),
                           stringsAsFactors = FALSE)

index=1
for (j in seq_along(learners_complexity)) {
  
  for(k in seq_len(ss_iters)){
    
    train_set = sample(task$nrow, train_size)
    
    test_set = setdiff(seq_len(task$nrow), train_set)
    
    learners_complexity[[j]]$train(task, row_ids = train_set)
    
    #calculate training error
    pred_train = learners_complexity[[j]]$predict(task, row_ids = train_set)
    train_err  = pred_train$score()
    
    #calculate test error
    pred_test = learners_complexity[[j]]$predict(task, row_ids = test_set)
    test_err = pred_test$score()
    
    
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
  select(complexity, mean_error) %>%
  distinct()


p4 <- ggplot(data= results_complexity1, aes(x = complexity, y= mean_error)) +
  geom_line() +
  geom_point()+
  theme_minimal() +
  scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("k") +
  #scale_x_discrete(limits = rev(unique(sort(results_complexity1$complexity)))) +
  ylab("MSE")
p4

ggsave("../figure/fig-train-vs-test-error-4.pdf", p4, width = 8, height = 3.5)

#-------------------------------------------------------------------------------
# Variation of model complexity (Test Error)
#-------------------------------------------------------------------------------

complexity_k = c(5, 10, 50, 100, 150)


learners_complexity = lapply(
  complexity_k,
  function(i) mlr3::lrn("regr.kknn", k = i))

train_size = as.integer(0.7*n)

length = length(learners_complexity)*ss_iters
results_complexity2 = data.frame(error = numeric(length),
                                complexity = factor(length, levels = complexity_k),
                                rep = numeric(length),
                                stringsAsFactors = FALSE)

index=1
for (j in seq_along(learners_complexity)) {
  
  for(k in seq_len(ss_iters)){
    
    train_set = sample(task$nrow, train_size)
    
    test_set = setdiff(seq_len(task$nrow), train_set)
    
    learners_complexity[[j]]$train(task, row_ids = train_set)
    
    #calculate test error
    pred_test = learners_complexity[[j]]$predict(task, row_ids = test_set)
    test_err = pred_test$score()
    
    
    #fill data frame 
    
    results_complexity2$complexity[index] = complexity_k[[j]]
    results_complexity2$error[index] = test_err
    results_complexity2$rep[index] = k
    index= index+1
  }
}


p5 <- ggplot(data= results_complexity2, aes(x = complexity, y= error)) +
  geom_boxplot() +
  theme_minimal() +
  scale_fill_viridis_d(begin= 0.4, end = 0.9) +
  xlab("k") +
  #scale_x_discrete(limits = rev(unique(sort(results_complexity2$complexity)))) +
  ylab("MSE")
p5

ggsave("../figure/fig-train-vs-test-error-5.pdf", p5, width = 8, height = 3.5)




# #-------------------------------------------------------------------------------
# # True Performance
# #-------------------------------------------------------------------------------
# resampling = mlr3::rsmp(
#   "subsampling", 
#   ratio = n_2 / n, 
#   repeats = ss_iters * 10L) 
# 
# resampling_result = mlr3::resample(
#   task, 
#   learner, 
#   resampling, 
#   store_models = FALSE)
# 
# true_performance = resampling_result$aggregate(mlr3::msr("classif.ce"))
# 
# 


