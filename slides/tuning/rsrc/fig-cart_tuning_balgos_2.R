# PREREQ -----------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(gridExtra)
library(viridis)

# DATA -------------------------------------------------------------------------

set.seed(12322)
rs_tr <- readRDS("tune_rs_example.rds")

rs_ggd <- rs_tr %>%
  select(iter = batch_nr, auc = classif.auc) %>% 
  mutate(auc = cummax(auc)) %>%
  add_column(optimizer = "random search")

gs_tr <- readRDS("tune_gs_example.rds")

gs_ggd <- gs_tr %>%
  select(iter = batch_nr, auc = classif.auc) %>%
  mutate(auc = cummax(auc)) %>%
  add_column(optimizer = "grid search")

df <- rbind(rs_ggd, gs_ggd)
df$optimizer <- factor(df$optimizer, levels = c("random search", "grid search"))

# PLOT -------------------------------------------------------------------------

rs_pl <- ggplot(rs_ggd, aes(x = iter, y = auc)) +
  geom_line() +
  theme_bw() +
  ylab("Maximal AUC") + 
  xlab("Iterations") +
  labs(title = "Random Search")

gs_pl <- ggplot(gs_ggd, aes(x = iter, y = auc)) +
  geom_line() +
  theme_bw() +
  ylab("Maximal AUC") +
  xlab("Iterations") +
  labs(title = "Grid Search")

p <- ggplot(df, aes(x = iter, y = auc, color = optimizer)) +
  geom_line() +
  theme_bw() +
  labs(x = "Iterations", y = "Maximal AUC") +
  scale_color_viridis(discrete = TRUE, end = 0.9)

ggsave("../figure/tuning_example.pdf", plot = p, width = 7, height = 2.5)

# ggsave("../figure/tuning_rs_example.pdf", plot = rs_pl, width = 8, height = 3)
# ggsave("../figure/tuning_gs_example.pdf", plot = gs_pl, width = 8, height = 3)
