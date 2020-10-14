# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(123)

D.ex <- rbinom(200, size = 1, prob = .5)
M1 <- rnorm(200, mean = D.ex, sd = .65)
M2 <- rnorm(200, mean = D.ex, sd = 1.5)

test <- data.frame(D = D.ex, 
                   D.str = c("Healthy", "Ill")[D.ex + 1],
                   M1 = M1, 
                   M2 = M2, 
                   stringsAsFactors = FALSE)

rocobj <- pROC::roc(test$D, test$M1)

# PLOT -------------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_13.pdf", width = 14, height = 7)

par(mfrow = c(1, 2))

pROC::plot.roc(rocobj, 
               print.auc = TRUE, 
               auc.polygon = TRUE, 
               partial.auc = c(1, 0.8), 
               partial.auc.focus = "sp", 
               reuse.auc = FALSE, 
               legacy.axes = TRUE, 
               xlab = "fpr", 
               ylab = "tpr", 
               xlim = c(1, 0), 
               ylim = c(0, 1),  
               auc.polygon.col = "red", 
               auc.polygon.density = 20, 
               auc.polygon.angle = 135, 
               partial.auc.correct = FALSE,  
               print.auc.cex = 2)

pROC::plot.roc(rocobj, 
               print.auc = TRUE, 
               auc.polygon = TRUE, 
               partial.auc = c(1, 0.8), 
               partial.auc.focus = "se", 
               reuse.auc = FALSE, 
               legacy.axes = TRUE, 
               xlab = "fpr", 
               ylab = "tpr", 
               xlim = c(1, 0), 
               ylim = c(0, 1),  
               auc.polygon.col = "red", 
               auc.polygon.density = 20, 
               auc.polygon.angle = 135, 
               print.auc.cex = 2)

ggsave("../figure/eval_mclass_roc_sp_13.pdf", width = 14, height = 7)
dev.off()