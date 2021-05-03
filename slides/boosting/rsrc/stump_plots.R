library(mlr)
library(ggplot2)
set.seed(121)

task = convertMLBenchObjToTask("mlbench.spirals", n = 200)
n.trees = c(1, seq(100, 1000, by = 100))

rf = makeLearner("classif.randomForest", maxnodes = 2L)
ada = makeLearner("classif.gbm", distribution = "adaboost", interaction.depth = 1L)

rin = makeResampleInstance("RepCV", folds = 5, reps = 5, task = task)

ps1 = makeParamSet(makeDiscreteParam("ntree", values = n.trees))
ps2 = makeParamSet(makeDiscreteParam("n.trees", values = n.trees))

ctrl = makeTuneControlGrid()

tr1 = tuneParams(rf, task, rin, par.set = ps1, control = ctrl)
tr2 = tuneParams(ada, task, rin, par.set = ps2, control = ctrl)

op1 = as.data.frame(tr1$opt.path)[,1:2]
names(op1) = c("M", "mmce")
op1$learner = "rf_stumps"
op2 = as.data.frame(tr2$opt.path)[,1:2]
names(op2) = c("M", "mmce")
op2$learner = "ada"
ops = rbind(op1, op2)

p = ggplot(ops, aes(x = M, y = mmce, col = learner, group = learner)) + 
  geom_line()  +
  xlab("trees")
ggsave("figure_man/stump_plot_ntree.png", p)

# print(p)


rf = setHyperPars(rf, ntree = 1000)
p1 = plotLearnerPrediction(rf, task)
ada = setHyperPars(ada, n.trees = 1000)
p2 = plotLearnerPrediction(ada, task)

ggsave("figure_man/stump_plot_rf.png", p1)
ggsave("figure_man/stump_plot_boost.png", p2)


