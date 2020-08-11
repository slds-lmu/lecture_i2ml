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


pdf("cart_tuning_nestresample_1.pdf", width = 8, height = 3.5)
load("overtuning_data.rds")
library(dplyr)
library(ggplot2)

df_overtuning %>%
  group_by(data_dim, tuning_method, number_points) %>%
  dplyr::summarize(performance = mean(performance)) %>%
  mutate(number_points = as.integer(as.character(number_points))) %>%
  ggplot(aes(x = number_points, y = performance, color = data_dim, linetype = tuning_method)) +
  geom_line() +
  xlab("Amount of tried hyperparameter configurations") +
  ylab("Tuned Performance") +
  scale_linetype_discrete(name = "")
ggsave("cart_tuning_nestresample_1.pdf", width = 8, height = 3.5)
dev.off()

