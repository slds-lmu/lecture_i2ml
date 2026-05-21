# goal here is to visualize a decison boundary of logistic regression, and show
# how scores translate to a probability for each observation

# PREREQ -----------------------------------------------------------------------

library(ggplot2)
library(mlr3)
library(data.table)

# common settings
set.seed(1234)
plot_width <- 13
plot_height <- 10
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 13

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

# PLOT 1 -----------------------------------------------------------------------

# to plot the decision region / boundary, we need the learner's predictions
df_pred = data.frame(task$data(), prob = prediction$prob[, "0"], prediction = prediction$response)

# creates a grid for decision boundary visualization
grid_x1 = seq(min(df$x1) - 1, max(df$x1) + 1, length.out = 100)
grid_x2 = seq(min(df$x2) - 1, max(df$x2) + 1, length.out = 100)
grid = expand.grid(x1 = grid_x1, x2 = grid_x2)

# predicts on the grid
grid_prediction = learner$predict_newdata(as.data.table(grid))$response
grid$prediction = as.factor(grid_prediction)

# plot the decision boundary and predictions
p1 = ggplot() +
  geom_tile(data = grid, aes(x = x1, y = x2, fill = prediction), alpha = 0.3) +
  geom_point(data = df_pred, aes(x = x1, y = x2, color = y), size = point_size, alpha = 1) +
  scale_fill_manual(values = c("0" = "#E69F00", "1" = "#0072B2"), guide = 'none') +
  scale_color_manual(values = c("0" = "#E69F00", "1" = "#0072B2"), name = "y") +
  labs(x = expression(x[1]), y = expression(x[2])) +
  theme_minimal(base_size = base_size)
print(p1)

ggsave("../figure/log_reg-db.png", plot = p1, width = plot_width, height = plot_height, dpi = plot_dpi)

# PLOT 2 -----------------------------------------------------------------------

df$y = as.factor(abs(as.numeric(df$y) - 2))
p2 = ggplot(df, aes(x = score, y = prob)) + 
  geom_line(linewidth = line_size) + 
  geom_point(aes(colour = y), size = point_size) +
  scale_color_manual(values = c("0" = "#E69F00", "1" = "#0072B2") ) +
  labs(x = "score", y = "probability") +
  theme_minimal(base_size = base_size)
print(p2)

ggsave("../figure/log_reg-scores.png", plot = p2, width = plot_width, height = plot_height, dpi = plot_dpi)
