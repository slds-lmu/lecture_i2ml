baseline = lrn("classif.featureless")
baseline$id = "Baseline"

baseline2 = GraphLearner$new(id = "Gender", 
                             po("select", param_vals = list(selector = selector_name("Sex"))) %>>% lrn("classif.log_reg"))

logreg = GraphLearner$new(id = "Logistic Regression",
                          pipeline_robustify(factors_to_numeric = FALSE) %>>% lrn("classif.log_reg"))

tree = GraphLearner$new(id = "Classification Tree",
                        pipeline_robustify(factors_to_numeric = FALSE) %>>% lrn("classif.rpart"))

forest = GraphLearner$new(id = "Random Forest",
              pipeline_robustify(factors_to_numeric = FALSE) %>>% lrn("classif.ranger"))

#### Tuned KNN ####

searchspace_knn_trafo = ParamSet$new(list(
  ParamDbl$new("k", log(1), log(50))
))

searchspace_knn_trafo$trafo = function(x, param_set) {
  x$k = round(exp(x$k))
  return(x)
}

knn_tuned = AutoTuner$new(
  learner = lrn("classif.kknn", kernel = "rectangular"),
  resampling = rsmp("cv", folds = 10), measure = msr("classif.ce"),
  terminator = trm("none"),
  tuner = tnr("grid_search", resolution = 10),
  search_space = searchspace_knn_trafo)

knn = GraphLearner$new(id = "KNN", pipeline_robustify(factors_to_numeric = FALSE) %>>% knn_tuned)

learners = list(
  baseline = baseline,
  baseline2 = baseline2,
  logreg =logreg, 
  tree = tree, 
  forest = forest, 
  knn = knn)
  