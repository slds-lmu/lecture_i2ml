# PREREQ -----------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(tidyverse)

load("overtuning_data.rds")

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_tuning_nestresample_1.pdf", width = 8, height = 3.5)

df_overtuning %>%
  group_by(data_dim, tuning_method, number_points) %>%
  dplyr::summarize(performance = mean(performance)) %>%
  mutate(number_points = as.integer(as.character(number_points))) %>%
  ggplot(aes(x = number_points, 
             y = performance, 
             color = data_dim, 
             linetype = tuning_method)) +
  geom_line() +
  xlab("Amount of tried hyperparameter configurations") +
  ylab("Tuned Performance") +
  scale_linetype_discrete(name = "") +
  scale_color_viridis_d(end = .9)

ggsave("../figure/cart_tuning_nestresample_1.pdf", width = 8, height = 3.5)
dev.off()