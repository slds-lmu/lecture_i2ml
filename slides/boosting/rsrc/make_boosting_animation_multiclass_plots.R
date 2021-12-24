library(mlr3verse)
library(mlr3extralearners)
library(mlr3viz)
library(mlbench)
library(ggplot2)
library(viridis)
library(gbm)
library(metR)
library(gridExtra)
library(grid)
library(glue)

plot_boosting_multiclass <- function(iters) {
  set.seed(0)

  iris_task <- tsk("iris")$select(c("Sepal.Length", "Sepal.Width"))
  # shrinkage
  iris_data <- iris_task$data()

  first_rows <- tapply(1:nrow(iris_data), iris_data$Species, head,1)
  iris_data_mod <- rbind(iris_data[first_rows,], iris_data[-first_rows,])

  gbm_fit <- gbm(formula = Species ~ .,
                 data = iris_data_mod,
                 distribution = "multinomial",
                 n.trees = iters,
                 interaction.depth = 3,
                 shrinkage = 0.001,
                 keep.data = FALSE,
                 bag.fraction = 0.1,
                 n.minobsinnode = 5
  )


  grid_size <- 100

  grid <- expand.grid(
    seq(min(iris_data_mod$Sepal.Length) - 0.5, max(iris_data_mod$Sepal.Length) + 0.5, length.out = grid_size),
    seq(min(iris_data_mod$Sepal.Width) - 0.5, max(iris_data_mod$Sepal.Width) + 0.5, length.out = grid_size))
  colnames(grid) <- c("Sepal.Length", "Sepal.Width")
  res_score <- predict(gbm_fit, grid)
  dim(res_score) <- c(grid_size^2, 3)
  colnames(res_score) <- unique(iris_data[first_rows,]$Species)
  final_score <- apply(res_score, 1, max)

  softmax <- function(x){
    exp(x) / sum(exp(x))
  }

  res_prob <- t(apply(res_score, 1, softmax))
  colnames(res_prob) <- unique(iris_data[first_rows,]$Species)
  final_prob <- apply(res_prob, 1, max)
  predicted_class <- colnames(res_prob)[max.col(res_prob)]
  tile_df <- cbind(grid, Prob=final_prob)
  tile_df <- cbind(tile_df, Pred.Species=predicted_class)

  contour_df <- cbind(grid, Score=final_score)
  contour_df <- cbind(contour_df, Pred.Species=predicted_class)

  prediction_plot <- ggplot(data = tile_df, mapping = aes(x=Sepal.Length, y=Sepal.Width, fill=Pred.Species, alpha=Prob)) +
    geom_tile(linetype = 0, size = 0) +
    geom_point(data = iris_data, mapping = aes(x=Sepal.Length, y=Sepal.Width, fill=Species, alpha=NULL), shape=21) +
    scale_fill_viridis(end=0.9, discrete = TRUE)

  species <- unique(contour_df$Pred.Species)
  colors <- viridis(length(species), end = 0.9)
  contour_plot <- ggplot(data = contour_df, mapping = aes(x=Sepal.Length, y=Sepal.Width, z=Score, color=Pred.Species, fill=Score, alpha=Score))
  for (i in 1:length(species)) {
    contour_plot <- contour_plot + geom_tile(data = contour_df[contour_df$Pred.Species == species[i],], fill=colors[i], linetype = 0, size = 0, color=colors[i])
  }
  contour_plot <- contour_plot +
    geom_contour(color="black") +
    geom_text_contour(color="black") +
    scale_fill_continuous(name="Score", low="white", high="blue") +
    scale_color_viridis(end=0.9, discrete = TRUE)


  grid.arrange(prediction_plot, contour_plot, ncol=2, nrow=1)
}

m <- c(1,2,5,10,100)

for (i in m) {
  p <- plot_boosting_multiclass(i)
  ggsave(glue("../figure/boosting_multiclass_{i}.png"), plot = p, width = 13, height = 6)
}
