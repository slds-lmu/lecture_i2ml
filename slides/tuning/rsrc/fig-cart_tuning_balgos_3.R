source("plotTune.R")

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


set.seed(123)
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

