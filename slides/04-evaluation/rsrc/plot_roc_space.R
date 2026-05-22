library(ggplot2)

plot_roc_space = function(fpr, tpr, label) {
  
  d = data.frame(FPR = fpr, TPR = tpr, label = label)
  pl = ggplot(d, aes(x = FPR, y = TPR, label = label))
  pl = pl + geom_point(size = 3)
  pl = pl + geom_text_repel()
  pl = pl + xlim(c(0, 1)) + ylim(c(0,1))
  pl = pl + geom_abline(slope = 1, lty = "dotted")
  
}
