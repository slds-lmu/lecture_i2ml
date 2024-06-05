# plots OOB errors for different classes of spam; visualizes a potential use case of OOB errors
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

plot_data <- data.frame(model$err.rate, iter = seq_len(nrow(model$err.rate))) %>%
  gather(key = "error.type", value = "error.measured", -iter)

ggplot(plot_data, mapping = aes(x = iter, y = error.measured, color = error.type, linetype = error.type)) +
  geom_line(size = 2) +
  scale_color_viridis_d(end = .9) +
  scale_linetype_manual(values = c("nonspam" = "dotted", "OOB" = "solid", "spam" = "dashed")) +
  xlab("number of trees") +
  ylab("MCE") +
  labs(color = "", linetype = "") +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14))
ggsave("../figure/forest-oob.pdf", width = 8, height = 4.5)
