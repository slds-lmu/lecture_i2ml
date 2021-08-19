library(titanic) # Contains the Data

# Machine Learning packages
library(mlr3)
library(mlr3learners)
library(mlr3tuning)
library(mlr3pipelines)
library(mlr3viz)

# Viz and preproc packages
library(ggplot2)
library(skimr)
library(stringi)


### Load and prepare Data ###

data(titanic_train)

str(titanic_train)
head(titanic_train)
skim(titanic_train)

titanic_train$Survived = as.factor(titanic_train$Survived)
titanic_train[which(titanic_train == "", arr.ind = TRUE)] = NA


task = TaskClassif$new("titanic", titanic_train, target = "Survived", positive = "1")
task$select(cols = setdiff(task$feature_names, c("PassengerId", "Cabin", "Name", "Ticket")))


### First benchmark of some Learner  

source("learners.R")

set.seed("160621")
rdesc = rsmp("cv", folds = 10L)$instantiate(task)

design = benchmark_grid(task, learners, rdesc)

if(file.exists("benchmark_result.rds")) {
  res = readRDS("benchmark_result.rds")
} else {
  res = benchmark(design)
  saveRDS(res, file = "benchmark_result.rds")
}

res$aggregate()
autoplot(res) + theme(axis.text.x = element_text(hjust = 1, angle = 45))

### Investigate first model ### 

forest_imp = learners$forest$clone()

forest_imp$param_set$values$classif.ranger.importance = "permutation"
forest_imp$train(task)


importance = as.data.table(forest_imp$model$classif.ranger$model$variable.importance, keep.rownames = TRUE)
colnames(importance) = c("Feature", "Importance")
p1 = ggplot(importance, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col() + coord_flip() + xlab("")
p1

### Let's try some feature Engineering ###

source("feat_eng.R")
skim(task_eng$data())

set.seed("160621")
design_eng = benchmark_grid(list(task, task_eng), learners$forest, rdesc)
res_eng = benchmark(design_eng)
res_eng$aggregate()
autoplot(res_eng)


forest_imp$train(task_eng)
importance_eng = as.data.table(forest_imp$model$classif.ranger$model$variable.importance, keep.rownames = TRUE)
colnames(importance_eng) = c("Feature", "Importance")
p2 = ggplot(importance_eng, aes(x = reorder(Feature, Importance), y = Importance)) + 
  geom_col() + coord_flip() + xlab("")

gridExtra::grid.arrange(p1, p2, ncol = 2)


### Predict on the test data ###

titanic_test$Survived = "0"
titanic_test$Survived = factor(titanic_test$Survived, levels = c("0", "1"))
titanic_test[which(titanic_test == "", arr.ind = TRUE)] = NA
test_task = TaskClassif$new("titanic", titanic_test, target = "Survived")
test_task$select(cols = setdiff(test_task$feature_names, "PassengerId"))
test_task = po_ftextract$train(list(test_task))[[1]]
test_task$select(cols = setdiff(test_task$feature_names, c("Cabin", "Name", "Ticket")))

preds = forest_imp$predict(test_task)$response

prediction_data = data.frame(PassengerId = titanic_test$PassengerId,
                             Survived = as.numeric(preds) - 1)

write.csv(prediction_data, file = "submission.csv", row.names = FALSE)

# Submitting this to Kaggle achieves an Accuracy of 0.76076
