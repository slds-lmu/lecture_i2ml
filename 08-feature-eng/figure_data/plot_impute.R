library(mlr)
library(ggplot2)
library(dplyr)

root = rprojroot::find_root(rprojroot::is_git_root)

data = readr::read_csv(paste0(root, "/data/ames_housing_extended.csv"))
data = data[, ! grepl(pattern = "energy_t", x = names(data))]

data_new = data
names(data_new) = make.names(names(data_new))

data_new = data_new %>%
  select(-X1, -Fence, -Pool.QC, -Misc.Feature, -Alley) %>%
  select_if(is.numeric)

task = removeConstantFeatures(makeRegrTask(data = data_new, target = "SalePrice"))
task_no_missings = removeConstantFeatures(makeRegrTask(data = na.omit(data_new), target = "SalePrice"))

lrn = makeLearner("regr.lm")
lrn_impute_mean = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeMedian(), integer = imputeMedian()))
lrn_impute_med = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeMedian(), integer = imputeMedian()))
lrn_impute_hist = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeHist(), integer = imputeHist()), dummy.classes = c("numeric", "integer"))
lrn_impute_max = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeMax(2), integer = imputeMax(2)))
lrn_impute_model_rpart = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeLearner("regr.rpart"), integer = imputeLearner("regr.rpart")))

rf_surrogate = makeLearner("regr.randomForestSRC", ntree = 200L, mtry = 3L, nodesize = 200L)
lrn_impute_model_rf = makeImputeWrapper(learner = lrn, classes = list(numeric = imputeLearner(rf_surrogate), integer = imputeLearner(rf_surrogate)))


set.seed(31415)
res_no_impute = resample(learner = lrn, task = task_no_missings, resampling = cv10, measures = mae, show.info = FALSE)

res_instance = makeResampleInstance(cv10, task)
res_impute_mean = resample(learner = lrn_impute_mean, task = task, resampling = res_instance, measures = mae, show.info = FALSE)
res_impute_med = resample(learner = lrn_impute_med, task = task, resampling = res_instance, measures = mae, show.info = FALSE)
res_impute_hist = resample(learner = lrn_impute_hist, task = task, resampling = res_instance, measures = mae, show.info = FALSE)
res_impute_max = resample(learner = lrn_impute_max, task = task, resampling = res_instance, measures = mae, show.info = FALSE)
res_impute_model_rpart = resample(learner = lrn_impute_model_rpart, task = task, resampling = res_instance, measures = mae)
res_impute_model_rf = resample(learner = lrn_impute_model_rf, task = task, resampling = res_instance, measures = mae)

df_plot = data.frame(
  perf = c(res_no_impute$measures.test$mae, res_impute_mean$measures.test$mae, res_impute_med$measures.test$mae,
    res_impute_hist$measures.test$mae, res_impute_max$measures.test$mae,
    res_impute_model_rpart$measures.test$mae, res_impute_model_rf$measures.test$mae),
  technique = rep(c("No imputation", "Mean", "Median", "Histogram", "Max*2", "CART", "Random Forest"), each = 10)
)

save(list = "df_plot", file = "plot_impute.rds")
