# see mlrmbo.mlr-org.com/articles/supplementary/machine_learning_with_mlrmbo.html
# run ggplot2 setup from setup.Rnw to get consistent theming before regenerating the figure.

library(mlr)
library(mlrMBO)
library(parallelMap)
library(ggplot2)

configureMlr(on.learner.warning = "quiet", show.learner.output = FALSE)
set.seed(12112) 

parallelStartMulticore(30)

task = sonar.task
learner = makeLearner("classif.rpart", predict.type = "prob")
params = makeParamSet(
  makeIntegerParam("maxdepth", lower = 1, upper = 30),
  makeIntegerParam("minsplit", lower = 1, upper = 105)
)
# create explicit resampling scheme so all tuning algorithms use same resampling folds:
cv10_sonar <- makeResampleInstance(cv10, sonar.task)

# to get "true" loss surface:
grid = makeTuneControlDesign(
  design = expand.grid(max.depth = 1:30, minsplit = seq(1, 105, by = 5))
)
tuning_grid = tuneParams(learner, task = task, par.set = params, resampling = cv10_sonar,
                         control = grid, measures = mlr::auc)


params = makeParamSet(
  makeIntegerParam("maxdepth", lower = 1, upper = 30),
  makeIntegerParam("minsplit", lower = 1, upper = 100)
)
random = makeTuneControlRandom(maxit = 150)
tuning_random = tuneParams(learner, task = task, par.set = params, resampling = cv10_sonar,
                           control = random, measures = mlr::auc)


mbo_ctrl = makeTuneControlMBO(mbo.control = 
                                setMBOControlTermination(
                                  makeMBOControl(resample.desc = cv10), 
                                  iters = 50))
tuning_mbo = tuneParams(learner, task = task, par.set = params, resampling = cv10_sonar,
                        control = mbo_ctrl, measures = mlr::auc)

bg <- ggplot(as.data.frame(tuning_grid$opt.path), aes(x = maxdepth, y = minsplit)) + 
  geom_tile(aes(fill = auc.test.mean, col = auc.test.mean))



saveRDS(list(grid = tuning_grid, random = tuning_random, mbo = tuning_mbo),
        file = "mbo-example.rds")


pdf("../figure_man/mbo_vs_random.pdf", width = 11, height = 6)
auc_range <- range(c(as.data.frame(tuning_grid$opt.path)$auc.test.mean, 
                     as.data.frame(tuning_random$opt.path)$auc.test.mean))
gridExtra::grid.arrange(
  bg + geom_path(data = as.data.frame(tuning_mbo$opt.path), alpha = .5) +
    geom_point(data = as.data.frame(tuning_mbo$opt.path)[-(1:6),], alpha = .2) +
    geom_text(data = as.data.frame(tuning_mbo$opt.path)[1:6,], aes(label = dob), alpha = 1) +
    theme(legend.position = "none") +
    ggtitle("MBO"),
  bg + geom_point(data = as.data.frame(tuning_random$opt.path), alpha = .5) + 
    labs(fill = "AUC", color = "AUC") +
    ggtitle("Random Search"),
 ggplot(as.data.frame(tuning_mbo$opt.path)) + geom_line(aes(x = dob, y = auc.test.mean)) + 
    labs(x = "iteration", y = "AUC") +
         #caption = bquote("runtime: "~.(round(sum(tuning_mbo$opt.path$env$exec.time)))~" sec")) +
   ylim(auc_range),
    ggplot(as.data.frame(tuning_random$opt.path)) + geom_line(aes(x = dob, y = auc.test.mean)) + 
      labs(x = "iteration", y = "AUC") +
      #caption = bquote("runtime: "~.(round(sum(tuning_random$opt.path$env$exec.time)))~" sec")) + 
    ylim(auc_range),
  ncol = 2, widths = c(1, 1.3), heights = c(1, 0.6))
dev.off()

parallelStop()
