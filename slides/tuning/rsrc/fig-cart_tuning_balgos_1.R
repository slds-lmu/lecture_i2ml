 
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
library(rpart)
library(rpart.plot)
library(randomForest)
library(rattle)
library(smoof)
library(kableExtra)
library(kknn)
library(e1071)
library(rattle)

library(plyr)
library(kernlab)

source("plotTune.R")
options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))



scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


set.seed(600000)
pdf("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)


x = y = seq(-10, 10, length.out = 10)
d = expand.grid(x = x, y = y)
pl = plotTune(d)
print(pl)
ggsave("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)
dev.off()

