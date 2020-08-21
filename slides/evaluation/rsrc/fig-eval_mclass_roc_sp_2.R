 
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


pdf("../figure/eval_mclass_roc_sp_2.pdf", width = 4, height = 4)
fpr = c(0, 1, 0, 0.25, 0.75)
tpr = c(1, 1, 0, 0.25, 0.75)
label = c("Best", "Pos-100%", "Pos-0%", "Pos-25%", "Pos-75%")
pl = plot_roc_space(fpr, tpr, label)
print(pl)
ggsave("../figure/eval_mclass_roc_sp_2.pdf", width = 4, height = 4)
dev.off()

