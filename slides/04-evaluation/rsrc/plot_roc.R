library(ggplot2)
library(gridExtra)

plotROC = function (df_auc, 
                    threshold, 
                    table = TRUE, 
                    auc = FALSE, 
                    highlight = TRUE) {
  
  bg_col_base = rep(c("#F2F2F2", "#CCCCCC"), length.out = nrow(df_auc))
  bg_col_base[df_auc$Score > threshold] = "#6BAED6"
  
  theme = ttheme_default(
    core = list(
      bg_params = list(fill = bg_col_base, 
                       alpha = rep(c(1, 0.5), length.out = nrow(df_auc)))
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
    p2 = p2 + geom_polygon(data = df_poly, 
                           aes(x, y), 
                           fill = "#6BAED6", 
                           alpha = 0.3)
  
  p2 = p2 + 
    geom_abline(intercept = 0, 
                slope = 1, 
                size = 1.3, 
                linetype = 2, 
                color = "gray") +
    geom_line(size = 1.3, color = "#6BAED6", alpha = 0.5) +
    geom_point(size = 3, shape = 23, fill = "#6BAED6", color = "#6BAED6") +
    xlab("False Positive Rate") +
    ylab("True Positive Rate") +
    xlim(0, 1) +
    ylim(0, 1)
  
  if (highlight) {
    
    p2 = p2 + 
      geom_point(data = df_plot[nrow(df_plot), ], 
                 aes(x, y), 
                 size = 3, 
                 shape = 23, 
                 fill = "#C67171", 
                 color = "#C67171")
    
  }
    
  if (table)
    return(gridExtra::grid.arrange(p1, p2, nrow = 1, widths = c(1,2)))
  
  return(p2)
  
}