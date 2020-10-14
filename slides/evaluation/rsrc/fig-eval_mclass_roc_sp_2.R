# PREREQ -----------------------------------------------------------------------

library(knitr)

source("plot_roc.R")

# DATA -------------------------------------------------------------------------

df_auc = data.frame(
  '#' = 1:12,
  Truth = c("Pos", "Neg")[c(1, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2)],
  Score = c(0.95, 0.86, 0.69, 0.65, 0.59, 0.52, 
            0.51, 0.39, 0.28, 0.18, 0.15, 0.06)
)
names(df_auc) = c("#", "Truth", "Score")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_4.pdf", width = 4, height = 4)

plotROC(df_auc, 0, highlight = FALSE, table = FALSE)

ggsave("../figure/eval_mclass_roc_sp_4.pdf", width = 4, height = 4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_5.pdf", width = 6, height = 4)

thresh = 0.9
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_5.pdf", width = 6, height = 4)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_6.pdf", width = 6, height = 4)

thresh = 0.85
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_6.pdf", width = 6, height = 4)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_7.pdf", width = 6, height = 4)

thresh = 0.66
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_7.pdf", width = 6, height = 4)
dev.off()

# PLOT 5 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_8.pdf", width = 6, height = 4)

thresh = 0.6
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_8.pdf", width = 6, height = 4)
dev.off()

# PLOT 6 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_9.pdf", width = 6, height = 4)

thresh = 0.55
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_9.pdf", width = 6, height = 4)
dev.off()

# PLOT 7 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_10.pdf", width = 6, height = 4)

thresh = 0.3
plotROC(df_auc, thresh)

ggsave("../figure/eval_mclass_roc_sp_10.pdf", width = 6, height = 4)
dev.off()

# PLOT 8 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_11.pdf", width = 6, height = 4)

plotROC(df_auc, 0, highlight = FALSE)

ggsave("../figure/eval_mclass_roc_sp_11.pdf", width = 6, height = 4)
dev.off()

# PLOT 9 -----------------------------------------------------------------------

pdf("../figure/eval_mclass_roc_sp_12_1.pdf", width = 6, height = 4)

plotROC(df_auc, 0, table = FALSE, auc = TRUE, highlight = FALSE)

ggsave("../figure/eval_mclass_roc_sp_12_1.pdf", width = 8, height = 4)