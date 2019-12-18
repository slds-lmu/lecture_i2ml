## Resampling vs. Nested Resampling: Overtuning
## -----------------------------------------------------------------------------

# DON'T RUN!!! This takes ~ 2 Days

library(ggplot2)
library(mlr)

parallelMap::parallelStartSocket(parallel::detectCores() / 2)


makeRLearner.classif.useless = function()
{
  makeRLearnerClassif(
    cl = "classif.useless",
    package = "mlr",
    par.set = makeParamSet(
      makeDiscreteLearnerParam(id = "method", default = "majority", values = c("majority", "sample-prior")),
      makeNumericLearnerParam(id = "useless", default = 0, lower = -Inf, upper = Inf)
    ),
    properties = c("twoclass", "multiclass", "numerics", "factors", "ordered", "missings", "prob", "functionals"),
    name = "Useless classifier",
    short.name = "useless"
  )
}

trainLearner.classif.useless = mlr:::trainLearner.classif.featureless
predictLearner.classif.useless = mlr:::predictLearner.classif.featureless

nrepeat = 50L
data_dims = c(50L, 100L, 250L, 500L)
rs_points = seq(50, 500, 10)

learner = "classif.useless"
ps = makeParamSet(makeNumericParam("useless", lower = -100, upper = 100))

nestedResampleExperiment = function (nrepeat, data_dims, rs_points, learner, ps, nested)
{
  results = lapply(X = data_dims, FUN = function (ndim) {

    df_sim = data.frame(target = sample(c("A", "B"), size = ndim, replace = TRUE))
    task = makeClassifTask(data = df_sim, target = "target")

    data.frame(
      performance = as.numeric(vapply(X = rs_points, FUN.VALUE = numeric(nrepeat), FUN = function (npoints) {
        vapply(X = seq_len(nrepeat), FUN.VALUE = numeric(1L), FUN = function (x) {
          if (nested) {
            learner_nested = makeTuneWrapper(learner, resampling = cv10, par.set = ps, control = makeTuneControlRandom(maxit = npoints), show.info = FALSE)
            mean(resample(learner = learner_nested, task = task, resampling = cv3)$measures.test$mmce)
          } else {
            tuneParams(learner = learner, task = task, resampling = cv10, par.set = ps, control = makeTuneControlRandom(maxit = npoints))$y
          }
        })
      })),
      number_points = rep(x = rs_points, each = nrepeat),
      data_dim = rep(x = ndim, each = nrepeat)
    )
  })
  out = do.call(rbind, results)
  out$number_points = as.factor(out$number_points)
  out$data_dim = as.factor(out$data_dim)

  return(out)
}


tune_results = nestedResampleExperiment(nrepeat, data_dims, rs_points, learner, ps, FALSE)
tune_results$tuning_method = "resampling"
nested_results = nestedResampleExperiment(nrepeat, data_dims, rs_points, learner, ps, TRUE)
nested_results$tuning_method = "nested resampling"

df_overtuning = do.call(rbind, list(tune_results, nested_results))
df_overtuning$tuning_method = as.factor(df_overtuning$tuning_method)

save(list = "df_overtuning", file = "overtuning_data.rds")

# load("chapters/ml/ml_nested_resampling/code/overtuning_data.rds")

# library(dplyr)
# library(ggplot2)

# df_overtuning %>%
#   group_by(data_dim, tuning_method, number_points) %>%
#   summarize(performance = mean(performance)) %>%
#   mutate(number_points = as.integer(as.character(number_points))) %>%
#   ggplot(aes(x = number_points, y = performance, color = data_dim, linetype = tuning_method)) +
#     geom_line() +
#     scale_color_brewer(name = "# Observations", palette = "Set1") +
#     ggthemes::theme_tufte() +
#     xlab("Amount of tried hyperparameter configurations") +
#     ylab("Tuned Performance") +
#     scale_linetype_discrete(name = "")

