# PREREQ -----------------------------------------------------------------------

library(data.table)
library(ggplot2)

# DATA -------------------------------------------------------------------------

load("holdout-biasvar.RData")

# PLOT 1 -----------------------------------------------------------------------

ggd$type = as.factor(ggd$type)

pl1 = ggplot2::ggplot(ggd, aes(x = split, y = mce, col = type))
pl1 = pl1 + ggplot2::geom_boxplot()
pl1 = pl1 + ggplot2::geom_hline(yintercept = true_performance)
pl1 = pl1 + ggplot2::theme(axis.text.x = element_text(angle = 45)) 
pl1 = pl1 + ggplot2::scale_color_viridis_d(end = 0.5)
print(pl1)

ggplot2::ggsave(
  "../figure/eval-resampling-example-1.pdf", pl1, width = 8, height = 3.5)

# PLOT 2 -----------------------------------------------------------------------

gmse$split = as.numeric(as.character(gmse$split))
gmse$type = as.factor(gmse$type)

pl2 = ggplot2::ggplot(gmse, aes(x = split, y = mse, col = type))
pl2 = pl2 + ggplot2::geom_line()
pl2 = pl2 + ggplot2::scale_y_log10()
pl2 = pl2 + ggplot2::scale_x_continuous(breaks = gmse$split)
pl2 = pl2 + ggplot2::theme(axis.text.x = element_text(angle = 45))
pl2 = pl2 + ggplot2::ylab(expression(paste("MSE of ", widehat(GE))))
pl2 = pl2 + ggplot2::scale_color_viridis_d(end = 0.5)
print(pl2)

ggplot2::ggsave(
  "../figure/eval-resampling-example-2.pdf", width = 7, height = 3.5)