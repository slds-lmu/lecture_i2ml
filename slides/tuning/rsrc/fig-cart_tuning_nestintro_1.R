 
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
library(reshape2)

library(plyr)
library(kernlab)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


pdf("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)

ggd = BBmisc::load2("overtuning-example.RData", "res2.mean")
ggd = reshape2::melt(ggd, measure.vars = colnames(res2), value.name = "tuneperf");
colnames(ggd)[1:2] = c("data.size", "iter")
ggd = BBmisc::sortByCol(ggd, c("data.size", "iter"))
ggd$data.size = as.factor(ggd$data.size)


pl = ggplot(ggd, aes(x = iter, y = tuneperf, col = data.size))
pl =  pl + geom_line() + ylab("Tuning Error") + xlab("Iteration") + labs(colour = "Data Size")
print(pl)
ggsave("../figure/cart_tuning_nestintro_1.pdf", width = 8, height = 3.5)
dev.off()

