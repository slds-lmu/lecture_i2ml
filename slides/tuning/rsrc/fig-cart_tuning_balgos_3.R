 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)

library(party)
library(rpart)
library(rpart.plot)
library(randomForest)
library(rattle)
library(smoof)
library(kableExtra)
library(kknn)
library(e1071)
library(rattle)

library(plyr)
library(kernlab)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


library(parallelMap)
library(ranger)
parallelStartMulticore(15)

# just run RS on spam for ranger so we can show an example path
# that improves the result

task = sonar.task
learner = makeLearner("classif.ranger", predict.type = "prob")

params = makeParamSet(
  makeIntegerParam("num.trees", lower = 3, upper = 200),
  makeIntegerParam("mtry", lower = 5, upper = 20),
  makeIntegerParam("min.node.size", lower = 2, upper = 20)
)
ctrl = makeTuneControlRandom(maxit = 150L)
tuning = tuneParams(learner, task = task, par.set = params, resampling = cv5,
                    control = ctrl, measures = mlr::auc)

BBmisc::save2("tune_example.RData", tune_example_res = tuning)

parallelStop()


set.seed(12322)
pdf("../figure/cart_tuning_balgos_3.pdf", width = 8, height = 3)
tr = BBmisc::load2("tune_example.RData")
df = as.data.frame(tr$opt.path)
ggd = df[, c("dob", "auc.test.mean")]
colnames(ggd) = c("iter", "auc")
ggd$auc = cummax(ggd$auc)
pl = ggplot(ggd, aes(x = iter, y = auc))
pl = pl + geom_line() 
pl = pl + theme_bw()
pl = pl + 
  theme(axis.text=element_text(size=18), axis.title=element_text(size=22)) +
  ylab("Maximal AUC") + xlab("Iterations")
print(pl)
ggsave("../figure/cart_tuning_balgos_3.pdf", width = 8, height = 3)
dev.off()

