# see mlrmbo.mlr-org.com/articles/supplementary/machine_learning_with_mlrmbo.html
# run ggplot2 setup from setup.Rnw to get consistent theming before regenerating the figure.

library(mlr)
library(mlrMBO)
library(parallelMap)
library(ggplot2)

configureMlr(on.learner.warning = "quiet", show.learner.output = FALSE)
# set.seed(12112) !! too good
set.seed(121211)

parallelStartMulticore(30)

task = sonar.task

learner = makeLearner("classif.rpart", predict.type = "prob")

params = makeParamSet(
  makeIntegerParam("maxdepth", lower = 1, upper = 30),
  makeIntegerParam("minsplit", lower = 1, upper = 105)
)
# to get "true" loss surface:
grid = makeTuneControlDesign(
  design = expand.grid(max.depth = 1:30, minsplit = seq(1, 105, by = 5))
)
tuning_grid = tuneParams(learner, task = task, par.set = params, resampling = cv10,
                         control = grid, measures = mlr::auc)


params = makeParamSet(
  makeIntegerParam("maxdepth", lower = 1, upper = 30),
  makeIntegerParam("minsplit", lower = 1, upper = 100)
)
random = makeTuneControlRandom(maxit = 150)
tuning_random = tuneParams(learner, task = task, par.set = params, resampling = cv10,
                           control = random, measures = mlr::auc)


mbo_ctrl = makeTuneControlMBO(mbo.control = 
                                setMBOControlTermination(
                                  makeMBOControl(resample.desc = cv10), 
                                  iters = 50))
tuning_mbo = tuneParams(learner, task = task, par.set = params, resampling = cv10,
                        control = mbo_ctrl, measures = mlr::auc)

bg <- ggplot(as.data.frame(tuning_grid$opt.path), aes(x = maxdepth, y = minsplit)) + 
  geom_tile(aes(fill = auc.test.mean, col = auc.test.mean))

saveRDS(list(grid = tuning_grid, random = tuning_random, mbo = tuning_mbo),
        file = "mbo-example.rds")


pdf("../figure_man/mbo_vs_random.pdf", width = 11, height = 6)
gridExtra::grid.arrange(
  bg + geom_point(data = as.data.frame(tuning_random$opt.path), alpha = .5) + 
    theme(legend.position = "none") +
    ggtitle("Random Search"),
  bg + geom_point(data = as.data.frame(tuning_mbo$opt.path), alpha = .5) + 
    ggtitle("MBO") + labs(fill = "AUC", color = "AUC"),
  ncol = 2, widths = c(1, 1.3))
dev.off()

parallelStop()
