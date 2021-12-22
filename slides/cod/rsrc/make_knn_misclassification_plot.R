# ------------------------------------------------------------------------------
# FIG: KNN MISCLASSIFICATION
# ------------------------------------------------------------------------------

library(ggplot2)
source("helpers/data_generators.R")
source("helpers/constants.R")
source("helpers/utilities.R")

# DATA -------------------------------------------------------------------------

df <- readRDS("datasets/knn_misclassification_dataset.rds")

# PLOTS ------------------------------------------------------------------------
p <- ggplot(data = df,
            aes(x = d, y = mmce.test.mean, colour = learner)) +
  theme_bw() +
  geom_line() +
  xlab("p") + ylab("Mean Misclassification Error") + labs(colour = "Learner") +
  ylim(c(0, 0.4)) +
  scale_color_discrete(breaks=unique(df$learner))

ggsave(filename = "../figure/knn_misclassification_plot.png", plot = p, height = 2.5, width = 7.5)