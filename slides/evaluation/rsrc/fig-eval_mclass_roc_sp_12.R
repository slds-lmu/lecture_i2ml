 
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



pdf("../figure/eval_mclass_roc_sp_12.pdf", width = 4.5, height = 3)
plot_roc_curves = function(d) {
  pl = ggplot(d, aes(x = FPR, y = TPR, col = model)) +  scale_color_viridis(discrete = TRUE, option = "D")
  pl = pl + geom_line(size = 2)
  pl = pl + xlim(c(0, 1)) + ylim(c(0,1))
  pl = pl + geom_abline(slope = 1, lty = "dotted")
}
n = 10
fpr = seq(0, 1, length.out = n)
tpr1 = pbeta(fpr, shape1 = 0.3, shape2 = 9)
tpr2 = pbeta(fpr, shape1 = 1, shape2 = 3)
tpr3 = pbeta(fpr, shape1 = 2, shape2 = 5)
tpr4 = pbeta(fpr, shape1 = 0.9, shape2 = 1)
d = rbind(
  data.frame(FPR = fpr, TPR = tpr1, model = "very good"),
  data.frame(FPR = fpr, TPR = tpr2, model = "ok1"),
  data.frame(FPR = fpr, TPR = tpr3, model = "ok2"),
  data.frame(FPR = fpr, TPR = tpr4, model = "bad")
)
pl = plot_roc_curves(d)
print(pl)
ggsave("../figure/eval_mclass_roc_sp_12.pdf", width = 4.5, height = 3)
dev.off()

