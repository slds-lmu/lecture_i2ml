 
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


pdf("../figure/reg_class_log_2.pdf", width = 8, height = 2.2)
n = 100
df = data.frame(x = rep(seq(from = -10, to  = 10, length.out = n ), times = 3),
                intercept = rep(c(-3,0,3), each = n))
df$y = exp(df$intercept + df$x) / (1 + exp(df$intercept + df$x))

ggplot(df) + geom_line(aes(x = x, y = y, group = intercept, color = factor(intercept))) +
  xlab("f")  + ylab("s") +
  scale_color_viridis_d(expression(theta[0]))
ggsave("../figure/reg_class_log_2.pdf", width = 8, height = 2.2)
dev.off()

