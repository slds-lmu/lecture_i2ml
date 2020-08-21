 
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

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plotModAbsoluteLoss = function (data, model, pt_idx, add_quadratic = TRUE)
{
  
  df_plot = data.frame(x = x[pt_idx], y = y[pt_idx], y_hat = predict(model)[pt_idx])
  df_plot$resid = df_plot$y_hat - df_plot$y
  df_plot$loss  = abs(df_plot$y_hat - df_plot$y)
  df_plot$loss_label = as.character(round(df_plot$loss, 2))
  df_plot$loss_qu = (df_plot$y_hat - df_plot$y)^2
  df_plot$loss_label_qu = as.character(round(df_plot$loss_qu, 2))
  
  gg1 = ggplot() +
    geom_point(data = data, aes(x = x, y = y)) +
    geom_abline(intercept = coef(model)[1], slope = coef(model)[2]) +
    geom_segment(data = df_plot, aes(x = x, y = y, xend = x, yend = y_hat), color = "red") +
    geom_point(data = df_plot, aes(x = x, y = y), color = "red", size = 2) +
    geom_text(data = df_plot, aes(x = x, y = y + resid/2, label = loss_label), color = "red", hjust = -0.5) +
    coord_fixed() + ggtitle("Data & Model") + xlim(-1.8, 5)
  
  gg2 = ggplot() +
    stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {abs(x)}) +
    geom_point(data = df_plot, aes(x = resid, y = loss), color = "red", size = 2) +
    geom_segment(data = df_plot, mapping = aes(x = resid, y = 0, xend = resid, yend = loss), color = "red") +
    xlab(expression(Residuals == y - f(x))) + ylab(expression(L(f(x), y))) +
    geom_text(data = df_plot, mapping = aes(x = resid, y = loss, label = loss_label), color = "red", hjust = -0.5) +
    ggtitle("Loss") + ylim(c(0, 16))
  
  if (add_quadratic) {
    gg2 = gg2 +
      stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {x^2}, alpha = 0.4) +
      geom_point(data = df_plot, aes(x = resid + 0.1, y = loss_qu), color = "red", size = 2, alpha = 0.4) +
      geom_segment(data = df_plot, mapping = aes(x = resid + 0.1, y = 0, xend = resid + 0.1, yend = loss_qu), color = "red", alpha = 0.4) +
      geom_text(data = df_plot, mapping = aes(x = resid + 0.1, y = loss_qu, label = loss_label_qu), color = "red", hjust = -0.5, alpha = 0.4)
  }
  return (gridExtra::grid.arrange(gg1, gg2, ncol = 2))
}



pdf("../figure/plot_abs_loss.pdf", height = 3)

set.seed(31415)

x = 1:5
y = 2 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)

model = lm(y ~ x)

plotModAbsoluteLoss(data, model = model, pt_idx = c(1,4), add_quadratic = FALSE) + ylim(c(0, 16))
ggsave("../figure/plot_abs_loss.pdf", width = 1.5, height = 1.5)
dev.off() 

