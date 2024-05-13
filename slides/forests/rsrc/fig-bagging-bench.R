library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3viz)
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

glrn_bagging_kknn = create_bagging_pipeline("classif.kknn")
glrn_bagging_kknn$id = "bagging_kknn"

lrn_log_reg = lrn("classif.log_reg")
lrn_rpart = lrn("classif.rpart")
lrn_ranger = lrn("classif.ranger")
lrn_kknn = lrn("classif.kknn") # default is already k=7

learners = list(glrn_bagging_log, lrn_log_reg, glrn_bagging_rpart, lrn_rpart, glrn_bagging_kknn, lrn_kknn)

tasks = lapply(c("sonar", "spam"), tsk)

bmr = benchmark(benchmark_grid(tasks, learners, rsmp("cv", folds = 10)))
results = bmr$aggregate()

# visualization
data <- as.data.table(results)
data[, learner_id := factor(learner_id,
                            levels = c("classif.log_reg", "bagging_logistic", "bagging_tree", "classif.rpart", "classif.kknn", "bagging_kknn"),
                            labels = c("Logistic Regression", "Logistic Regression bagged", "CART bagged", "CART", "kknn", "kknn bagged"))]


data_sonar <- data[task_id == "sonar"]
data_spam <- data[task_id == "spam"]

p1 <- ggplot(data_sonar, aes(x = learner_id, y = classif.ce, fill = learner_id)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(title = "Classification Error for Sonar Task", x = "Method", y = "Classification Error") +
  theme_minimal()

p2 <- ggplot(data_spam, aes(x = learner_id, y = classif.ce, fill = learner_id)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(title = "Classification Error for Spam Task", x = "Method", y = "Classification Error") +
  theme_minimal()

print(p1)
print(p2)

a <- autoplot(bmr)

print(a)
