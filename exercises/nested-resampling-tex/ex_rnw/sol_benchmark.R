library(mlbench)

## a)



task.list = list(iris.task,
                 sonar.task,
                 pid.task,
                 convertMLBenchObjToTask("mlbench.2dnormals", 500),
                 convertMLBenchObjToTask("mlbench.spirals", 500, cycles = 2, sd = 0.1)
                 )


## b)
classif.list = list(makeLearner("classif.lda"),
                    makeLearner("classif.qda"),
                    makeLearner("classif.rpart"),
                    makeLearner("classif.ctree"))



## c)
rdesc = makeResampleDesc("CV", iters = 10)


##d)

res = benchmark(classif.list, task.list, rdesc, measures = mmce)

res

getBMRPerformances(res)

getBMRAggrPerformances(res)


plotBMRSummary(res)

plotBMRBoxplots(res, style = "violin") + 
  aes(color = learner.id) +
  facet_wrap(~ task.id, nrow = 2) + geom_boxplot(width = 0.3)
