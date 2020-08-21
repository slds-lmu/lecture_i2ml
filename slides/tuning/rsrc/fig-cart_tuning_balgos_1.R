 
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

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))



scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


set.seed(600000)
pdf("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)
library(tidyr)
library(kernlab)
plotTune = function(d) {
  d$TestAccuracy = mvtnorm::dmvnorm(x = d, mean = c(5,5), sigma = 40 * diag(2)) * 120 + 0.4
  pl = ggplot(data = d, aes(x = x, y = y, color = TestAccuracy))
  pl = pl + geom_point(size = d$TestAccuracy * 4)
  pl = pl + xlab("Hyperparameter 1") + ylab("Hyperparameter 2") + coord_fixed()
  return(pl)
}
x = y = seq(-10, 10, length.out = 10)
d = expand.grid(x = x, y = y)
pl = plotTune(d)
print(pl)
ggsave("../figure/cart_tuning_balgos_1.pdf", width = 8, height = 3.5)
dev.off()

