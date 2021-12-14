# ------------------------------------------------------------------------------
# FIG: LM MSE
# ------------------------------------------------------------------------------

library(ggplot2)
library(reshape)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------

df <- readRDS("datasets/lm_mse_dataset.rds")
df <- melt(df, id.vars = c("task_id", "learner_id", "d"))

# PLOTS ------------------------------------------------------------------------
p <- ggplot(data = df[df$d != 500, ], aes(x = d, y = value, colour = learner_id)) +
  geom_line() +
  xlab("Number of noise variables") +
  ylab("Mean Squared Error") +
  labs(colour = "Learner")


ggsave("../figure/lm_mse_plot.png", width = 7.5, height= 2.5)