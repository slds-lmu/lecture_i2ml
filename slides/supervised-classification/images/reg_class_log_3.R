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


pdf("reg_class_log_3.pdf", width = 8, height = 2.2)
n = 100
df = data.frame(x = rep(seq(from = -10, to  = 10, length.out = n ), times = 4),
                theta1 = rep(c(-2,-0.3, 1, 6), each = n))
df$y = exp(df$x * df$theta1) / (1 + exp(df$theta1 * df$x))

ggplot(df) + geom_line(aes(x = x, y = y, group = theta1, color=factor(theta1))) +
  xlab("f")  + ylab("s") +
  scale_color_viridis_d(expression(alpha))
ggsave("reg_class_log_3.pdf", width = 8, height = 2.2)
dev.off()

