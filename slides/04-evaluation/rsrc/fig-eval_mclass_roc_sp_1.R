# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(ggrepel)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

source("plot_roc_space.R")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_1.pdf", width = 4, height = 4)

fpr = c(0.1, 0.30, 0.4)
tpr = c(0.7, 0.85, 0.6)
label = c("C1", "C2", "C3")

pl = plot_roc_space(fpr, tpr, label)
pl = pl + geom_segment(x = fpr[1], 
                       y = tpr[1], 
                       xend = fpr[2], 
                       yend = tpr[2], 
                       lty = "dotted")
pl = pl + geom_text_repel(data = data.frame(FPR = 0.20, TPR = 0.83, 
                                            label = "unclear winner"))
pl = pl + geom_segment(x = fpr[1], 
                       y = tpr[1], 
                       xend = fpr[3], 
                       yend = tpr[3], 
                       lty = "dotted")
pl = pl + geom_text_repel(data = data.frame(FPR = 0.25, TPR = 0.65, 
                                            label = "dominates"))
print(pl)

ggsave("../figure/eval_mclass_roc_sp_1.pdf", width = 4, height = 4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_2.pdf", width = 4, height = 4)

fpr = c(0, 1, 0, 0.25, 0.75)
tpr = c(1, 1, 0, 0.25, 0.75)
label = c("Best", "Pos-100%", "Pos-0%", "Pos-25%", "Pos-75%")

pl = plot_roc_space(fpr, tpr, label)
print(pl)

ggsave("../figure/eval_mclass_roc_sp_2.pdf", width = 4, height = 4)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_3.pdf", width = 4, height = 4)

fpr = c(0.75, 0.25)
tpr = c(0.25, 0.75)
label = c("C1", "C2")

pl = plot_roc_space(fpr, tpr, label)
pl = pl + geom_segment(x = 
                         fpr[1], 
                       y = tpr[1], 
                       xend = fpr[2], 
                       yend = tpr[2], 
                       lty = "dotted")
print(pl)

ggsave("../figure/eval_mclass_roc_sp_3.pdf", width = 4, height = 4)
dev.off()