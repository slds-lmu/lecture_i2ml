# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(1)

n = 40
x = runif(2 * n, min = 0, max = 7)
x1 = x[1:n]
x2 = x[(n + 1):(2 * n)]
y = factor(x1 + x2 + rnorm(n) > 7)
df = data.frame(x1 = x1, x2 = x2, y = y)

task = TaskClassif$new("logreg_task", 
                       backend = df, 
                       target = "y", 
                       positive = "FALSE")

learner = lrn("classif.log_reg", predict_type = "prob")

model = learner$train(task)$model
prediction = learner$train(task)$predict(task)

df$score = -predict(model)
df$prob = prediction$prob[, "FALSE"]

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_log_6.pdf", width = 8, height = 4)

plot_learner_prediction(learner, task) +
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/reg_class_log_6.pdf", width = 8, height = 4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_log_7.pdf", width = 2, height = 2)

p2 = ggplot(df, aes(x = score, y = prob)) + 
  geom_line() + 
  geom_point(aes(colour = y), size = 2) +
  scale_color_viridis_d(end = .9)
p2 = p2 + 
  theme(legend.position = "none") + 
  xlim(c(-10, 10))
plot(p2)

ggsave("../figure/reg_class_log_7.pdf", width = 2, height = 2)
dev.off()