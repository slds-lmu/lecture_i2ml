library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(ggplot2)
library(data.table)

set.seed(123)

create_bagging_pipeline <- function(base_learner) {
  gr_single_pred = po("subsample", frac = 0.7) %>>% lrn(base_learner)
  gr_pred_set = ppl("greplicate", graph = gr_single_pred, n = 100)
  gr_bagging = gr_pred_set %>>% po("classifavg", innum = 100)
  as_learner(gr_bagging)
}

glrn_bagging_log = create_bagging_pipeline("classif.log_reg")
glrn_bagging_log$id = "bagging_logistic"

glrn_bagging_rpart = create_bagging_pipeline("classif.rpart")
glrn_bagging_rpart$id = "bagging_tree"

lrn_log_reg = lrn("classif.log_reg")
lrn_rpart = lrn("classif.rpart")
lrn_ranger = lrn("classif.ranger")
lrn_kknn = lrn("classif.kknn") # default is already k=7

learners = list(glrn_bagging_log, lrn_log_reg, glrn_bagging_rpart, lrn_rpart, lrn_ranger, lrn_kknn)

tasks = lapply(c("sonar", "spam"), tsk)

bmr = benchmark(benchmark_grid(tasks, learners, rsmp("cv", folds = 10)))
results = bmr$aggregate()

data <- as.data.table(results)

g <- ggplot(data, aes(x = learner_id, y = classif.ce, fill = learner_id)) +
  geom_bar(stat = "identity", position = position_dodge(), width = 0.7) +
  facet_wrap(~ task_id, scales = "free_x") +
  geom_text(aes(label = sprintf("%.3f", classif.ce)), position = position_dodge(width = 0.7), vjust = -0.5) +
  labs(title = "comparison of classification error across methods and tasks",
       x = "method",
       y = "classification error",
       fill = "learner") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom")

print(g)

# TODO: ggplot für versch. slides
ggsave("~/all_learners_comparison.jpg", plot = g, device = "jpeg", width = 10, height = 8, units = "in", dpi = 300)
