 
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


pdf("../figure/eval_mclass_roc_sp_3.pdf", width = 4, height = 4)
fpr = c(0.75, 0.25)
tpr = c(0.25, 0.75)
label = c("C1", "C2")
pl = plot_roc_space(fpr, tpr, label)
pl = pl + geom_segment(x = fpr[1], y = tpr[1], xend = fpr[2], yend = tpr[2], lty = "dotted")
print(pl)
ggsave("../figure/eval_mclass_roc_sp_3.pdf", width = 4, height = 4)
dev.off()

