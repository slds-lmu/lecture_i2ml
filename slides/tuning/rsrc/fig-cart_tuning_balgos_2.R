# PREREQ -----------------------------------------------------------------------

library(tidyverse)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(12322)

rs_tr <- readRDS("tune_rs_example.rds")

rs_ggd <- rs_tr %>%
  select(iter = batch_nr, auc = classif.auc) %>% 
  mutate(auc = cummax(auc))

gs_tr <- readRDS("tune_gs_example.rds")

gs_ggd <- gs_tr %>%
  select(iter = batch_nr, auc = classif.auc) %>%
  mutate(auc = cummax(auc))

# PLOT -------------------------------------------------------------------------

rs_pl <- ggplot(rs_ggd, aes(x = iter, y = auc)) +
  geom_line() +
  theme_bw() +
  theme(axis.text = element_text(size = 18), 
        axis.title = element_text(size = 22)) +
  ylab("Maximal AUC") + 
  xlab("Iterations")

gs_pl <- ggplot(gs_ggd, aes(x = iter, y = auc)) +
  geom_line() +
  theme_bw() +
  theme(axis.text = element_text(size = 18),
        axis.title = element_text(size = 22)) +
  ylab("Maximal AUC") +
  xlab("Iterations")

ggsave("../figure/tuning_rs_example.pdf", plot = rs_pl, width = 8, height = 3)
ggsave("../figure/tuning_gs_example.pdf", plot = gs_pl, width = 8, height = 3)