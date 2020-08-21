setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
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
plotROC = function (df_auc, threshold, table = TRUE, auc = FALSE, highlight = TRUE) {
  
  bg_col_base = rep(c("#F2F2F2", "#CCCCCC"), length.out = nrow(df_auc))
  bg_col_base[df_auc$Score > threshold] = "#6BAED6"
  
  theme = ttheme_default(
    core = list(
      bg_params = list(fill = bg_col_base, alpha = rep(c(1, 0.5), length.out = nrow(df_auc)))
    )
  )
  
  if (table)
    p1 = gridExtra::tableGrob(df_auc, rows = NULL, theme = theme)
  
  n_pos = sum(df_auc$Truth == "Pos")
  n_neg = sum(df_auc$Truth == "Neg")
  
  fpr = cumsum(df_auc$Truth == "Neg") / n_neg
  tpr = cumsum(df_auc$Truth == "Pos") / n_pos
  
  
  plt_idx = df_auc$Score > threshold
  
  df_plot = data.frame(
    x = c(0, fpr[plt_idx]),
    y = c(0, tpr[plt_idx])
  )
  
  df_poly = df_plot[c(seq_len(nrow(df_plot)), rev(seq_len(nrow(df_plot)))), ]
  df_poly$y[nrow(df_plot) + seq_len(nrow(df_plot))] = 0
  
  
  p2 = ggplot(df_plot, aes(x = x, y = y))
  
  if (auc)
    p2 = p2 + geom_polygon(data = df_poly, aes(x, y), fill = "#6BAED6", alpha = 0.3)
  
  p2 = p2 + geom_abline(intercept = 0, slope = 1, size = 1.3, linetype = 2, color = "gray") +
    geom_line(size = 1.3, color = "#6BAED6", alpha = 0.5) +
    geom_point(size = 3, shape = 23, fill = "#6BAED6", color = "#6BAED6") +
    xlab("False Positive Rate") +
    ylab("True Positive Rate") +
    xlim(0, 1) +
    ylim(0, 1)
  
  if (highlight)
    p2 = p2 + geom_point(data = df_plot[nrow(df_plot), ], aes(x, y), size = 3, shape = 23, fill = "#C67171", color = "#C67171")
  
  if (table)
    return(gridExtra::grid.arrange(p1, p2, nrow = 1, widths = c(1,2)))
  
  return(p2)
}

df_auc = data.frame(
  '#' = 1:12,
  Truth = c("Pos", "Neg")[c(1, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2)],
  Score = c(0.95, 0.86, 0.69, 0.65, 0.59, 0.52, 0.51, 0.39, 0.28, 0.18, 0.15, 0.06)
)
names(df_auc) = c("#", "Truth", "Score")


pdf("eval_mclass_roc_sp_12_1.pdf", width = 8, height = 4)
plotROC(df_auc, 0, table = FALSE, auc = TRUE, highlight = FALSE)
ggsave("eval_mclass_roc_sp_12_1.pdf", width = 8, height = 4)
dev.off()

