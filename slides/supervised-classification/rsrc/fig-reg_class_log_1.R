 
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

#set.seed(600000)
options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


pdf("../figure/reg_class_log_1.pdf", width = 8, height = 3.5)
n = 100
df = data.frame(x = seq(from = -10, to  = 10, length.out = n))
df$y = exp(df$x) / (1 + exp(df$x))
ggplot(df) + geom_line(aes(x = x, y = y)) + scale_x_continuous('f')  + scale_y_continuous('s(f)')
ggsave("../figure/reg_class_log_1.pdf", width = 8, height = 3.5)
dev.off()

