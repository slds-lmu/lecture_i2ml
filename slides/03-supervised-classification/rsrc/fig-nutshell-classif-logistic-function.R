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
y = factor(as.numeric((x1 + x2 + rnorm(n) > 7)))
df = data.frame(x1 = x1, x2 = x2, y = y)

task = TaskClassif$new("logreg_task", 
                       backend = df, 
                       target = "y", 
                       positive = "0")

learner = lrn("classif.log_reg", predict_type = "prob")

model = learner$train(task)$model
prediction = learner$train(task)$predict(task)

df$score = predict(model)
df$prob = prediction$prob[, "0"]


df$y = as.factor(abs(as.numeric(df$y) - 2))
legend_title <- "Class"

p2 = ggplot(df, aes(x = score, y = prob)) + 
  ggtitle("Logistic Function") +
  geom_line() + 
  geom_point(aes(shape=y, color = y), size = 3) +
  geom_hline(yintercept = 0.5, color = "black",  linetype = "dashed") +
  annotate("text", x = 5.5, y = 0.56, size = 6, label = "Threshold",
           parse = TRUE, color = "black") +
  guides(color=guide_legend(title=legend_title), shape = guide_legend(title=legend_title))+
  theme_bw()
p2 = p2 + xlim(c(-10, 10)) +  theme(axis.text=element_text(size=20),title=element_text(size = 20), axis.title=element_text(size=18), 
                                    legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=20),
                                    legend.text = element_text(size=18), legend.title.align=0.3) 

ggsave("figure/nutshell_classif_logistic_function.png", plot = p2, width = 8, height = 4)