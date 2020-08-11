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

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plotModQuadraticLoss = function (data, model, loss, pt_idx)
{
  
  df_plot = data.frame(x = x[pt_idx], y = y[pt_idx], y_hat = predict(model)[pt_idx])
  df_plot$resid = df_plot$y_hat - df_plot$y
  df_plot$loss  = (df_plot$y_hat - df_plot$y)^2
  df_plot$loss_label = as.character(round(df_plot$loss, 2))
  
  gg1 = ggplot() +
    geom_point(data = data, aes(x = x, y = y)) +
    geom_abline(intercept = coef(model)[1], slope = coef(model)[2]) +
    geom_rect(data = df_plot, aes(ymin = y_hat, ymax = y, xmin = x, xmax = x + resid), color = "black", linetype = "dotted", fill = "red", alpha = 0.2) +
    geom_segment(data = df_plot, aes(x = x, y = y, xend = x, yend = y_hat), color = "red") +
    geom_point(data = df_plot, aes(x = x, y = y), color = "red", size = 2) +
    geom_text(data = df_plot, aes(x = x + resid/2, y = y + resid/2, label = loss_label), color = "red")
  coord_fixed()
  
  gg2 = ggplot() +
    stat_function(data = data.frame(x = c(-4, 4)), mapping = aes(x), fun = function (x) {x^2}) +
    geom_point(data = df_plot, aes(x = resid, y = loss), color = "red", size = 2) +
    geom_segment(data = df_plot, mapping = aes(x = resid, y = 0, xend = resid, yend = loss), color = "red") +
    xlab(expression(Residuals == y - hat(y))) + ylab(expression(L(hat(y), y))) +
    geom_text(data = df_plot, mapping = aes(x = resid, y = loss, label = loss_label), color = "red", hjust = -0.5)
  
  return (gridExtra::grid.arrange(gg1, gg2, ncol = 2))
}


pdf("plot_quad_loss.pdf", height = 2.5)

set.seed(31415)

x = 1:5
y = 2 + 0.5 * x + rnorm(length(x), 0, 1.5)
data = data.frame(x = x, y = y)
model = lm(y ~ x)

plotModQuadraticLoss(data = data, model = model, pt_idx = c(1,4))
ggsave("plot_quad_loss.pdf", width = 7, height = 2.5)
dev.off() 

