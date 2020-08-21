 
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
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

source("plot_roc_space.R")
pdf("../figure/eval_mclass_roc_sp_1.pdf", width = 4, height = 4)


fpr = c(0.1, 0.30, 0.4)
tpr = c(0.7, 0.85, 0.6)
label = c("C1", "C2", "C3")
pl = plot_roc_space(fpr, tpr, label)
pl = pl + geom_segment(x = fpr[1], y = tpr[1], xend = fpr[2], yend = tpr[2], lty = "dotted")
pl = pl + geom_text_repel(data = data.frame(FPR = 0.20, TPR = 0.83, label = "unclear winner"))
pl = pl + geom_segment(x = fpr[1], y = tpr[1], xend = fpr[3], yend = tpr[3], lty = "dotted")
pl = pl + geom_text_repel(data = data.frame(FPR = 0.25, TPR = 0.65, label = "dominates"))
print(pl)
ggsave("../figure/eval_mclass_roc_sp_1.pdf", width = 4, height = 4)
dev.off()

