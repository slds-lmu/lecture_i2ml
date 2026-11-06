library(mlbench)
library(mlr3verse)
library(glue)

defaultW <- getOption("warn")
options(warn = -1)

set.seed(0)

n_train <- 100
n_test <- 10000
n_reps <- 10
spirals <- mlbench.spirals(n = n_train + n_test, cycles = 3)
X <- spirals$x
y <- spirals$classes
data <- as.data.frame(cbind(X, y))
data$y <- as.factor(data$y)
colnames(data) <- c("x1", "x2", "y")

tree_aucs <- NULL
maxdepths <- 1:20

knn_aucs <- NULL
ks <- 1:20

svm_aucs <- NULL
gammas <- 2^seq(from=log2(1e-2), to=log2(1e4), length.out=10)
Cs <- 2^seq(from=log2(1e-2), to=log2(1e4), length.out=10)
svm_params <- expand.grid(gammas, Cs)
colnames(svm_params) <- c("gamma", "C")

measure <- msr("classif.auc")


for (rep in 1:n_reps) {
  print(glue("Starting {rep}-th rep ..."))
  train_idx <- sample(seq_len(nrow(data)), size = n_train, replace = FALSE)

  # task <- as_task_classif(data, target = "y")
  train_df <- data[train_idx, ]
  test_df <- data[-train_idx, ]

  train_task <- as_task_classif(train_df, target = "y", positive = '1')
  test_task <- as_task_classif(test_df, target = "y", positive = '1')

  

  # Tree benchmark

  rep_tree_aucs <- NULL
  for (maxdepth in maxdepths) {
    tree_lrn <- lrn("classif.rpart",
                    predict_type = "prob",
                    maxdepth=maxdepth,
                    minsplit=1,
                    cp=0,
                    xval=1
    )
    tree_lrn$train(train_task)
    rep_tree_aucs <- c(rep_tree_aucs, tree_lrn$predict(test_task)$score(measure)[[1]])
  }

  if (is.null(tree_aucs)) {
    tree_aucs <- rep_tree_aucs
  } else {
    tree_aucs <- tree_aucs + rep_tree_aucs
  }

  # kNN Benchmark
  rep_knn_aucs <- NULL
  for (k in ks) {
    knn_lrn <- lrn("classif.kknn", k=k, predict_type="prob")
    knn_lrn$train(train_task)
    rep_knn_aucs <- c(rep_knn_aucs, knn_lrn$predict(test_task)$score(measure)[[1]])
  }

  if (is.null(knn_aucs)) {
    knn_aucs <- rep_knn_aucs
  } else {
    knn_aucs <- knn_aucs + rep_knn_aucs
  }

  # SVM Benchmark
  rep_svm_aucs <- NULL
  for (i in 1:nrow(svm_params)) {
    svm_lrn <- lrn("classif.svm",
                   kernel="radial",
                   cost=svm_params[i, ]$C,
                   gamma=svm_params[i, ]$gamma,
                   type="C-classification",
                   predict_type="prob"
    )

    svm_lrn$train(train_task)
    rep_svm_aucs <- c(rep_svm_aucs, svm_lrn$predict(test_task)$score(measure)[[1]])
  }

  if (is.null(svm_aucs)) {
    svm_aucs <- rep_svm_aucs
  } else {
    svm_aucs <- svm_aucs + rep_svm_aucs
  }


  print(glue("Finished {rep}-th rep"))
}

# Post process
tree_aucs <- tree_aucs/n_reps
knn_aucs <- knn_aucs/n_reps
svm_aucs <- svm_aucs/n_reps


tree_res_df <- data.frame(maxdepth=maxdepths, auc=tree_aucs)
knn_res_df <- data.frame(k=ks, auc=knn_aucs)
svm_res_df <- data.frame(gamma=svm_params$gamma, C=svm_params$C, auc=svm_aucs)

saveRDS(list(tree_res_df=tree_res_df, knn_res_df=knn_res_df, svm_res_df=svm_res_df), file = "tuning_importance.rds")

options(warn = defaultW)
