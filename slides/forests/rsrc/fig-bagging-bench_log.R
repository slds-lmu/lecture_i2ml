library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(ggplot2)

set.seed(123)

# bagging example from mlr3
gr_single_pred = po("subsample", frac = 0.7) %>>% lrn("classif.log_reg")
gr_pred_set = ppl("greplicate", graph = gr_single_pred, n = 10)
gr_bagging = gr_pred_set %>>% po("classifavg", innum = 10)

# turn graph into learner
glrn_bagging = as_learner(gr_bagging)
glrn_bagging$id = "bagging"

lrn_log_reg = lrn("classif.log_reg")
learners = c(glrn_bagging, lrn_log_reg)

bmr = benchmark(benchmark_grid(tsk("sonar"), learners,
                               rsmp("cv", folds = 3)))

bmr$aggregate()[, .(learner_id, classif.ce)]

# visualisation

data <- data.frame(
  learner_id = c("bagged logistic regression", "single logistic regression"),
  classif_ce = c(0.2398896, 0.2834369)
)

g <- ggplot(data, aes(x = learner_id, y = classif_ce, fill = learner_id)) +
  geom_bar(stat = "identity", width = 0.5, color = "black", show.legend = FALSE) +
  geom_text(aes(label = round(classif_ce, 3)), vjust = -0.5) +
  labs(title = "Comparison of Classification Error",
       x = "Method",
       y = "Classification Error") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

data <- data.frame(
  learner_id = c("bagged logistic regression", "single logistic regression"),
  classif_ce = c(0.2499655, 0.3124914)
)

g <- ggplot(data, aes(x = learner_id, y = classif_ce, fill = learner_id)) +
  geom_bar(stat = "identity", width = 0.5, color = "black", show.legend = FALSE) +
  geom_text(aes(label = round(classif_ce, 3)), vjust = -0.5) +
  labs(x = "Method",
       y = "Classification Error") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(size = 14),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    plot.title = element_text(size = 20)
  )

print(g)

ggsave("~/bagging-bench_log.jpg", plot = g, device = "jpeg", width = 10, height = 8, units = "in", dpi = 300)

