# goal here is to visualize the advantage of LDA over QDA in high dimensions,
# thus we set up some toy datasets, and increase the dimension while ensuring 
# that there are enough observations for QDA

library(mlr3)
library(mlr3learners)
library(ggplot2)

set.seed(123)
# some options for the plot
plot_width <- 10
plot_height <- 5
plot_dpi <- 300

# create toy datasets with increasing dimensions
# with 10 observations per feature each
dimensions <- c(2, 5, 10, 20, 50, 100, 200, 300)
observations <- sapply(dimensions, function(dim) dim * 10)

datasets <- lapply(seq_along(dimensions), function(i) {
  data <- as.data.frame(matrix(rnorm(observations[i] * dimensions[i]), ncol = dimensions[i]))
  data$target <- as.factor(sample(c("A", "B"), observations[i], replace = TRUE))
  
  # we add some class-specific shifts to create some structure across up to 5 features
  idx_A <- which(data$target == "A")
  idx_B <- which(data$target == "B")
  num_shift_features <- min(5, dimensions[i])
  data[idx_A, 1:num_shift_features] <- data[idx_A, 1:num_shift_features] + 1
  return(data)
})

lrn_lda = lrn("classif.lda", predict_type = "prob")
lrn_qda = lrn("classif.qda", predict_type = "prob")

results <- list()
for (i in seq_along(datasets)) {
  task <- TaskClassif$new(id = paste0("toy_data_dim_", dimensions[i]), backend = datasets[[i]], target = "target")
  resampling <- rsmp("cv", folds = 10)
  
  design <- benchmark_grid(
    tasks = task,
    learners = list(lrn_lda, lrn_qda),
    resamplings = resampling
  )
  
  bmr <- benchmark(design)
  results[[i]] <- bmr$aggregate(msr("classif.ce"))
}

# combines results into a data frame for plotting
plot_data <- do.call(rbind, lapply(seq_along(results), function(i) {
  df <- results[[i]]
  df$dimension <- dimensions[i]
  return(df)
}))

# finally, the plot:
# CE vs. number of dimensions
plot <- ggplot(plot_data, aes(x = dimension, y = classif.ce, color = learner_id, group = learner_id)) +
  geom_line(size = 1.5) +
  geom_point(size = 3) +
  scale_color_manual(values = c("#E69F00", "#0072B2")) +
  labs(
    x = "number of dimensions",
    y = "classification error",
    color = "learner"
  ) +
  theme_minimal(base_size = 18) +
  theme(
    text = element_text(face = "bold"),
    axis.title = element_text(face = "bold", size = 20),
    axis.text = element_text(face = "bold", size = 16),
    legend.title = element_text(face = "bold", size = 20),
    legend.text = element_text(face = "bold", size = 16)
  )
ggsave("../figure/disc_cod.png", plot = plot, width = plot_width, height = plot_height, dpi = plot_dpi)
