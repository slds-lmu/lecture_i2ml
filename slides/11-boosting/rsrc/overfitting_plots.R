# classif.boosting is really sloooow, because ada implementation sucks
library(mlr)
library(reshape2)
library(ggplot2)

set.seed(121)
task = convertMLBenchObjToTask("mlbench.spirals", n = 200, sd = 0.2)
n.trees = c(1, seq(100, 1000, by = 100))

rf = makeLearner("classif.randomForest")
ada = makeLearner("classif.gbm", shrinkage = 0.1, distribution = "adaboost", 
    interaction.depth = 8L, bag.fraction = 1)

rin = makeResampleInstance("RepCV", folds = 5, reps = 5, task = task)

ps1 = makeParamSet(makeDiscreteParam("ntree", values = n.trees))
ps2 = makeParamSet(makeDiscreteParam("n.trees", values = n.trees))

ctrl = makeTuneControlGrid()

tr1 = tuneParams(rf, task, rin, par.set = ps1, control = ctrl)
tr2 = tuneParams(ada, task, rin, par.set = ps2, control = ctrl)

op1 = as.data.frame(tr1$opt.path)[,1:2]
names(op1) = c("M", "mmce")
op1$learner = "rf"
op2 = as.data.frame(tr2$opt.path)[,1:2]
names(op2) = c("M", "mmce")
op2$learner = "ada"
ops = rbind(op1, op2)

p = ggplot(ops, aes(x = M, y = mmce, col = learner, group = learner)) + 
  geom_line()  +
  xlab("trees")
ggsave("figure_man/overfitting_plot_ntree.png", p)

p1 = plotLearnerPrediction(cv = 5L,
  makeLearner("classif.randomForest", ntree = 1000L), task
)
p2 = plotLearnerPrediction(cv = 5L,
  makeLearner("classif.gbm", shrinkage = 1L, interaction.depth = 1L, n.trees = 1000L, 
    distribution = "adaboost"), task
)


ggsave("figure_man/overfitting_plot_rf.png", p1)
ggsave("figure_man/overfitting_plot_boost.png", p2)



