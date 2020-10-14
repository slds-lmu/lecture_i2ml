# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(randomForest)
library(kernlab)
library(tidyverse)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)

data(spam)
model = randomForest(type ~., data = spam, ntree = 150, proximity = TRUE)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_forest_intro_4.pdf", width = 8, height = 4.5)

data.frame(model$err.rate, iter = seq_len(nrow(model$err.rate))) %>%
  gather(key = "error.type", value = "error.measured", -iter) %>%
  ggplot(mapping = aes(x = iter, y = error.measured, color = error.type)) +
  geom_line() +
  scale_color_viridis_d(end = .9) +
  xlab("Number of Trees") +
  ylab("MCE") +
  labs(color = "")

ggsave("../figure/cart_forest_intro_4.pdf", width = 8, height = 4.5)
dev.off()