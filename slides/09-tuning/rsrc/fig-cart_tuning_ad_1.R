
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

source("plotTune.R")
options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))



scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


set.seed(123)

#figure 1
library(mlrMBO)
library(DiceKriging) #regr.km

test.fun = makeSingleObjectiveFunction(
  fn = function(x) x * sin(14 * x),
  par.set = makeNumericParamSet(lower = 0, upper = 1, len = 1L)
)

ctrl.ei = makeMBOControl()
ctrl.ei = setMBOControlTermination(ctrl.ei, iters = 4L)
ctrl.ei = setMBOControlInfill(ctrl.ei, crit = makeMBOInfillCritEI())

lrn.km = makeLearner("regr.km", predict.type = "se")

set.seed(112)
design = #data.frame(x = c(0.1, 0.3, 0.65, 1))
  data.frame(x = runif(7))

run.ei = exampleRun(test.fun, design = design, learner = lrn.km, control = ctrl.ei, show.info = FALSE)

pdf("../figure/cart_tuning_ad_1.pdf", width = 8, height = 4)
renderExampleRunPlot(run.ei, 1)
ggsave("../figure/cart_tuning_ad_1.pdf", width = 8, height = 4)
dev.off()


#figure 2
pdf("../figure/cart_tuning_ad_2.pdf", width = 8, height = 4)
renderExampleRunPlot(run.ei, 2)
ggsave("../figure/cart_tuning_ad_2.pdf", width = 8, height = 4)
dev.off()


#figure 3
pdf("../figure/cart_tuning_ad_3.pdf", width = 8, height = 4)
renderExampleRunPlot(run.ei, 3)
ggsave("../figure/cart_tuning_ad_3.pdf", width = 8, height = 4)
dev.off()


#figure 4
pdf("../figure/cart_tuning_ad_4.pdf", width = 8, height = 4)
renderExampleRunPlot(run.ei, 4)
ggsave("../figure/cart_tuning_ad_4.pdf", width = 8, height = 4)
dev.off()


