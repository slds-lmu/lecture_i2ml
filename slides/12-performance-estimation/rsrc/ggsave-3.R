
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)

######################################## ROC CURVE AND AUC

plot_roc_space = function(fpr, tpr, label) {
  require(ggrepel)
  d = data.frame(FPR = fpr, TPR = tpr, label = label)
  pl = ggplot(d, aes(x = FPR, y = TPR, label = label))
  pl = pl + geom_point(size = 3)
  pl = pl + geom_text_repel()
  pl = pl + xlim(c(0, 1)) + ylim(c(0,1))
  pl = pl + geom_abline(slope = 1, lty = "dotted")
}
fpr = c(0, 1, 0, 0.25, 0.75)
tpr = c(1, 1, 0, 0.25, 0.75)
label = c("Best", "always predict 1", "always predict 0", "predict 1 with \n prob. 25%", "predict 1 with \n prob. 75%")
pl = plot_roc_space(fpr, tpr, label)
print(pl)
############################################################################