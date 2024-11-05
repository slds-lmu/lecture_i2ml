# PREREQ -----------------------------------------------------------------------
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)

# OPTIONS
plot_width <- 20
plot_height <- 10
plot_dpi <- 300
point_size <- 9
base_size <- 40

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

set.seed(123)

# DATA -------------------------------------------------------------------------
task = tsk("iris")
task$select(c("Petal.Width", "Petal.Length"))

learner_lda = lrn("classif.lda", predict_type = "prob")
learner_qda = lrn("classif.qda", predict_type = "prob")

# TRAIN MODELS -----------------------------------------------------------------
learner_lda$train(task)
learner_qda$train(task)

# CREATE GRID FOR PREDICTIONS --------------------------------------------------
x_range <- seq(min(task$data()$Petal.Width) - 0.5, max(task$data()$Petal.Width) + 0.5, length.out = 200)
y_range <- seq(min(task$data()$Petal.Length) - 0.5, max(task$data()$Petal.Length) + 0.5, length.out = 200)
grid <- expand.grid(Petal.Width = x_range, Petal.Length = y_range)

# PREDICTIONS ON GRID ----------------------------------------------------------
# LDA PREDICTIONS
grid_lda_preds <- as.data.frame(learner_lda$predict_newdata(grid)$prob)
grid_lda_preds$Species <- factor(apply(grid_lda_preds, 1, function(row) colnames(grid_lda_preds)[which.max(row)]))
grid_lda_preds$max_prob <- apply(grid_lda_preds[, 1:3], 1, max)  # Extract the maximum probability for shading
lda_data <- cbind(grid, Species = grid_lda_preds$Species, max_prob = grid_lda_preds$max_prob)

# QDA PREDICTIONS
grid_qda_preds <- as.data.frame(learner_qda$predict_newdata(grid)$prob)
grid_qda_preds$Species <- factor(apply(grid_qda_preds, 1, function(row) colnames(grid_qda_preds)[which.max(row)]))
grid_qda_preds$max_prob <- apply(grid_qda_preds[, 1:3], 1, max)  # Extract the maximum probability for shading
qda_data <- cbind(grid, Species = grid_qda_preds$Species, max_prob = grid_qda_preds$max_prob)

# ORIGINAL DATASET FOR OVERLAY -------------------------------------------------
orig_data <- as.data.frame(task$data())

# PLOT LDA ---------------------------------------------------------------------
lda_plot <- ggplot() +
  geom_tile(data = lda_data, aes(x = Petal.Width, y = Petal.Length, fill = Species, alpha = max_prob)) +
  geom_point(data = orig_data, aes(x = Petal.Width, y = Petal.Length, color = Species), size = point_size) +
  xlab("Petal.Width") + ylab("Petal.Length") +
  theme_minimal() +
  scale_alpha(range = c(0.2, 0.8), guide = 'none') +  # Control the range of alpha values
  theme(
    plot.title = element_text(hjust = 0.5, size = base_size, face = "bold"),
    axis.title = element_text(size = base_size, face = "bold"),
    axis.text = element_text(size = base_size, face = "bold"),
    legend.title = element_text(size = base_size, face = "bold"),
    legend.text = element_text(size = base_size, face = "bold")
  )

ggsave("../figure/disc_db-lda.png", plot = lda_plot, width = plot_width, height = plot_height, dpi = plot_dpi)

# PLOT QDA ---------------------------------------------------------------------
qda_plot <- ggplot() +
  geom_tile(data = qda_data, aes(x = Petal.Width, y = Petal.Length, fill = Species, alpha = max_prob)) +
  geom_point(data = orig_data, aes(x = Petal.Width, y = Petal.Length, color = Species), size = point_size) +
  xlab("Petal.Width") + ylab("Petal.Length") +
  theme_minimal() +
  scale_alpha(range = c(0.2, 0.8), guide = 'none') +  # Control the range of alpha values
  theme(
    plot.title = element_text(hjust = 0.5, size = base_size, face = "bold"),
    axis.title = element_text(size = base_size, face = "bold"),
    axis.text = element_text(size = base_size, face = "bold"),
    legend.title = element_text(size = base_size, face = "bold"),
    legend.text = element_text(size = base_size, face = "bold")
  )

ggsave("../figure/disc_db-qda.png", plot = qda_plot, width = plot_width, height = plot_height, dpi = plot_dpi)
