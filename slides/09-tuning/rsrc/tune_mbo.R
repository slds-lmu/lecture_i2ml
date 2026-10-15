set.seed(1)
library(mlr3)
library(mlr3tuning)
library(mlrintermbo)
library(ggplot2)

data("titanic", package = "mlr3data")
task = tsk("pima")
task = as_task_classif(titanic, target = "survived", positive = "yes")
all_train = as.data.frame(task$data())

train <- all_train[, -c(
which(colnames(all_train) == "cabin"),
which(colnames(all_train) == "name"),
which(colnames(all_train) == "ticket")
)]
str(train)

task <- TaskClassif$new(
  id = "titanic_train", backend = na.omit(train),
  target = "survived"
)
# check

learner = lrn("classif.rpart", cp = to_tune(lower = 1e-04, upper = 0.05, logscale = FALSE),
              minsplit = to_tune(1, 100))
set.seed(3)
num_reps = 10

mbo_datas = list()
for(i in 1:num_reps){
  instance = tune(
    method = "intermbo",
    task = task,
    learner = learner,
    resampling = rsmp("cv", folds = 10),
    measure = msr("classif.acc"),
    term_evals = 50
  )
  mbo_datas = append(mbo_datas, list(instance$archive$data))
}

mbo_data = mbo_datas[[1]]

random_datas = list()
set.seed(123)

for(i in 1:num_reps){
  instance = tune(
    method = "random_search",
    task = task,
    learner = learner,
    resampling = rsmp("cv", folds = 10),
    measure = msr("classif.acc"),
    term_evals = 50
  )
  random_datas = append(random_datas, list(instance$archive$data))
}

random_data = random_datas[[1]]
  
instance = tune(
  method = "grid_search",
  task = task,
  learner = learner,
  resampling = rsmp("cv", folds = 10),
  measure = msr("classif.acc"),
  resolution = 20
)

grid_data = instance$archive$data

BBmisc::save2("tune_mbo.RData", grid=grid_data, mbo=mbo_data, rand=random_data,
              mbos=mbo_datas, rands=random_datas)

