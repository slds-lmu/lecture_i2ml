# goal is to benchmark QDA versus NB versus LDA
library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3viz)
library(ggplot2)
library(data.table)

set.seed(123)

task = tsk("spam")

lrn_qda = lrn("classif.qda")
lrn_nb = lrn("classif.naive_bayes")
lrn_lda = lrn("classif.lda")

learners = list(lrn_nb, lrn_lda, lrn_qda)
bmr = benchmark(benchmark_grid(task, learners, rsmp("cv", folds = 5)))

a <- autoplot(bmr, type = "boxplot") +
  ylab("CE for 5-fold CV") +
  xlab("Learners") +
  scale_x_discrete(labels = c("QDA", "NB", "LDA")) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 22, face = "bold"),
    axis.text = element_text(size = 20, face = "bold"),
    legend.title = element_text(size = 22, face = "bold"),
    legend.text = element_text(size = 20, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
ggsave("../figure/nb-bench.png", plot = a, width = 12, height = 8, dpi = 300)
