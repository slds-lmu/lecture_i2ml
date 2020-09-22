 
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
pdf("../figure/cart_forest_intro_4.pdf", width = 8, height = 4.5)
library(tidyr)
library(kernlab)

data(spam)
model = randomForest(type ~., data=spam, ntree=150, proximity=TRUE)

data.frame(model$err.rate, iter = seq_len(nrow(model$err.rate))) %>%
  gather(key = "error.type", value = "error.measured", -iter) %>%
  ggplot(mapping = aes(x = iter, y = error.measured, color = error.type)) +
  geom_line() +
  xlab("Number of Trees") +
  ylab("MCE") +
  labs(color = "")
ggsave("../figure/cart_forest_intro_4.pdf", width = 8, height = 4.5)
dev.off()

